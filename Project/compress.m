function compress()
    % Add helper directories to path
    addpath('./helpers/');
    addpath('./helpers/compression/');
    addpath('./helpers/decompression/');
    
    % Load configuration
    cfg = config();
    
    % Setup
    input_dir = './video_data/';
    output_file = 'result.bin';
    
    % Get quantization matrix
    q_mat = q_matrix();
    
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
    for i = 1:total_frames
        % Extract frame number from filename
        frame_name = frame_files(i).name;
        frame_numbers(i) = str2double(regexp(frame_name, '\d+', 'match'));
    end
    [~, sort_idx] = sort(frame_numbers);
    frame_files = frame_files(sort_idx(1:total_frames));  % Only take the frames we need
    
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
    prev_frame = [];
    
    for frame_idx = 1:total_frames
        % Display progress
        fprintf('Processing frame %d / %d\n', frame_idx, total_frames);
        
        % Read current frame
        frame_path = fullfile(input_dir, frame_files(frame_idx).name);
        current_frame = double(imread(frame_path));
        
        % Convert frame to macroblocks
        mb_cells = frame_to_mb(current_frame);
        [mb_rows, mb_cols] = size(mb_cells);
        
        % Determine frame type
        is_iframe = is_i_frame(frame_idx, cfg.GOP_SIZE);
        
        % Force specific frames to be I-frames if needed
        if ismember(frame_idx, cfg.FORCE_I_FRAMES)
            is_iframe = 1;
            fprintf('Forcing frame %d to be an I-frame for better quality\n', frame_idx);
        end
        
        % Write frame type
        fwrite(fid, is_iframe, 'uint8');
        
        % Write number of macroblocks
        fwrite(fid, mb_rows * mb_cols, 'uint16');
        
        % Process each macroblock
        for i = 1:mb_rows
            for j = 1:mb_cols
                % Get current macroblock
                current_mb = mb_cells{i, j};
                
                % For P-frames, compute residual with thresholding
                if ~is_iframe && ~isempty(prev_frame)
                    prev_mb = frame_to_mb(prev_frame);
                    residual = current_mb - prev_mb{i, j};
                    
                    % Debug before thresholding
                    if i == 1 && j == 1
                        fprintf('P-frame %d, Block (1,1) before threshold: min/max=%.2f/%.2f\n', ...
                                frame_idx, min(residual(:)), max(residual(:)));
                    end
                    
                    % Apply threshold to residuals (more selective thresholding)
                    % Only zero out very small values to preserve more detail
                    residual(abs(residual) < cfg.RESIDUAL_THRESHOLD) = 0;
                    current_mb = residual;
                    
                    % Debug for first block to verify residual calculation
                    if i == 1 && j == 1
                        fprintf('P-frame %d, Block (1,1) after threshold: min/max=%.2f/%.2f\n', ...
                                frame_idx, min(residual(:)), max(residual(:)));
                    end
                end
                
                % Apply DCT
                dct_mb = apply_dct(current_mb);
                
                % Quantize
                quantized_mb = quantize_block(dct_mb, q_mat);
                
                % Zigzag scan
                zigzag_vector = zigzag_scan(quantized_mb);
                
                % Run-length encoding
                rle_encoded = rle_encode(zigzag_vector);
                
                % Write encoded data
                for c = 1:3
                    channel_data = rle_encoded{c};
                    num_pairs = size(channel_data, 1);
                    
                    % Debug print for first block
                    if frame_idx == 1 && i == 1 && j == 1
                        fprintf('Frame 1, Block (1,1), Channel %d: %d pairs\n', c, num_pairs);
                        % Print first few pairs for debugging
                        if num_pairs > 0
                            fprintf('First pair: length=%d, value=%d\n', channel_data(1,1), channel_data(1,2));
                        end
                    end
                    
                    % Write number of pairs
                    fwrite(fid, num_pairs, 'uint16');
                    
                    % Write pairs
                    for k = 1:num_pairs
                        % Always write run length as uint16 for simplicity
                        fwrite(fid, channel_data(k, 1), 'uint16');
                        fwrite(fid, channel_data(k, 2), 'int8');
                    end
                end
            end
        end
        
        % Store current frame for next iteration
        if is_iframe
            prev_frame = current_frame;
        else
            % For P-frames, reconstruct the frame properly for reference
            reconstructed_frame = prev_frame;
            
            % Properly reconstruct by adding residuals
            for i = 1:mb_rows
                for j = 1:mb_cols
                    row_start = (i-1)*8 + 1;
                    row_end = i*8;
                    col_start = (j-1)*8 + 1;
                    col_end = j*8;
                    
                    % Extract the residual from mb_cells
                    residual_block = mb_cells{i, j};
                    
                    % Add residual to the reference block
                    reconstructed_frame(row_start:row_end, col_start:col_end, :) = ...
                        reconstructed_frame(row_start:row_end, col_start:col_end, :) + residual_block;
                end
            end
            
            % Verify a sample block for debugging
            sample_i = 1; sample_j = 1;
            sample_residual = mb_cells{sample_i, sample_j};
            sample_prev = prev_frame((sample_i-1)*8+1:sample_i*8, (sample_j-1)*8+1:sample_j*8, :);
            sample_recon = reconstructed_frame((sample_i-1)*8+1:sample_i*8, (sample_j-1)*8+1:sample_j*8, :);
            fprintf('P-frame %d verification: Residual min/max=%.2f/%.2f, Prev min/max=%.2f/%.2f, Recon min/max=%.2f/%.2f\n', ...
                    frame_idx, min(sample_residual(:)), max(sample_residual(:)), ...
                    min(sample_prev(:)), max(sample_prev(:)), ...
                    min(sample_recon(:)), max(sample_recon(:)));
            
            % Ensure values are in valid range
            reconstructed_frame = max(0, min(255, reconstructed_frame));
            prev_frame = reconstructed_frame;
        end
    end
    
    % Close file
    fclose(fid);
    
    % Display file size
    file_info = dir(output_file);
    file_size_mb = file_info.bytes / (1024 * 1024);
    fprintf('Compression complete. Output file size: %.2f MB\n', file_size_mb);
end 