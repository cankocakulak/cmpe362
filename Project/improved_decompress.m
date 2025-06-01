function improved_decompress()
    % Add helper directories to path
    addpath('./helpers/');
    addpath('./helpers/compression/');
    addpath('./helpers/decompression/');
    
    % Load configuration
    cfg = config();

    % Motion Estimation specific config (ensure this is in your config.m if used for indexing)
    if isfield(cfg, 'BLOCK_SIZE')
        block_size = cfg.BLOCK_SIZE;
    else
        block_size = 8; % Default block size if not in config
        warning('BLOCK_SIZE not found in config.m, using default value: %d', block_size);
    end

    % Constants (should match compression)
    output_dir = './decompressed_improved/'; % Changed output directory
    input_file = 'result_improved.bin'; % Changed input file name
    MAX_PAIRS = 64;  % Maximum possible pairs for one channel in 8x8 block
    
    % Create output directory if it doesn't exist
    if ~exist(output_dir, 'dir')
        mkdir(output_dir);
    end
    
    % Get quantization matrix
    q_mat = q_matrix_improved();
    
    % Open input file
    fid = fopen(input_file, 'rb');
    if fid == -1
        error('Cannot open input file: %s', input_file);
    end
    
    % Read header
    GOP_SIZE = fread(fid, 1, 'uint32');
    total_frames = fread(fid, 1, 'uint32');
    width = fread(fid, 1, 'uint32');
    height = fread(fid, 1, 'uint32');
    
    % Validate header values
    if isempty(GOP_SIZE) || isempty(total_frames) || isempty(width) || isempty(height) || ...
       any([GOP_SIZE, total_frames, width, height] <= 0) || ...
       any([GOP_SIZE, total_frames, width, height] > 10000)  % reasonable max value
        fclose(fid);
        error('Invalid header values: GOP_SIZE=%d, frames=%d, width=%d, height=%d', ...
              GOP_SIZE, total_frames, width, height);
    end
    
    fprintf('Header values: GOP_SIZE=%d, frames=%d, width=%d, height=%d\n', ...
            GOP_SIZE, total_frames, width, height);
    
    % Calculate macroblock dimensions
    mb_rows = height / block_size; % Use cfg.BLOCK_SIZE
    mb_cols = width / block_size;  % Use cfg.BLOCK_SIZE
    expected_macroblocks = mb_rows * mb_cols;
    
    % Process each frame
    prev_frame = []; % Stores the fully reconstructed previous frame
    
    for frame_idx = 1:total_frames
        fprintf('Decompressing frame %d / %d\n', frame_idx, total_frames);
        
        is_iframe = fread(fid, 1, 'uint8');
        if isempty(is_iframe)
            fclose(fid);
            error('Unexpected end of file while reading frame type for frame %d', frame_idx);
        end
        
        if is_iframe
            fprintf('Frame %d is I-frame\n', frame_idx);
        else
            fprintf('Frame %d is P-frame\n', frame_idx);
        end
        
        num_macroblocks_in_frame = fread(fid, 1, 'uint16');
        if isempty(num_macroblocks_in_frame) || num_macroblocks_in_frame ~= expected_macroblocks
            fclose(fid);
            error('Invalid number of macroblocks for frame %d: expected %d, got %d', ...
                  frame_idx, expected_macroblocks, num_macroblocks_in_frame);
        end
        
        current_frame_mb_cells = cell(mb_rows, mb_cols);
        
        for r_mb = 1:mb_rows
            for c_mb = 1:mb_cols
                mv_row = 0;
                mv_col = 0;

                if ~is_iframe
                    mv_row = fread(fid, 1, 'int8');
                    mv_col = fread(fid, 1, 'int8');
                    if isempty(mv_row) || isempty(mv_col)
                        fclose(fid);
                        error('Unexpected end of file while reading motion vector for frame %d, MB(%d,%d)', frame_idx, r_mb, c_mb);
                    end
                end

                decoded_block_component = zeros(block_size, block_size, 3); % This will be IDCT(Dequant(Quantized(Residual or Original)))

                for c_ch = 1:3 % color channel
                    num_pairs = fread(fid, 1, 'uint16');
                    if isempty(num_pairs) || num_pairs > MAX_PAIRS || num_pairs < 0 % num_pairs can be 0
                        fclose(fid);
                        error('Invalid number of RLE pairs at frame %d, MB(%d,%d), channel %d: %d', ...
                              frame_idx, r_mb, c_mb, c_ch, num_pairs);
                    end
                    
                    rle_data = zeros(num_pairs, 2);
                    for k_pair = 1:num_pairs
                        run_length = fread(fid, 1, 'uint16');
                        value = fread(fid, 1, 'int8');
                        if isempty(run_length) || isempty(value)
                            fclose(fid);
                            error('Unexpected end of file while reading RLE data for frame %d, MB(%d,%d), Ch %d, Pair %d', ...
                                  frame_idx, r_mb, c_mb, c_ch, k_pair);
                        end
                        rle_data(k_pair, 1) = run_length;
                        rle_data(k_pair, 2) = value;
                    end
                    
                    zigzag_vector = zeros(block_size*block_size, 1);
                    if ~isempty(rle_data)
                        zigzag_vector = rle_decode_single(rle_data, block_size*block_size);
                    end
                    
                    quantized_channel = inverse_zigzag(zigzag_vector, [block_size, block_size, 1]);
                    dequantized_channel = dequantize_block(quantized_channel, q_mat); % q_mat should be for block_size x block_size
                    decoded_block_component(:,:,c_ch) = apply_idct(dequantized_channel);
                end

                % Now reconstruct the actual macroblock content
                if ~is_iframe
                    if isempty(prev_frame)
                        fclose(fid);
                        error('prev_frame is empty for P-frame %d, MB(%d,%d). This should not happen.', frame_idx, r_mb, c_mb);
                    end
                    % P-frame: decoded_block_component is the decoded residual
                    % Need to fetch the reference block from prev_frame using motion vectors
                    ref_block_row_start_nominal = (r_mb-1)*block_size + 1;
                    ref_block_col_start_nominal = (c_mb-1)*block_size + 1;
                    
                    ref_block_row_actual = ref_block_row_start_nominal + mv_row;
                    ref_block_col_actual = ref_block_col_start_nominal + mv_col;
                    
                    % Boundary checks for the reference block (crucial!)
                    ref_block_row_actual_end = ref_block_row_actual + block_size - 1;
                    ref_block_col_actual_end = ref_block_col_actual + block_size - 1;

                    if ref_block_row_actual < 1 || ref_block_row_actual_end > height || ...
                       ref_block_col_actual < 1 || ref_block_col_actual_end > width
                        % This indicates an issue, MVs pointing out of bounds.
                        % For now, let's use a fallback: the block at the nominal position (0,0 MV)
                        % A more robust solution might involve padding or edge extension for ref_frame.
                        warning('Motion vector for P-frame %d, MB(%d,%d) points out of bounds. MV=(%d,%d). Using (0,0) MV instead.', ...
                                frame_idx, r_mb, c_mb, mv_row, mv_col);
                        ref_block_row_actual = ref_block_row_start_nominal;
                        ref_block_col_actual = ref_block_col_start_nominal;
                    end
                    
                    motion_compensated_ref_block = prev_frame(ref_block_row_actual : ref_block_row_actual + block_size - 1, ...
                                                              ref_block_col_actual : ref_block_col_actual + block_size - 1, :);
                    
                    reconstructed_mb = motion_compensated_ref_block + decoded_block_component;
                    current_frame_mb_cells{r_mb, c_mb} = max(0, min(255, reconstructed_mb));
                else
                    % I-frame: decoded_block_component is the reconstructed I-block itself
                    current_frame_mb_cells{r_mb, c_mb} = max(0, min(255, decoded_block_component));
                end
            end
        end
        
        current_reconstructed_frame = mb_to_frame(current_frame_mb_cells);
        % No need to clamp here if individual MBs are already clamped, but doesn't hurt.
        current_reconstructed_frame = max(0, min(255, current_reconstructed_frame)); 
        
        % Optional post-processing (filters, etc.) can be applied to current_reconstructed_frame
        % Example from original decompress.m (adjust if needed)
        if ~is_iframe && isfield(cfg, 'USE_MEDIAN_FILTER') && cfg.USE_MEDIAN_FILTER && frame_idx > cfg.ENHANCE_AFTER_FRAME
            for c_filter = 1:3 
                current_reconstructed_frame(:,:,c_filter) = custom_median_filter(current_reconstructed_frame(:,:,c_filter), cfg.MEDIAN_FILTER_SIZE);
            end
            current_reconstructed_frame = max(0, min(255, current_reconstructed_frame));
        end
        if ~is_iframe && isfield(cfg, 'USE_SHARPENING') && cfg.USE_SHARPENING && frame_idx > cfg.ENHANCE_AFTER_FRAME
            % Sharpening logic (ensure current_reconstructed_frame is used)
             for c_sharpen = 1:3 
                channel = current_reconstructed_frame(:,:,c_sharpen);
                laplacian = zeros(size(channel));
                for r_lap = 2:size(channel,1)-1 
                    for c_lap = 2:size(channel,2)-1 
                        laplacian(r_lap,c_lap) = 4*channel(r_lap,c_lap) - channel(r_lap-1,c_lap) - channel(r_lap+1,c_lap) - channel(r_lap,c_lap-1) - channel(r_lap,c_lap+1);
                    end
                end
                current_reconstructed_frame(:,:,c_sharpen) = channel + cfg.SHARPENING_STRENGTH * laplacian;
            end
            current_reconstructed_frame = max(0, min(255, current_reconstructed_frame));
        end

        output_path = fullfile(output_dir, sprintf('frame%03d.jpg', frame_idx));
        imwrite(uint8(current_reconstructed_frame), output_path);
        
        prev_frame = current_reconstructed_frame; % Update for the next iteration
        
        fprintf('Frame %d decompressed. Min/Max: %.2f/%.2f\n', frame_idx, ...
                min(current_reconstructed_frame(:)), max(current_reconstructed_frame(:)));
    end
    
    fclose(fid);
    fprintf('\nDecompression complete. %d frames saved to %s\n', total_frames, output_dir);
end 