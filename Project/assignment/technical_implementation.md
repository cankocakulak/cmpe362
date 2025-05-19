# Technical Implementation Guide

## 1. MATLAB-Specific Considerations

### 1.1 Data Types and Conversions
```matlab
% Reading images
frame = imread('frame.jpg');  % Returns uint8 (360, 480, 3)
frame_double = double(frame); % Convert to double for processing

% Final output
output_frame = uint8(processed_frame); % Convert back to uint8
```

### 1.2 Macroblocks Handling
```matlab
% Using provided helper functions
mb_cells = frame_to_mb(frame);  % Returns (45, 60) cell array
% Each cell contains (8, 8, 3) double array

% Processing a single macroblock
mb = mb_cells{i,j};  % Get macroblock at position (i,j)
```

### 1.3 DCT Operations
```matlab
% Forward DCT
dct_coeffs = dct2(mb);  % 2D DCT on macroblock

% Inverse DCT
reconstructed_mb = idct2(dct_coeffs);
```

## 2. Code Structure

### 2.1 compress.m
```matlab
function compress()
    % Constants
    GOP_SIZE = 30;  % Configurable
    
    % Setup
    input_dir = './video_data/';
    output_file = 'result.bin';
    
    % Main compression loop
    for frame_idx = 1:total_frames
        if is_i_frame(frame_idx, GOP_SIZE)
            compress_i_frame();
        else
            compress_p_frame();
        end
    end
end

function compress_i_frame()
    % 1. Read frame
    % 2. Convert to macroblocks
    % 3. For each macroblock:
    %    - DCT
    %    - Quantize
    %    - Zigzag scan
    %    - RLE encode
    % 4. Write to binary
end

function compress_p_frame()
    % 1. Read current and previous frame
    % 2. Convert to macroblocks
    % 3. For each macroblock:
    %    - Calculate residual
    %    - DCT
    %    - Quantize
    %    - Zigzag scan
    %    - RLE encode
    % 4. Write to binary
end
```

### 2.2 decompress.m
```matlab
function decompress()
    % Constants
    GOP_SIZE = 30;  % Must match compression
    
    % Setup
    input_file = 'result.bin';
    output_dir = './decompressed/';
    
    % Main decompression loop
    for frame_idx = 1:total_frames
        if is_i_frame(frame_idx, GOP_SIZE)
            decompress_i_frame();
        else
            decompress_p_frame();
        end
    end
end

function decompress_i_frame()
    % 1. Read from binary
    % 2. For each macroblock:
    %    - RLE decode
    %    - Inverse zigzag
    %    - Dequantize
    %    - Inverse DCT
    % 3. Convert macroblocks to frame
    % 4. Save frame
end

function decompress_p_frame()
    % 1. Read from binary
    % 2. For each macroblock:
    %    - RLE decode
    %    - Inverse zigzag
    %    - Dequantize
    %    - Inverse DCT
    %    - Add to previous frame
    % 3. Convert macroblocks to frame
    % 4. Save frame
end
```

## 3. Helper Functions

### 3.1 Quantization
```matlab
function quantized = quantize_block(dct_block, q_matrix)
    % Element-wise division and rounding
    quantized = round(dct_block ./ q_matrix);
end

function dequantized = dequantize_block(quantized_block, q_matrix)
    % Element-wise multiplication
    dequantized = quantized_block .* q_matrix;
end
```

### 3.2 Zigzag Scanning
```matlab
function vector = zigzag_scan(block)
    % Implement zigzag scanning pattern
    % Returns 1D vector
end

function block = inverse_zigzag(vector)
    % Reconstruct 8x8 block from zigzag vector
end
```

### 3.3 RLE Encoding/Decoding
```matlab
function encoded = rle_encode(vector)
    % Convert vector to (run_length, value) pairs
end

function decoded = rle_decode(encoded)
    % Reconstruct original vector from RLE pairs
end
```

## 4. Binary File Format

### 4.1 Header Structure
```
[GOP_SIZE (uint32)]
[Total Frames (uint32)]
[Frame Width (uint32)]
[Frame Height (uint32)]
```

### 4.2 Frame Data Structure
```
[Frame Type (uint8)]  % 0 for I-frame, 1 for P-frame
[Number of Macroblocks (uint32)]
For each macroblock:
    [RLE Encoded Data]
```

## 5. Performance Optimization Tips

1. **Pre-allocation**
   ```matlab
   % Pre-allocate arrays for better performance
   mb_cells = cell(45, 60);
   ```

2. **Vectorization**
   ```matlab
   % Use vectorized operations instead of loops where possible
   quantized = round(dct_blocks ./ q_matrix);
   ```

3. **Memory Management**
   ```matlab
   % Clear large variables when no longer needed
   clear frame_double;
   ```

## 6. Testing and Validation

### 6.1 Basic Tests
```matlab
% Test DCT/IDCT
test_block = rand(8,8);
reconstructed = idct2(dct2(test_block));
assert(norm(test_block - reconstructed) < 1e-10);

% Test Quantization
q_matrix = load('quantizationMatrix.png');
quantized = quantize_block(dct2(test_block), q_matrix);
dequantized = dequantize_block(quantized, q_matrix);
```

### 6.2 Performance Tests
```matlab
% Measure compression ratio
original_size = 480 * 360 * 24 * 120;  % bits
compressed_size = get_file_size('result.bin') * 8;  % bits
compression_ratio = original_size / compressed_size;

% Calculate PSNR
psnr_value = psnr(original_frame, decompressed_frame);
``` 