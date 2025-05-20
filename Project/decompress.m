function decompress()
    % Add helper directories to path
    addpath('./helpers/');
    addpath('./helpers/compression/');
    addpath('./helpers/decompression/');
    
    % Constants (should match compression)
    output_dir = './decompressed/';
    input_file = 'result.bin';
    MAX_PAIRS = 64;  % Maximum possible pairs for one channel in 8x8 block
    
    % Create output directory if it doesn't exist
    if ~exist(output_dir, 'dir')
        mkdir(output_dir);
    end
    
    % Get quantization matrix
    q_mat = q_matrix();
    
    % Open input file
    fid = fopen(input_file, 'rb');
    
    % Read header
    GOP_SIZE = fread(fid, 1, 'uint32');
    total_frames = fread(fid, 1, 'uint32');
    width = fread(fid, 1, 'uint32');
    height = fread(fid, 1, 'uint32');
    
    % Validate header values
    if any([GOP_SIZE, total_frames, width, height] <= 0) || ...
       any([GOP_SIZE, total_frames, width, height] > 10000)  % reasonable max value
        error('Invalid header values: GOP_SIZE=%d, frames=%d, width=%d, height=%d', ...
              GOP_SIZE, total_frames, width, height);
    end
    
    fprintf('Header values: GOP_SIZE=%d, frames=%d, width=%d, height=%d\n', ...
            GOP_SIZE, total_frames, width, height);
    
    % Calculate macroblock dimensions
    mb_rows = height / 8;
    mb_cols = width / 8;
    expected_macroblocks = mb_rows * mb_cols;
    
    % Process each frame
    prev_frame = [];
    
    for frame_idx = 1:total_frames
        % Display progress
        fprintf('Decompressing frame %d / %d\n', frame_idx, total_frames);
        
        % Read frame type
        is_iframe = fread(fid, 1, 'uint8');
        if isempty(is_iframe)
            error('Unexpected end of file while reading frame type');
        end
        
        % Print frame type using proper MATLAB syntax for conditional text
        if is_iframe
            fprintf('Frame %d is I-frame\n', frame_idx);
        else
            fprintf('Frame %d is P-frame\n', frame_idx);
        end
        
        % Read number of macroblocks
        num_macroblocks = fread(fid, 1, 'uint16');
        if isempty(num_macroblocks) || num_macroblocks ~= expected_macroblocks
            error('Invalid number of macroblocks: expected %d, got %d', expected_macroblocks, num_macroblocks);
        end
        
        % Initialize macroblock array
        mb_cells = cell(mb_rows, mb_cols);
        
        % Process each macroblock
        for mb_idx = 1:num_macroblocks
            % Calculate macroblock position
            i = ceil(mb_idx / mb_cols);
            j = mod(mb_idx - 1, mb_cols) + 1;
            
            % Initialize decoded data
            decoded_mb = zeros(8, 8, 3);
            
            % Read and decode data for each color channel
            for c = 1:3
                % Read number of RLE pairs
                num_pairs = fread(fid, 1, 'uint16');
                
                % Debug print for first block
                if frame_idx == 1 && i == 1 && j == 1
                    fprintf('Reading Frame 1, Block (1,1), Channel %d: %d pairs\n', c, num_pairs);
                end
                
                if isempty(num_pairs) || num_pairs > MAX_PAIRS || num_pairs < 0
                    error('Invalid number of RLE pairs at frame %d, block %d, channel %d: %d', ...
                          frame_idx, mb_idx, c, num_pairs);
                end
                
                % Read pairs
                rle_data = zeros(num_pairs, 2);
                for k = 1:num_pairs
                    % Read run length and value
                    run_length = fread(fid, 1, 'uint16');
                    value = fread(fid, 1, 'int8');
                    
                    if isempty(run_length) || isempty(value)
                        error('Unexpected end of file while reading RLE data');
                    end
                    
                    rle_data(k, 1) = run_length;
                    rle_data(k, 2) = value;
                    
                    % Debug print first pair of first block
                    if frame_idx == 1 && i == 1 && j == 1 && k == 1
                        fprintf('First pair read: length=%d, value=%d\n', run_length, value);
                    end
                end
                
                % RLE decode
                zigzag_vector = zeros(64, 1);
                if ~isempty(rle_data)
                    zigzag_vector = rle_decode_single(rle_data, 64);
                end
                
                % Process each channel separately for better color fidelity
                % Inverse zigzag scan for this channel
                quantized_channel = inverse_zigzag(zigzag_vector, [8, 8, 1]);
                
                % Dequantize
                dequantized_channel = dequantize_block(quantized_channel, q_mat);
                
                % Inverse DCT
                decoded_mb(:,:,c) = apply_idct(dequantized_channel);
            end
            
            % For P-frames, add to previous frame
            if ~is_iframe && ~isempty(prev_frame)
                prev_mb = frame_to_mb(prev_frame);
                residual_mb = decoded_mb;  % Store the residual for debugging
                decoded_mb = decoded_mb + prev_mb{i, j};
                
                % Debug print for the first macroblock of problematic frames
                if i == 1 && j == 1
                    fprintf('P-frame %d, Block (1,1) residual range: min=%.2f, max=%.2f\n', ...
                           frame_idx, min(residual_mb(:)), max(residual_mb(:)));
                    fprintf('P-frame %d, Block (1,1) previous block range: min=%.2f, max=%.2f\n', ...
                           frame_idx, min(prev_mb{i,j}(:)), max(prev_mb{i,j}(:)));
                    fprintf('P-frame %d, Block (1,1) after adding: min=%.2f, max=%.2f\n', ...
                           frame_idx, min(decoded_mb(:)), max(decoded_mb(:)));
                end
                
                % Apply error correction to avoid drift and saturation
                decoded_mb = max(0, min(255, decoded_mb));
                
                % Apply custom filtering for P-frames to reduce artifacts (only if needed)
                if frame_idx > 2 && ~is_iframe
                    % Apply simple filtering to each channel to reduce noise
                    for c = 1:3
                        decoded_mb(:,:,c) = custom_median_filter(decoded_mb(:,:,c), [3 3]);
                    end
                end
            end
            
            % Store macroblock
            mb_cells{i, j} = decoded_mb;
        end
        
        % Convert macroblocks to frame
        current_frame = mb_to_frame(mb_cells);
        
        % Ensure values are in valid range (0-255)
        current_frame = max(0, min(255, current_frame));
        
        % For P-frames after frame 2, apply additional processing to improve quality
        if ~is_iframe && frame_idx > 2
            % Simple sharpening by adding weighted high-pass filtered version
            for c = 1:3
                channel = current_frame(:,:,c);
                % Create a simple sharpened version by adding Laplacian
                laplacian = zeros(size(channel));
                for i = 2:size(channel,1)-1
                    for j = 2:size(channel,2)-1
                        laplacian(i,j) = 4*channel(i,j) - channel(i-1,j) - channel(i+1,j) - channel(i,j-1) - channel(i,j+1);
                    end
                end
                % Add a scaled version of the Laplacian to enhance edges
                current_frame(:,:,c) = channel + 0.5*laplacian;
            end
            
            % Ensure values are in valid range again after filtering
            current_frame = max(0, min(255, current_frame));
        end
        
        % Save decompressed frame
        output_path = fullfile(output_dir, sprintf('frame%03d.jpg', frame_idx));
        imwrite(uint8(current_frame), output_path);
        
        % Update previous frame for next iteration
        % For proper P-frame reconstruction, we need to use current_frame as is
        % (no conditional logic based on frame type)
        prev_frame = current_frame;
        
        % Explicitly ensure we're within valid range
        prev_frame = max(0, min(255, prev_frame));
        
        % Print min/max values for debugging
        fprintf('Frame %d min/max values: %.2f/%.2f\n', frame_idx, min(current_frame(:)), max(current_frame(:)));
    end
    
    % Close file
    fclose(fid);
    
    fprintf('Decompression complete. %d frames saved to %s\n', total_frames, output_dir);
end 