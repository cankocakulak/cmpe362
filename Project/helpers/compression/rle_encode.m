function encoded = rle_encode(vector)
    % Apply RLE for each color channel
    encoded = cell(1, 3);
    
    % Get configuration for p-frame enhancement
    try
        cfg = config();
        enhance_zeros = cfg.ENHANCE_P_FRAME_ZEROS;
    catch
        enhance_zeros = false;
    end
    
    for c = 1:3
        channel_vector = vector(:, c);
        channel_encoded = [];
        
        % Pre-scan for enhanced zero run optimization
        if enhance_zeros
            % For P-frames, consider merging very small values into zero runs
            % This helps create longer zero runs for better compression
            for i = 2:length(channel_vector)-1
                % If surrounded by zeros and very small, make it zero too
                if channel_vector(i-1) == 0 && channel_vector(i+1) == 0 && abs(channel_vector(i)) <= 2
                    channel_vector(i) = 0;
                end
            end
        end
        
        i = 1;
        while i <= length(channel_vector)
            current_val = channel_vector(i);
            
            % Special handling for zero runs
            if current_val == 0
                % Count consecutive zeros
                run_length = 0;
                while i + run_length <= length(channel_vector) && channel_vector(i + run_length) == 0
                    run_length = run_length + 1;
                end
                
                % Only store non-zero run lengths
                if run_length > 0
                    channel_encoded = [channel_encoded; run_length, 0];
                end
                
                i = i + run_length;
            else
                % For non-zero values, store value and count consecutive same values
                run_length = 1;
                
                % Special handling for very small values if we're enhancing zeros
                if enhance_zeros && abs(current_val) <= 1 && i < length(channel_vector)-1
                    % If only a single small value between zeros, better to keep it
                    % as a separate value rather than breaking a potential zero run
                    if i > 1 && i < length(channel_vector) && ...
                       channel_vector(i-1) == 0 && channel_vector(i+1) == 0
                        channel_encoded = [channel_encoded; 1, current_val];
                        i = i + 1;
                        continue;
                    end
                end
                
                % Regular RLE for non-zero values
                while i + run_length <= length(channel_vector) && ...
                      channel_vector(i + run_length) == current_val && ...
                      run_length < 65535  % Cap run length for uint16 storage
                    run_length = run_length + 1;
                end
                
                channel_encoded = [channel_encoded; run_length, current_val];
                i = i + run_length;
            end
        end
        
        % Further optimization: Merge adjacent zero runs
        % This can happen if we had isolated small values that were processed separately
        if size(channel_encoded, 1) > 1
            j = 1;
            while j < size(channel_encoded, 1)
                if channel_encoded(j, 2) == 0 && channel_encoded(j+1, 2) == 0
                    % Merge adjacent zero runs
                    channel_encoded(j, 1) = channel_encoded(j, 1) + channel_encoded(j+1, 1);
                    channel_encoded(j+1:end-1, :) = channel_encoded(j+2:end, :);
                    channel_encoded = channel_encoded(1:end-1, :);
                else
                    j = j + 1;
                end
            end
        end
        
        % Store final encoded data
        encoded{c} = channel_encoded;
    end
end 