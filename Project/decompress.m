function decompress()
    % Add helper directories to path
    addpath('./helpers/');
    addpath('./helpers/compression/');
    addpath('./helpers/decompression/');
    
    % Constants (should match compression)
    output_dir = './decompressed/';
    input_file = 'result.bin';
    
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
    
    % Calculate macroblock dimensions
    mb_rows = height / 8;
    mb_cols = width / 8;
    
    % Process each frame
    prev_frame = [];
    
    for frame_idx = 1:total_frames
        % Display progress
        fprintf('Decompressing frame %d / %d\n', frame_idx, total_frames);
        
        % Read frame type
        is_iframe = fread(fid, 1, 'uint8');
        
        % Read number of macroblocks
        num_macroblocks = fread(fid, 1, 'uint32');
        
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
                num_pairs = fread(fid, 1, 'uint32');
                
                % Read pairs
                rle_data = zeros(num_pairs, 2);
                for k = 1:num_pairs
                    rle_data(k, 1) = fread(fid, 1, 'uint32');  % Run length
                    rle_data(k, 2) = fread(fid, 1, 'int16');   % Value
                end
                
                % RLE decode
                zigzag_vector = zeros(64, 3);
                zigzag_vector(:, c) = rle_decode_single(rle_data, 64);
                
                if c == 3
                    % Inverse zigzag scan
                    quantized_mb = inverse_zigzag(zigzag_vector);
                    
                    % Dequantize
                    dequantized_mb = dequantize_block(quantized_mb, q_mat);
                    
                    % Inverse DCT
                    decoded_mb = apply_idct(dequantized_mb);
                end
            end
            
            % For P-frames, add to previous frame
            if ~is_iframe && ~isempty(prev_frame)
                prev_mb = frame_to_mb(prev_frame);
                decoded_mb = decoded_mb + prev_mb{i, j};
            end
            
            % Store macroblock
            mb_cells{i, j} = decoded_mb;
        end
        
        % Convert macroblocks to frame
        current_frame = mb_to_frame(mb_cells);
        
        % Ensure values are in valid range (0-255)
        current_frame = max(0, min(255, current_frame));
        
        % Save decompressed frame
        output_path = fullfile(output_dir, sprintf('frame%03d.jpg', frame_idx));
        imwrite(uint8(current_frame), output_path);
        
        % Update previous frame
        prev_frame = current_frame;
    end
    
    % Close file
    fclose(fid);
    
    fprintf('Decompression complete. %d frames saved to %s\n', total_frames, output_dir);
end 