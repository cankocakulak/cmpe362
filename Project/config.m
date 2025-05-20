function params = config()
    % Central configuration file for video compression parameters
    % Edit this file to change compression behavior without modifying multiple files
    
    % ======== Compression Parameters ========
    % GOP (Group of Pictures) size: how many frames between I-frames
    % Lower = better quality, larger file size (1 = all I-frames)
    params.GOP_SIZE = 2;
    
    % Residual threshold: small values below this are set to zero
    % Higher = more compression, lower quality (0 = keep all details)
    params.RESIDUAL_THRESHOLD = 0;
    
    % Test mode: limit the number of frames processed
    % Set to true for faster testing with fewer frames
    params.TEST_MODE = false;
    
    % Number of frames to process in test mode
    params.TEST_FRAMES = 10;
    
    % Force specific frames to be I-frames (regardless of GOP)
    % Format: [3, 5, 9] means frames 3,5,9 will be forced as I-frames
    params.FORCE_I_FRAMES = [3, 5, 7, 9];
    
    % ======== Quantization Parameters ========
    % Quality factor for quantization (higher = more compression, lower quality)
    % Range: 0.5 (high quality) to 10.0 (low quality, high compression)
    params.QUALITY_FACTOR = 3.0;
    
    % Frequency weighting factor (higher = more compression of high frequencies)
    params.FREQ_WEIGHT_FACTOR = 0.6;
    
    % Special weighting for low-frequency components (0-1, lower = better quality)
    params.DC_SCALE_FACTOR = 0.6;
    
    % Size of low-frequency block to get special treatment
    params.DC_BLOCK_SIZE = 3;
    
    % ======== Enhancement Parameters ========
    % Apply median filtering to P-frames (true/false)
    params.USE_MEDIAN_FILTER = true;
    
    % Median filter window size
    params.MEDIAN_FILTER_SIZE = [3, 3];
    
    % Apply sharpening to P-frames (true/false)
    params.USE_SHARPENING = false;
    
    % Sharpening strength (0-1)
    params.SHARPENING_STRENGTH = 0.2;
    
    % Minimum frame index to apply enhancements
    params.ENHANCE_AFTER_FRAME = 2;
end 