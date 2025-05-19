function encoded = rle_encode(vector)
    % Apply RLE for each color channel
    encoded = cell(1, 3);
    
    for c = 1:3
        channel_vector = vector(:, c);
        channel_encoded = [];
        
        % Optimize for cases with many zeros
        i = 1;
        while i <= length(channel_vector)
            current_val = channel_vector(i);
            
            % Count run length
            run_length = 1;
            while i + run_length <= length(channel_vector) && channel_vector(i + run_length) == current_val
                run_length = run_length + 1;
            end
            
            % Add to encoded data
            % For long runs of zeros, this is particularly efficient
            channel_encoded = [channel_encoded; run_length, current_val];
            
            % Move to next value
            i = i + run_length;
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