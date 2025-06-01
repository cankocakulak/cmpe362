# Video Compression Implementation

This directory contains two implementations of a video compression algorithm in MATLAB:
1. A basic implementation using I-frames and P-frames
2. An improved version with motion estimation and optimized quantization

## How to Run

### Basic Implementation
```matlab
>> compress                  % Compress video using basic implementation
>> decompress               % Decompress using basic implementation
```

### Improved Implementation
```matlab
>> improved_compress        % Compress video using motion estimation
>> improved_decompress     % Decompress using improved implementation
```

### Analysis
```matlab
>> analyze_compression     % Analyzes both implementations:
                         % - Compression ratios for different GOP sizes
                         % - PSNR comparison
                         % - Generates comparative plots
```

## Implementation Details

### Basic Implementation
- Uses simple P-frame prediction (co-located blocks)
- Quantization factor: 5.0x
- Standard entropy coding with RLE

### Improved Implementation
- Motion estimation with 7-pixel search range
- More aggressive quantization (8.0x)
- Optimized for better compression while maintaining quality
- Faster decompression due to simplified entropy coding

### Key Components (Both Versions)

1. **Macroblocks (8x8)**: All processing is done on 8x8 pixel blocks
2. **DCT Transform**: Converts pixels to frequency domain
3. **Quantization**: Reduces precision based on visual importance
4. **Zigzag Scan**: Orders coefficients from low to high frequency
5. **RLE**: Compresses sequences of repeated values

### Frame Types

1. **I-frames (Intra-coded)**: 
   - Encoded independently
   - Full information preserved
   - Serve as reference points

2. **P-frames (Predicted)**: 
   - Basic: Uses co-located blocks for prediction
   - Improved: Uses motion estimation to find best matching blocks
   - Much smaller than I-frames

## Tuning Parameters

1. **Global Configuration**: Modify `config.m` to change common parameters
   - GOP size
   - Frame dimensions
   - Macroblock size
   - Other shared configuration values

2. **GOP Size**: Modify in respective compression scripts
   - Recommended range: 1-30
   - Larger values = better compression but potential quality impact
   - Analysis shows diminishing returns after GOP size 15-20

3. **Quantization Settings**:
   - Basic: Modify `q_matrix.m`
   - Improved: Modify `q_matrix_improved.m`
   - Current settings:
     * Basic: 5.0x quantization factor
     * Improved: 8.0x quantization factor (enabled by better motion prediction)

4. **Motion Search Range** (Improved version only):
   - Set in `improved_compress.m`
   - Default: 7 pixels
   - Larger values may improve quality but increase compression time

## Performance Characteristics

1. **Compression Ratio**:
   - Basic: ~3:1 (GOP=1) to ~8.5:1 (GOP=30)
   - Improved: ~4.5:1 (GOP=1) to ~9.7:1 (GOP=30)

2. **PSNR Quality**:
   - Basic: ~34-34.5 dB
   - Improved: ~26-26.7 dB (lower due to aggressive quantization)

## Directory Structure

```
.
├── compress.m                  # Basic compression
├── decompress.m               # Basic decompression
├── improved_compress.m        # Improved compression with motion estimation
├── improved_decompress.m     # Improved decompression
├── analyze_compression.m     # Analysis script for both implementations
├── helpers/
│   ├── compression/
│   ├── decompression/
│   ├── analysis/
│   ├── q_matrix.m            # Basic quantization
│   └── q_matrix_improved.m   # Improved quantization
├── video_data/               # Input frames
├── decompressed/            # Output frames (basic)
└── decompressed_improved/   # Output frames (improved)
```

## Troubleshooting

1. **Path Issues**: Ensure MATLAB can find all functions:
   ```matlab
   >> addpath('./helpers/');
   >> addpath('./helpers/compression/');
   >> addpath('./helpers/decompression/');
   >> addpath('./helpers/analysis/');
   ```

2. **Memory Issues**: 
   - For large videos, use smaller frame subset
   - Reduce motion search range in improved version
   - Reduce GOP size

3. **Quality vs Compression**:
   - Basic: Adjust quantization factor in `q_matrix.m`
   - Improved: Adjust factor in `q_matrix_improved.m`
   - Modify GOP size in respective compression scripts