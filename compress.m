function compress()
    % Add helper directories to path
    addpath('./helpers/');
    addpath('./helpers/compression/');
    
    % Constants
    GOP_SIZE = 30;  % Increased from 15 to 30 for better compression
    
    % Setup
    input_dir = './video_data/';
    output_file = 'result.bin';
    
    % Get quantization matrix
    q_mat = q_matrix();
    
    % Get list of frame files
    frame_files = dir(fullfile(input_dir, 'frame*.jpg'));
    total_frames = length(frame_files);
    
    % Sort frame files by number
    frame_numbers = zeros(total_frames, 1);
    for i = 1:total_frames
        % Extract frame number from filename
        frame_name = frame_files(i).name;
        frame_numbers(i) = str2double(regexp(frame_name, '\d+', 'match'));
    end
    [~, sort_idx] = sort(frame_numbers);
    frame_files = frame_files(sort_idx);
    
    % Open output file
    fid = fopen(output_file, 'wb');
    
    % Write header
    fwrite(fid, GOP_SIZE, 'uint32');
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
        is_iframe = is_i_frame(frame_idx, GOP_SIZE);
        
        % Write frame type
        fwrite(fid, is_iframe, 'uint8');
        
        % Write number of macroblocks
        fwrite(fid, mb_rows * mb_cols, 'uint32');
        
        % Process each macroblock
        for i = 1:mb_rows
            for j = 1:mb_cols
                % Get current macroblock
                current_mb = mb_cells{i, j};
                
                % For P-frames, compute residual
                if ~is_iframe
                    prev_mb = frame_to_mb(prev_frame);
                    current_mb = current_mb - prev_mb{i, j};
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
                    
                    % Write number of pairs
                    fwrite(fid, num_pairs, 'uint32');
                    
                    % Write pairs
                    for k = 1:num_pairs
                        fwrite(fid, channel_data(k, 1), 'uint32');  % Run length
                        fwrite(fid, channel_data(k, 2), 'int16');   % Value
                    end
                end
            end
        end
        
        % Store current frame for next iteration
        if is_iframe
            prev_frame = current_frame;
        else
            % For P-frames, update the reference by adding the residual
            prev_frame = prev_frame + mb_to_frame(mb_cells);
        end
    end
    
    % Close file
    fclose(fid);
    
    % Display file size
    file_info = dir(output_file);
    file_size_mb = file_info.bytes / (1024 * 1024);
    fprintf('Compression complete. Output file size: %.2f MB\n', file_size_mb);
end 