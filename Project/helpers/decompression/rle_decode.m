function decoded = rle_decode(encoded, vector_length)
    % Initialize result vector
    decoded = zeros(vector_length, 3);
    
    % Apply RLE decoding for each color channel
    for c = 1:3
        channel_encoded = encoded{c};
        channel_decoded = [];
        
        % Decode each (run_length, value) pair
        for i = 1:size(channel_encoded, 1)
            run_length = channel_encoded(i, 1);
            value = channel_encoded(i, 2);
            
            % Add repeated value to decoded data
            channel_decoded = [channel_decoded; repmat(value, run_length, 1)];
        end
        
        % Ensure vector is of correct length
        decoded(:, c) = channel_decoded(1:vector_length);
    end
end 