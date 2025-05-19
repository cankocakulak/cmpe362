function quantized = quantize_block(dct_block, q_matrix)
    % Apply quantization for each color channel
    quantized = zeros(size(dct_block));
    for c = 1:3
        quantized(:,:,c) = round(dct_block(:,:,c) ./ q_matrix);
    end
end 