function psnr_value = calculate_psnr(original, compressed)
    % Convert to double if not already
    original = double(original);
    compressed = double(compressed);
    
    % Calculate MSE
    mse = mean((original(:) - compressed(:)).^2);
    
    % Calculate PSNR
    if mse == 0
        psnr_value = Inf;
    else
        psnr_value = 10 * log10(255^2 / mse);
    end
end 