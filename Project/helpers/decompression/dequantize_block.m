function dequantized = dequantize_block(quantized_block, q_matrix)
    % Apply dequantization for each color channel
    dequantized = zeros(size(quantized_block));
    for c = 1:3
        dequantized(:,:,c) = quantized_block(:,:,c) .* q_matrix;
    end
end 