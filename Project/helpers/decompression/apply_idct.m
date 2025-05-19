function block = apply_idct(dct_block)
    % Apply inverse DCT for each color channel
    block = zeros(size(dct_block));
    for c = 1:3
        block(:,:,c) = custom_idct2(dct_block(:,:,c));
    end
end

% Custom 2D IDCT implementation without using idct2
function idct_result = custom_idct2(dct_block)
    [M, N] = size(dct_block);
    idct_result = zeros(M, N);
    
    % Calculate inverse DCT
    for x = 0:M-1
        for y = 0:N-1
            sum_val = 0;
            for u = 0:M-1
                for v = 0:N-1
                    % Normalization factors
                    if u == 0
                        alpha_u = sqrt(1/M);
                    else
                        alpha_u = sqrt(2/M);
                    end
                    
                    if v == 0
                        alpha_v = sqrt(1/N);
                    else
                        alpha_v = sqrt(2/N);
                    end
                    
                    sum_val = sum_val + alpha_u * alpha_v * dct_block(u+1, v+1) * ...
                        cos((2*x+1)*u*pi/(2*M)) * cos((2*y+1)*v*pi/(2*N));
                end
            end
            
            idct_result(x+1, y+1) = sum_val;
        end
    end
end 