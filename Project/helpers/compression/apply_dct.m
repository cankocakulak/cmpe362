function dct_block = apply_dct(block)
    % Apply DCT for each color channel
    dct_block = zeros(size(block));
    for c = 1:3
        dct_block(:,:,c) = custom_dct2(block(:,:,c));
    end
end

% Custom 2D DCT implementation without using dct2
function dct_result = custom_dct2(input_block)
    [M, N] = size(input_block);
    dct_result = zeros(M, N);
    
    % 1D DCT basis functions
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
            
            % Calculate DCT coefficient
            sum_val = 0;
            for x = 0:M-1
                for y = 0:N-1
                    sum_val = sum_val + input_block(x+1, y+1) * ...
                        cos((2*x+1)*u*pi/(2*M)) * cos((2*y+1)*v*pi/(2*N));
                end
            end
            
            dct_result(u+1, v+1) = alpha_u * alpha_v * sum_val;
        end
    end
end 