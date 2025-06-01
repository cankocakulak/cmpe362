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
    
    % Apply a simple quality scaling
    % For quality focus, use a factor slightly less than 1
    % to preserve more detail
    q_matrix = base_matrix * 5.0;  % More aggressive quantization
end 