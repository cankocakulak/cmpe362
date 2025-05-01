# CMPE362 Assignment 3: Noise Removal using FIR and IIR Filters

## Project Overview
This project implements and compares different digital filters (FIR and IIR) for removing narrow-band noise from an audio signal. The implementation includes spectrogram analysis, filter design, and performance comparison.

## Directory Structure
```
CMPE362_HW3_NoiseRemoval/
│
├── 📂 code/
│   ├── spectrogram_analysis.m    # Analyze original audio spectrogram
│   ├── fir_filter_design.m       # Design FIR bandstop filter
│   ├── iir_filter_design.m       # Design IIR bandstop filters
│   ├── apply_filters.m           # Apply filters to audio
│   ├── instability_analysis.m    # Analyze IIR filter stability
│   └── utils.m                   # Helper functions
│
├── 📂 results/
│   ├── 📂 spectrograms/          # Spectrogram plots
│   ├── 📂 freq_responses/        # Frequency response plots
│   ├── 📂 pole_zero_plots/       # Pole-zero diagrams
│   └── 📂 filtered_audios/       # Filtered audio files
│
├── 📄 report.pdf                 # Project report
└── 📄 sample.wav                 # Input audio file
```

## Requirements
- MATLAB R2020b or later
- Signal Processing Toolbox
- Audio Toolbox

## Setup Instructions
1. Clone this repository
2. Place the `sample.wav` file in the root directory
3. Open MATLAB and navigate to the project directory
4. Run the scripts in the following order:
   - `spectrogram_analysis.m`
   - `fir_filter_design.m`
   - `iir_filter_design.m`
   - `apply_filters.m`
   - `instability_analysis.m`

## Script Descriptions
- `spectrogram_analysis.m`: Analyzes the original audio to identify the noise frequency band
- `fir_filter_design.m`: Designs a 256th-order FIR bandstop filter
- `iir_filter_design.m`: Designs Butterworth, Chebyshev Type I, and Elliptic bandstop filters
- `apply_filters.m`: Applies the designed filters to the audio file
- `instability_analysis.m`: Analyzes IIR filter stability with increasing orders
- `utils.m`: Contains helper functions for plotting and saving results

## Results
The results directory contains:
- Spectrograms of original and filtered audio
- Frequency response plots for all filters
- Pole-zero diagrams for IIR filters
- Filtered audio files in WAV format

## Author
[Your Name]

## Date
[Current Date] 