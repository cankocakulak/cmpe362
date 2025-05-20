function encoded = rle_encode(vector)
    % Apply RLE for each color channel
    encoded = cell(1, 3);
    
    for c = 1:3
        channel_vector = vector(:, c);
        channel_encoded = [];
        
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
                while i + run_length <= length(channel_vector) && ...
                      channel_vector(i + run_length) == current_val && ...
                      run_length < 255  % Cap run length for uint8 storage
                    run_length = run_length + 1;
                end
                
                channel_encoded = [channel_encoded; run_length, current_val];
                i = i + run_length;
            end
        end
        
        % Further compression: if the tail is all zeros, we can just store the length
        if ~isempty(channel_encoded) && channel_encoded(end, 2) == 0
            encoded{c} = channel_encoded;
        else
            % If there are non-zero values at the end, make sure to include them
            encoded{c} = channel_encoded;
        end
    end
end 