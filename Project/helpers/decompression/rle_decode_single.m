function decoded = rle_decode_single(encoded, vector_length)
    % Decode a single channel of RLE data
    % Initialize result
    decoded = zeros(vector_length, 1);
    decoded_idx = 1;
    
    % Safety check for empty input
    if isempty(encoded)
        return;
    end
    
    % Decode each (run_length, value) pair
    for i = 1:size(encoded, 1)
        run_length = encoded(i, 1);
        value = encoded(i, 2);
        
        % Validate run length
        if run_length <= 0
            warning('Invalid run length %d at position %d, skipping', run_length, i);
            continue;
        end
        
        % Fill in the repeated values
        for j = 1:run_length
            if decoded_idx <= vector_length
                decoded(decoded_idx) = value;
                decoded_idx = decoded_idx + 1;
            else
                % We've reached the end of the vector
                warning('Decoded data exceeds vector length %d, truncating', vector_length);
                return;
            end
        end
    end
    
    % Check if we filled the entire vector
    if decoded_idx <= vector_length
        warning('Decoded data only filled %d out of %d positions', decoded_idx-1, vector_length);
    end
end 