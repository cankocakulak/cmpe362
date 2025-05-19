# Video Compression Implementation

This directory contains the implementation of a simple video compression algorithm in MATLAB. The algorithm is based on techniques similar to MPEG-4/H264, using I-frames and P-frames organized in a Group of Pictures (GOP) structure.

## How to Run

### Compression
```matlab
>> compress
```
This will:
1. Load video frames from the `video_data/` directory
2. Apply DCT, quantization, zigzag scanning, and RLE compression
3. Save the compressed data to `result.bin`

### Decompression
```matlab
>> decompress
```
This will:
1. Read the compressed data from `result.bin`
2. Perform the decompression process
3. Save the reconstructed frames to the `decompressed/` directory

### Analysis
```matlab
>> analyze_compression
```
This will:
1. Test different GOP sizes (1, 5, 10, 15, 20, 25, 30)
2. Calculate compression ratios and PSNR values
3. Generate plots comparing the performance

## Implementation Details

### Key Components

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
   - Encode only differences from previous frame
   - Much smaller than I-frames
   - Depend on previous frames for reconstruction

### GOP Structure

The Group of Pictures (GOP) structure defines how many P-frames follow each I-frame. A larger GOP size typically results in better compression but may reduce random access capability and error resilience.

## Tuning Parameters

1. **GOP Size**: Modify the `GOP_SIZE` variable in `compress.m`
   - Smaller values (e.g., 1): Higher quality, larger file size
   - Larger values (e.g., 30): Lower quality, smaller file size

2. **Quantization Matrix**: Modify `q_matrix.m` in the helpers directory
   - More aggressive quantization = higher compression, lower quality
   - Less aggressive quantization = lower compression, higher quality

## Directory Structure

```
.                               # Project root
├── compress.m                  # Main compression script
├── decompress.m                # Main decompression script
├── analyze_compression.m       # Performance analysis script
├── frame_to_mb.m               # Converts frames to macroblocks
├── mb_to_frame.m               # Converts macroblocks to frames
├── helpers/                    # Helper functions
│   ├── compression/            # Compression functions
│   ├── decompression/          # Decompression functions
│   ├── analysis/               # Analysis functions
│   └── q_matrix.m              # Quantization matrix
├── video_data/                 # Input video frames
└── decompressed/               # Output frames
```

## Troubleshooting

1. **Path Issues**: Ensure MATLAB can find all required functions by checking:
   ```matlab
   >> addpath('./helpers/');
   >> addpath('./helpers/compression/');
   >> addpath('./helpers/decompression/');
   >> addpath('./helpers/analysis/');
   ```

2. **Memory Issues**: For large videos, use a smaller subset of frames or reduce GOP size

3. **Compression Ratio**: If result file is too large, try:
   - Increasing GOP size
   - Using more aggressive quantization
   - Checking RLE implementation for efficiency 