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
    
    % Debug: Print quantization matrix
    fprintf('Quantization Matrix:\n');
    disp(q_mat(1:4,1:4));  % Show top-left corner
    
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
    prev_frame = [];
    
    for frame_idx = 1:total_frames
        % Display progress
        fprintf('\n==== Processing frame %d / %d ====\n', frame_idx, total_frames);
        
        % Read current frame
        frame_path = fullfile(input_dir, frame_files(frame_idx).name);
        current_frame = double(imread(frame_path));
        
        % Debug: Print frame statistics
        fprintf('Frame %d stats - Min: %.2f, Max: %.2f, Mean: %.2f\n', ...
                frame_idx, min(current_frame(:)), max(current_frame(:)), mean(current_frame(:)));
        
        % Convert frame to macroblocks
        mb_cells = frame_to_mb(current_frame);
        [mb_rows, mb_cols] = size(mb_cells);
        
        % Determine frame type
        is_iframe = is_i_frame(frame_idx, cfg.GOP_SIZE);
        fprintf('Frame %d is %s\n', frame_idx, conditional(is_iframe, 'I-frame', 'P-frame'));
        
        % Write frame type
        fwrite(fid, is_iframe, 'uint8');
        fwrite(fid, mb_rows * mb_cols, 'uint16');
        
        % Process each macroblock
        for i = 1:mb_rows
            for j = 1:mb_cols
                current_mb = mb_cells{i, j};
                
                if ~is_iframe && ~isempty(prev_frame)
                    % Debug P-frame processing
                    if i == 1 && j == 1
                        fprintf('\nProcessing first macroblock of P-frame %d:\n', frame_idx);
                        fprintf('Original block stats - Min: %.2f, Max: %.2f\n', ...
                                min(current_mb(:)), max(current_mb(:)));
                    end
                    
                    % Get previous frame block
                    prev_mb = frame_to_mb(prev_frame);
                    prev_block = prev_mb{i, j};
                    
                    % Debug previous block
                    if i == 1 && j == 1
                        fprintf('Previous block stats - Min: %.2f, Max: %.2f\n', ...
                                min(prev_block(:)), max(prev_block(:)));
                    end
                    
                    % Compute residual
                    residual = current_mb - prev_block;
                    
                    % Debug residual before threshold
                    if i == 1 && j == 1
                        fprintf('Residual before threshold - Min: %.2f, Max: %.2f\n', ...
                                min(residual(:)), max(residual(:)));
                    
                        % Print a small section of the residual for visualization
                        fprintf('Sample residual values (top-left corner):\n');
                        disp(residual(1:4, 1:4, 1));  % Show red channel
                    end
                    
                    % For quality focus, use very minimal thresholding
                    residual(abs(residual) < 1) = 0;  % Only remove tiny noise
                    
                    % Store residual for processing
                    current_mb = residual;
                    
                    % Debug residual after threshold
                    if i == 1 && j == 1
                        fprintf('Residual after threshold - Min: %.2f, Max: %.2f\n', ...
                                min(current_mb(:)), max(current_mb(:)));
                    end
                end
                
                % Apply DCT
                dct_mb = apply_dct(current_mb);
                
                % Debug DCT output
                if i == 1 && j == 1
                    fprintf('DCT output stats - Min: %.2f, Max: %.2f\n', ...
                            min(dct_mb(:)), max(dct_mb(:)));
                end
                
                % Quantize with minimal quality loss
                quantized_mb = quantize_block(dct_mb, q_mat);
                
                % Debug quantization
                if i == 1 && j == 1
                    fprintf('Quantized output stats - Min: %.2f, Max: %.2f\n', ...
                            min(quantized_mb(:)), max(quantized_mb(:)));
                end
                
                % For P-frames, dequantize and inverse DCT to get actual residual
                if ~is_iframe && ~isempty(prev_frame)
                    % Dequantize
                    dequantized_mb = zeros(size(quantized_mb));
                    for c = 1:3
                        dequantized_mb(:,:,c) = quantized_mb(:,:,c) .* q_mat;
                    end
                    
                    % Inverse DCT to get actual residual
                    mb_cells{i, j} = apply_idct(dequantized_mb);
                    
                    if i == 1 && j == 1
                        fprintf('Dequantized residual stats - Min: %.2f, Max: %.2f\n', ...
                                min(mb_cells{i,j}(:)), max(mb_cells{i,j}(:)));
                    end
                else
                    % For I-frames, just store the quantized values
                    mb_cells{i, j} = quantized_mb;
                end
                
                % Zigzag scan for storage
                zigzag_vector = zigzag_scan(quantized_mb);
                
                % Run-length encoding
                rle_encoded = rle_encode(zigzag_vector);
                
                % Write encoded data
                for c = 1:3
                    channel_data = rle_encoded{c};
                    num_pairs = size(channel_data, 1);
                    fwrite(fid, num_pairs, 'uint16');
                    
                    for k = 1:num_pairs
                        fwrite(fid, channel_data(k, 1), 'uint16');
                        fwrite(fid, channel_data(k, 2), 'int8');
                    end
                end
            end
        end
        
        % Update reference frame
        if is_iframe
            prev_frame = current_frame;
            fprintf('Stored I-frame as reference\n');
        else
            % For P-frames, reconstruct the frame for next reference
            reconstructed_frame = prev_frame;
            
            % Debug reconstruction process
            fprintf('\nReconstructing P-frame %d:\n', frame_idx);
            fprintf('Previous frame stats - Min: %.2f, Max: %.2f\n', ...
                    min(prev_frame(:)), max(prev_frame(:)));
            
            % Reconstruct frame by adding residuals
            for i = 1:mb_rows
                for j = 1:mb_cols
                    row_start = (i-1)*8 + 1;
                    row_end = i*8;
                    col_start = (j-1)*8 + 1;
                    col_end = j*8;
                    
                    residual_block = mb_cells{i, j};
                    
                    if i == 1 && j == 1
                        fprintf('Sample residual block stats - Min: %.2f, Max: %.2f\n', ...
                                min(residual_block(:)), max(residual_block(:)));
                    end
                    
                    % Add residual to reference block
                    reconstructed_block = reconstructed_frame(row_start:row_end, col_start:col_end, :);
                    reconstructed_block = reconstructed_block + residual_block;
                    
                    % Clamp values at block level before storing
                    reconstructed_block = max(0, min(255, reconstructed_block));
                    reconstructed_frame(row_start:row_end, col_start:col_end, :) = reconstructed_block;
                    
                    if i == 1 && j == 1
                        fprintf('Reconstructed block stats - Min: %.2f, Max: %.2f\n', ...
                                min(reconstructed_block(:)), max(reconstructed_block(:)));
                    end
                end
            end
            
            % Debug final reconstruction
            fprintf('Reconstructed frame stats - Min: %.2f, Max: %.2f\n', ...
                    min(reconstructed_frame(:)), max(reconstructed_frame(:)));
            
            % Store reconstructed frame as reference for next P-frame
            prev_frame = reconstructed_frame;
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