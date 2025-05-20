Compression Parameters

GOP_SIZE: Controls how frequently I-frames occur (smaller = more I-frames = better quality but larger files)
RESIDUAL_THRESHOLD: Determines how aggressively small changes are filtered out (higher = more compression but more artifacts)
TEST_MODE and TEST_FRAMES: Controls test environment (processing fewer frames)
FORCE_I_FRAMES: Specific frames to encode as I-frames regardless of the GOP pattern
Quantization Parameters
QUALITY_FACTOR: The main quality control (lower = better quality, larger files)
FREQ_WEIGHT_FACTOR: Controls how aggressively high frequencies are compressed
DC_SCALE_FACTOR: Special treatment for the most important visual information
DC_BLOCK_SIZE: Size of the "important" frequency region
Enhancement Parameters
USE_MEDIAN_FILTER: Toggle median filtering for noise reduction
MEDIAN_FILTER_SIZE: Control the strength of noise filtering
USE_SHARPENING: Toggle sharpening enhancement
SHARPENING_STRENGTH: Control how strong the sharpening effect is
ENHANCE_AFTER_FRAME: When to start applying enhancements
By adjusting these parameters, you have comprehensive control over the compression system. For example:
For maximum quality: Set GOP_SIZE=1, QUALITY_FACTOR=1.0, RESIDUAL_THRESHOLD=0
For balanced quality/size: Current settings are good
For maximum compression: Set GOP_SIZE=5, QUALITY_FACTOR=5.0, RESIDUAL_THRESHOLD=3
A good strategy for experimentation is to change one parameter at a time and observe the effect on both file size and visual quality.