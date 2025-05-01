# CMPE362 HW3: Noise Removal

This project implements FIR and IIR bandstop filters to remove cicada-like noise from an audio file.

## Project Structure

- `code/`: Contains MATLAB scripts
- `results/`: Contains outputs (spectrograms, frequency responses, etc.)
- `sample.wav`: Original noisy audio file

## How to Run

Follow these steps in MATLAB:

1. First, analyze the spectrogram to identify the noise frequencies:
   ```matlab
   cd code
   spectrogram_analysis
   ```

2. Next, design the FIR bandstop filter:
   ```matlab
   cd code
   fir_filter_design
   ```

3. Finally, analyze and compare different IIR filters:
   ```matlab
   cd code
   iir_filter_analysis
   ```

## Filter Types

The project compares:
- 256th-order FIR filter
- Butterworth IIR filters
- Chebyshev Type I IIR filters
- Elliptic IIR filters

Results are saved in the `results/` directory.

## Troubleshooting

If you encounter "Unrecognized function or variable" errors, ensure you're running the scripts from the `code/` directory. 