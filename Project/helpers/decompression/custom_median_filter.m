function output = custom_median_filter(input, window_size)
    % A simple implementation of median filtering without using medfilt2
    % Input: 2D image matrix
    % window_size: [height, width] of the filter window
    
    if nargin < 2
        window_size = [3, 3]; % Default 3x3 window
    end
    
    % Get image dimensions
    [rows, cols] = size(input);
    
    % Pad the image to handle borders
    h_pad = floor(window_size(1)/2);
    w_pad = floor(window_size(2)/2);
    
    % Create padded image with replicated borders
    padded = zeros(rows + 2*h_pad, cols + 2*w_pad);
    padded(h_pad+1:h_pad+rows, w_pad+1:w_pad+cols) = input;
    
    % Replicate border pixels for padding
    % Top and bottom padding
    for i = 1:h_pad
        padded(i, w_pad+1:w_pad+cols) = input(1, :);
        padded(h_pad+rows+i, w_pad+1:w_pad+cols) = input(rows, :);
    end
    
    % Left and right padding
    for j = 1:w_pad
        padded(h_pad+1:h_pad+rows, j) = input(:, 1);
        padded(h_pad+1:h_pad+rows, w_pad+cols+j) = input(:, cols);
    end
    
    % Corner padding
    padded(1:h_pad, 1:w_pad) = input(1, 1);
    padded(1:h_pad, w_pad+cols+1:end) = input(1, cols);
    padded(h_pad+rows+1:end, 1:w_pad) = input(rows, 1);
    padded(h_pad+rows+1:end, w_pad+cols+1:end) = input(rows, cols);
    
    % Initialize output
    output = zeros(rows, cols);
    
    % Apply median filter
    for i = 1:rows
        for j = 1:cols
            % Extract window
            window = padded(i:i+2*h_pad, j:j+2*w_pad);
            
            % Calculate median
            output(i, j) = median(window(:));
        end
    end
end 