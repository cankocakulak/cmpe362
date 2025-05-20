function q_matrix = q_matrix()
    % Standard JPEG quantization matrix for good quality
    base_matrix = [
        16  11  10  16  24  40  51  61;
        12  12  14  19  26  58  60  55;
        14  13  16  24  40  57  69  56;
        14  17  22  29  51  87  80  62;
        18  22  37  56  68  109 103 77;
        24  35  55  64  81  104 113 92;
        49  64  78  87  103 121 120 101;
        72  92  95  98  112 100 103 99
    ];
    
    % Higher quality with lower quality factor
    quality_factor = 2.0;  % Significantly lowered from 5.0 for much better quality
    
    % Adjust frequency weighting to preserve more frequency details
    [h, w] = size(base_matrix);
    freq_weight = ones(h, w);
    for i = 1:h
        for j = 1:w
            % Much gentler weighting based on distance from DC
            dc_dist = sqrt((i-1)^2 + (j-1)^2) / sqrt(2*(h-1)^2);
            
            % Linear weighting with much less emphasis on high frequencies
            freq_weight(i,j) = 1 + dc_dist * 0.8;  % Reduced from 1.2
        end
    end
    
    % Apply both quality factor and frequency weighting
    q_matrix = base_matrix .* freq_weight * quality_factor;
    
    % Further reduce quantization for low frequencies (more important details)
    q_matrix(1:3, 1:3) = q_matrix(1:3, 1:3) * 0.5;  % Stronger preservation of important frequencies
end 