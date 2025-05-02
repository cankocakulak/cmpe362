# CMPE362 HW3: Noise Removal

This project implements modular FIR and IIR bandstop filters to remove cicada-like noise from an audio file. The codebase is organized for easy experimentation, comparison, and reporting.

## Project Structure

- `code/`: MATLAB scripts and filter design functions
  - `fir_bandstop_design.m`: Modular function for FIR bandstop filter design (takes order, f1, f2, fs)
  - `iir_filter_algorithms.m`: Modular function for IIR bandstop filter design (Butterworth, Chebyshev Type I, Elliptic)
  - `iir_vs_fir_filter_analysis.m`: Compares IIR filters (for various n) with the FIR filter and saves results under `results/comparison/`
  - `report_ideal_n.m`: Visualizes frequency response and pole-zero plots for your chosen stable n values
  - `report_unstable_n.m`: Visualizes frequency response and pole-zero plots for your chosen unstable n values
  - `apply_filters.m`: Applies all filters to the audio, generates filtered audio files and spectrograms (for stable n)
  - `apply_filters_unstable_n.m`: Same as above, but for unstable n values
- `results/`: Contains outputs (spectrograms, frequency responses, comparison plots, etc.)
- `sample.wav`: Original noisy audio file

## How to Run

1. **(Optional) Analyze the spectrogram to identify the noise frequencies:**
   ```matlab
   cd code
   spectrogram_analysis
   ```

2. **Compare IIR and FIR filters for various n:**
   ```matlab
   iir_vs_fir_filter_analysis
   ```
   - Results are saved under `../results/comparison/`

3. **Visualize frequency response and pole-zero plots for your chosen n values:**
   - For stable n:
     ```matlab
     report_ideal_n
     ```
   - For unstable n:
     ```matlab
     report_unstable_n
     ```

4. **Apply filters to the audio and generate filtered files and spectrograms:**
   - For stable n:
     ```matlab
     apply_filters
     ```
   - For unstable n:
     ```matlab
     apply_filters_unstable_n
     ```
   - Filtered audio is saved under `../filtered_audios/`, spectrograms under `../results/spectrograms/`

## Filter Design
- All FIR filter design is handled by `fir_bandstop_design.m` (no direct use of `fir1` in scripts)
- All IIR filter design is handled by `iir_filter_algorithms.m` (no direct use of `butter`, `cheby1`, or `ellip` in scripts)

## Troubleshooting
- If you encounter "Unrecognized function or variable" errors, ensure you're running the scripts from the `code/` directory.
- All filter design is now modular—no need to run a separate FIR design script or load coefficients from files.

## Outputs
- Filtered audio files: `filtered_audios/`
- Spectrograms and frequency response plots: `results/`
- Comparison plots for various n: `results/comparison/` 