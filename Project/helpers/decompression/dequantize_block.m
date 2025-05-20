function dequantized = dequantize_block(quantized_block, q_matrix)
    % Apply dequantization for each color channel
    dequantized = zeros(size(quantized_block));
    
    % Check if input is single-channel or multi-channel
    if ndims(quantized_block) == 2 || size(quantized_block, 3) == 1
        % Single channel case
        dequantized = quantized_block .* q_matrix;
    else
        % Multi-channel case
        for c = 1:size(quantized_block, 3)
            dequantized(:,:,c) = quantized_block(:,:,c) .* q_matrix;
        end
    end
end 