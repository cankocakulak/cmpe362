function decoded = rle_decode_single(encoded, vector_length)
    % Decode a single channel of RLE data
    % Initialize result
    decoded = zeros(vector_length, 1);
    decoded_idx = 1;
    
    % Decode each (run_length, value) pair
    for i = 1:size(encoded, 1)
        run_length = encoded(i, 1);
        value = encoded(i, 2);
        
        % Fill in the repeated values
        for j = 1:run_length
            if decoded_idx <= vector_length
                decoded(decoded_idx) = value;
                decoded_idx = decoded_idx + 1;
            end
        end
    end
end 