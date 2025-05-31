# This is a new file, copied from compress.m
# It will be modified to include motion estimation. 

function compress()
    % Add helper directories to path
    addpath('./helpers/');
    addpath('./helpers/compression/');
    addpath('./helpers/decompression/');
    
    % Load configuration
    cfg = config();
    
    % Motion Estimation specific config (ensure these are in your config.m)
    if isfield(cfg, 'ME_SEARCH_RANGE')
        search_range = cfg.ME_SEARCH_RANGE;
    else
        search_range = 7; % Default search range if not in config
        warning('ME_SEARCH_RANGE not found in config.m, using default value: %d', search_range);
    end
    if isfield(cfg, 'BLOCK_SIZE')
        block_size = cfg.BLOCK_SIZE;
    else
        block_size = 8; % Default block size if not in config
        warning('BLOCK_SIZE not found in config.m, using default value: %d', block_size);
    end

    % Setup
    input_dir = './video_data/';
    output_file = 'result_improved.bin'; % Changed output file name
    
    % Get quantization matrix
    q_mat = q_matrix();
    
    % Debug: Print quantization matrix
    % fprintf('Quantization Matrix:\n');
    % disp(q_mat(1:4,1:4));  % Show top-left corner
    
    % Get list of frame files
    frame_files = dir(fullfile(input_dir, 'frame*.jpg'));
    total_frames = length(frame_files);
    
    % For testing, use only a limited number of frames
    if cfg.TEST_MODE
        total_frames = min(cfg.TEST_FRAMES, total_frames);
        fprintf('TEST MODE: Using only %d frames\n', total_frames);
    end
    
    % Sort frame files by number
    frame_numbers = zeros(total_frames, 1);
    for i_fn = 1:total_frames % Renamed loop variable
        % Extract frame number from filename
        frame_name = frame_files(i_fn).name;
        frame_numbers(i_fn) = str2double(regexp(frame_name, '\d+', 'match'));
    end
    [~, sort_idx] = sort(frame_numbers);
    frame_files = frame_files(sort_idx(1:total_frames));
    
    % Open output file
    fid = fopen(output_file, 'wb');
    
    % Write header
    fwrite(fid, cfg.GOP_SIZE, 'uint32');
    fwrite(fid, total_frames, 'uint32');
    
    % Sample a frame to get dimensions
    sample_frame = imread(fullfile(input_dir, frame_files(1).name));
    [height, width, ~] = size(sample_frame);
    fwrite(fid, width, 'uint32');
    fwrite(fid, height, 'uint32');
    
    % Process each frame
    prev_frame = []; % This will store the RECONSTRUCTED previous frame
    
    for frame_idx = 1:total_frames
        % Display progress
        fprintf('\n==== Processing frame %d / %d ====\n', frame_idx, total_frames);
        
        % Read current frame
        frame_path = fullfile(input_dir, frame_files(frame_idx).name);
        current_frame_raw = double(imread(frame_path)); % Keep raw current frame for ME
        
        % Debug: Print frame statistics
        % fprintf('Frame %d stats - Min: %.2f, Max: %.2f, Mean: %.2f\n', ...
        %         frame_idx, min(current_frame_raw(:)), max(current_frame_raw(:)), mean(current_frame_raw(:)));
        
        % Convert frame to macroblocks (these are original macroblocks)
        mb_cells_original = frame_to_mb(current_frame_raw);
        [mb_rows, mb_cols] = size(mb_cells_original);
        
        % This cell array will store the residuals (for P) or quantized DCT (for I)
        % which are then used for reconstruction of prev_frame
        processed_mb_for_reconstruction = cell(mb_rows, mb_cols);

        % Determine frame type
        is_iframe = is_i_frame(frame_idx, cfg.GOP_SIZE);
        fprintf('Frame %d is %s\n', frame_idx, conditional(is_iframe, 'I-frame', 'P-frame'));
        
        % Write frame type
        fwrite(fid, is_iframe, 'uint8');
        fwrite(fid, mb_rows * mb_cols, 'uint16');
        
        % Process each macroblock
        for r_mb = 1:mb_rows % r_mb for row of macroblocks
            for c_mb = 1:mb_cols % c_mb for column of macroblocks
                
                original_mb_content = mb_cells_original{r_mb, c_mb};
                mb_to_encode = []; % This will be the residual for P or original for I (before DCT)
                
                mv_row = 0; % Initialize motion vectors
                mv_col = 0;
                best_match_block_for_p_recon = []; % Store for P-frame reconstruction

                if ~is_iframe && ~isempty(prev_frame)
                    % P-frame processing with motion estimation
                    mb_row_start_in_frame = (r_mb-1)*block_size + 1;
                    mb_col_start_in_frame = (c_mb-1)*block_size + 1;

                    % Call block_matching: current_mb is original_mb_content
                    [mv_r, mv_c, best_match_block] = block_matching(original_mb_content, prev_frame, ...
                                                              mb_row_start_in_frame, mb_col_start_in_frame, search_range);
                    mv_row = mv_r;
                    mv_col = mv_c;
                    best_match_block_for_p_recon = best_match_block; % Save for reconstruction step

                    % Compute residual against the best_match_block
                    residual = original_mb_content - best_match_block;
                    
                    % For quality focus, use very minimal thresholding (optional)
                    % residual(abs(residual) < 1) = 0; 
                    
                    mb_to_encode = residual; % The residual is what we DCT and quantize

                    if r_mb == 1 && c_mb == 1 && frame_idx > 1 % Debug first MB of a P-frame
                        fprintf('P-Frame %d, MB(1,1): MV=(%d, %d)\n', frame_idx, mv_row, mv_col);
                        fprintf('Residual (after ME) stats - Min: %.2f, Max: %.2f\n', ...
                                min(mb_to_encode(:)), max(mb_to_encode(:)));
                    end
                else % I-frame
                    mb_to_encode = original_mb_content;
                end
                
                % Apply DCT
                dct_mb = apply_dct(mb_to_encode);
                
                % Quantize
                quantized_mb = quantize_block(dct_mb, q_mat);
                
                % For reconstructing the current frame (to be used as prev_frame in next iteration)
                dequantized_data = zeros(size(quantized_mb));
                for c_ch = 1:3
                    dequantized_data(:,:,c_ch) = quantized_mb(:,:,c_ch) .* q_mat;
                end
                idct_data = apply_idct(dequantized_data);

                if ~is_iframe && ~isempty(prev_frame) % P-frame: idct_data is decoded_residual
                    reconstructed_block = best_match_block_for_p_recon + idct_data; % Add residual to motion compensated block
                    processed_mb_for_reconstruction{r_mb, c_mb} = max(0, min(255, reconstructed_block));
                else % I-frame: idct_data is the reconstructed I-block
                    processed_mb_for_reconstruction{r_mb, c_mb} = max(0, min(255, idct_data));
                end
                
                % Zigzag scan for storage (always of the quantized_mb)
                zigzag_vector = zigzag_scan(quantized_mb);
                
                % Run-length encoding
                rle_encoded = rle_encode(zigzag_vector);
                
                % Write motion vectors for P-frame macroblocks BEFORE RLE data
                if ~is_iframe
                    fwrite(fid, int8(mv_row), 'int8');
                    fwrite(fid, int8(mv_col), 'int8');
                end

                % Write encoded RLE data
                for c_ch = 1:3
                    channel_data = rle_encoded{c_ch};
                    num_pairs = size(channel_data, 1);
                    fwrite(fid, num_pairs, 'uint16');
                    
                    for k_pair = 1:num_pairs % k_pair for RLE pair index
                        fwrite(fid, channel_data(k_pair, 1), 'uint16'); % run length
                        fwrite(fid, channel_data(k_pair, 2), 'int8');   % value
                    end
                end
            end
        end
        
        % Update reference frame (prev_frame) for the NEXT iteration
        if is_iframe
            % For I-frame, the reference is the reconstructed current frame
            % We need to reconstruct it from processed_mb_for_reconstruction which holds dequantized, IDCTed blocks
            reconstructed_current_frame = mb_to_frame(processed_mb_for_reconstruction);
            prev_frame = max(0, min(255, reconstructed_current_frame)); % Clamp
            fprintf('Stored reconstructed I-frame as reference\n');
        else % P-frame
            if isempty(prev_frame)
                error('prev_frame is empty for a P-frame, this should not happen after frame 1.');
            end
            % For P-frames, reconstruct by adding the processed residuals to the *motion-compensated* previous frame
            % This is tricky: prev_frame for ME search is from t-1.
            % The prev_frame for the *next* iteration (t+1) is the reconstruction of current frame (t).
            reconstructed_current_frame = zeros(height, width, 3);
            for r_mb_rec = 1:mb_rows % loop for reconstruction
                for c_mb_rec = 1:mb_cols
                    % Get the stored motion vectors (these were not written to file, so need to re-fetch or store them temporarily if needed for THIS reconstruction)
                    % For simplicity in this step, we assume we have the prev_frame (t-1)
                    % and the *residuals* for current frame (t) are in processed_mb_for_reconstruction.
                    % To reconstruct frame (t), we need the MVs of frame (t) to fetch blocks from prev_frame (t-1).
                    
                    % PROBLEM: Motion vectors are not stored per block in a way that this loop can easily access them
                    % for reconstruction here. The `block_matching` was done with `original_mb_content` from `current_frame_raw`
                    % Let's reconstruct P-frames using the motion vectors already found in the main loop.
                    % We need to store the MVs along with residuals in processed_mb_for_reconstruction or pass differently.

                    % Simpler approach for now: `prev_frame` IS the correctly reconstructed frame from time t-1.
                    % `processed_mb_for_reconstruction{r_mb_rec, c_mb_rec}` is the DECODED RESIDUAL for current block (r_mb_rec, c_mb_rec) of frame t.
                    % We need to find where this residual should be ADDED in `prev_frame` using motion vectors.
                    
                    % This reconstruction part needs to be aligned with how MVs are determined and used.
                    % The current `processed_mb_for_reconstruction` stores the dequantized, IDCT'd *residual*.
                    % The reference for this residual was `best_match_block` from `prev_frame`.

                    % --- REVISED RECONSTRUCTION LOGIC FOR P-FRAME --- 
                    % We need the original current macroblock to call block_matching again to get the MV and best_match_block
                    % or store MVs and use them. Storing MVs is better.

                    % Let's assume MVs are available for each block of the current P-frame. For now, this part is complex.
                    % The current loop for reconstruction uses `processed_mb_for_reconstruction` which contains decoded residuals.
                    % The reference for these residuals came from the motion search on `prev_frame`.
                    
                    % The prev_frame passed to block_matching IS the reconstructed frame from the previous iteration. That's correct.
                    % The `processed_mb_for_reconstruction{r_mb, c_mb}` correctly stores the dequantized, IDCT'd residual.

                    % To reconstruct current_frame at (r_mb_rec, c_mb_rec):
                    % 1. Get the actual content of prev_frame at the *motion-compensated* position.
                    %    This means we need the MVs that were calculated for original_mb_cells{r_mb_rec, c_mb_rec}.
                    %    This is becoming circular or requires storing all MVs for the current frame.
                    
                    % --- Let's simplify the P-frame reconstruction logic within the main loop --- 
                    % The `mb_cells{i,j}` in the original code stored the reconstructed block for P-frames.
                    % We need `processed_mb_for_reconstruction` to store the *reconstructed block itself*, not just the residual.
                    
                    % Back in the main r_mb, c_mb loop for P-frames, after getting the `residual_for_reconstruction = apply_idct(dequantized_residual)`: 
                    %   `reconstructed_block = best_match_block_from_ME + residual_for_reconstruction;`
                    %   `processed_mb_for_reconstruction{r_mb, c_mb} = max(0, min(255, reconstructed_block));`
                    % This change needs to be done above, in the main processing loop.
                end
            end
            % After the main r_mb, c_mb loop, `processed_mb_for_reconstruction` will contain fully reconstructed blocks for P-frames.
            reconstructed_current_frame = mb_to_frame(processed_mb_for_reconstruction);
            prev_frame = max(0, min(255, reconstructed_current_frame)); % Clamp
            fprintf('Stored reconstructed P-frame as reference\n');
        end
    end
    
    % Close file
    fclose(fid);
    
    % Display file size
    file_info = dir(output_file);
    file_size_mb = file_info.bytes / (1024 * 1024);
    fprintf('\nCompression complete. Output file size: %.2f MB\n', file_size_mb);
end

function result = conditional(condition, if_true, if_false)
    if condition
        result = if_true;
    else
        result = if_false;
    end
end 