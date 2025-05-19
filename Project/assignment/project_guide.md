# Video Compression Project Guide

## 1. Project Overview
This project implements a video compression algorithm in MATLAB, similar to MPEG-4/H264 standards. The goal is to compress video frames while maintaining acceptable quality.

## 2. Key Concepts

### 2.1 Video Structure
- Input video: 480x360 resolution
- Frames are provided as .jpg images
- Each frame has 3 color channels (RGB)
- MATLAB's `imread` returns frames in (360, 480, 3) format as uint8

### 2.2 Core Compression Techniques

#### 2.2.1 Macroblocks
- Size: 8x8 pixels
- Frames are divided into non-overlapping macroblocks
- Helper functions provided:
  - `frame_to_mb.m`: Converts frame to macroblock cell array
  - `mb_to_frame.m`: Converts macroblock cell array back to frame

#### 2.2.2 Transform Coding
1. **DCT (Discrete Cosine Transform)**
   - Converts spatial data to frequency domain
   - MATLAB functions: `dct2` and `idct2`
   - Low frequencies (important) → top-left
   - High frequencies (less important) → bottom-right

2. **Quantization**
   - Reduces precision of DCT coefficients
   - Uses provided quantization matrix
   - Formula: Q(u,v) = round(C(u,v) / Qmat(u,v))

3. **Zigzag Scanning**
   - Converts 8x8 block to 1D vector
   - Orders coefficients from low to high frequency
   - Helps in RLE compression

4. **Run-Length Encoding (RLE)**
   - Compresses consecutive zeros
   - Format: (run_length, value) pairs
   - Example: [12, -3, 0, 0, 0, 5, 0, 0, 0, 0, -1] →
     [(1,12), (1,-3), (3,0), (1,5), (4,0), (1,-1)]

### 2.3 Frame Types

#### 2.3.1 I-Frames (Intra-coded)
- Compressed independently
- Processing steps:
  1. DCT on each macroblock
  2. Quantization
  3. Zigzag scan
  4. RLE encoding

#### 2.3.2 P-Frames (Predicted)
- Uses previous frame as reference
- Stores only differences (residuals)
- Processing steps:
  1. Calculate residual: R(i,j) = B(t)(i,j) - B(t-1)(i,j)
  2. DCT on residual
  3. Quantization
  4. Zigzag scan
  5. RLE encoding

#### 2.3.3 GOP (Group of Pictures)
- Structure: I-frame followed by P-frames
- Example GOP size 5: I P P P P
- Affects:
  - Compression ratio
  - Error propagation
  - Random access capability

## 3. Implementation Steps

### 3.1 Part 1: Basic Implementation

1. **Setup**
   - Create `compress.m` and `decompress.m`
   - Define GOP size constant
   - Set up input/output paths

2. **Compression Pipeline**
   ```
   Input Frames → Macroblocks → DCT → Quantization → Zigzag → RLE → Binary Output
   ```

3. **Decompression Pipeline**
   ```
   Binary Input → RLE Decode → Inverse Zigzag → Dequantization → IDCT → Macroblocks → Output Frames
   ```

4. **Analysis**
   - Calculate compression ratios for GOP sizes 1-30
   - Compute PSNR for GOP sizes 1, 15, and 30
   - Generate comparison plots

### 3.2 Part 2: Improvements

Choose one of:
1. **Motion Estimation**
   - Implement Block Matching Algorithm
   - Improve P-frame compression

2. **B-Frames Implementation**
   - Add bidirectional prediction
   - Experiment with different GOP structures
   - Test various quantization matrices

## 4. Important Notes

1. **Data Types**
   - Convert uint8 to double for processing
   - Convert back to uint8 for final output

2. **Performance Targets**
   - Target compression: ~7.8MB for GOP size 30
   - Original data size: ~62MB (480 × 360 × 24 × 120 bits)

3. **File Organization**
   - Input: `./video_data/`
   - Output: `./decompressed/`
   - Compressed data: `result.bin`

## 5. Deliverables

### 5.1 Part 1 (60 points)
- Working compression/decompression code
- Compression ratio analysis
- PSNR analysis
- Implementation report

### 5.2 Part 2 (40 points)
- Improved algorithm implementation
- Performance comparison with Part 1
- Analysis of improvements
- Implementation report

## 6. Next Steps
1. Review the provided helper functions
2. Set up the basic project structure
3. Implement the basic compression pipeline
4. Test with sample frames
5. Implement improvements
6. Generate analysis and reports 