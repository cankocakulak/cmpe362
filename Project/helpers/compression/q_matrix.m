function q_matrix = q_matrix()
    % Load configuration
    cfg = config();
    
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
    
    % Apply quality factor from config
    quality_factor = cfg.QUALITY_FACTOR;
    
    % Adjust frequency weighting based on config
    [h, w] = size(base_matrix);
    freq_weight = ones(h, w);
    for i = 1:h
        for j = 1:w
            % Distance-based weighting according to config
            dc_dist = sqrt((i-1)^2 + (j-1)^2) / sqrt(2*(h-1)^2);
            freq_weight(i,j) = 1 + dc_dist * cfg.FREQ_WEIGHT_FACTOR;
        end
    end
    
    % Apply both quality factor and frequency weighting
    q_matrix = base_matrix .* freq_weight * quality_factor;
    
    % Apply special treatment to DC and low-frequency components
    block_size = cfg.DC_BLOCK_SIZE;
    q_matrix(1:block_size, 1:block_size) = q_matrix(1:block_size, 1:block_size) * cfg.DC_SCALE_FACTOR;
end 