function params = config()
    % ========================================================================
    % COMPREHENSIVE VIDEO COMPRESSION CONFIGURATION
    % 
    % This configuration file centralizes all parameters that control the 
    % compression behavior, quality, and performance. Modify these parameters
    % to experiment with different compression settings.
    % ========================================================================
    
    % ======== Compression Parameters ========
    
    % GOP (Group of Pictures) size: Controls I-frame frequency
    % RANGE: 1 to 30+ (integer)
    % EFFECT: Lower = better quality, larger file size
    %         Higher = smaller file size, potentially lower quality
    % NOTE: Value of 1 means all frames are I-frames (highest quality)
    params.GOP_SIZE = 30;
    
    % Residual threshold: Noise filter for P-frame differences
    % RANGE: 0 to 10 (integer)
    % EFFECT: 0 = keep all details (largest P-frames)
    %         3-5 = balanced (removes noise, keeps structure)
    %         10+ = aggressive filtering (smallest P-frames, potential artifacts)
    % NOTE: Higher values improve compression but may cause detail loss
    params.RESIDUAL_THRESHOLD = 0;  % Keep all details in residuals
    
    % Test mode: Process limited frames for faster testing
    % RANGE: true (1) or false (0)
    % EFFECT: true = process only TEST_FRAMES number of frames
    %         false = process all frames in directory
    params.TEST_MODE = false;
    
    % Number of frames to process in test mode
    % RANGE: 1 to total frame count (integer)
    % EFFECT: Only used when TEST_MODE = true
    params.TEST_FRAMES = 5;
    
    % Force specific frames to be I-frames
    % RANGE: Array of frame indices [1,3,5,...]
    % EFFECT: Ensures specific frames are encoded as full I-frames
    %         regardless of GOP structure
    % NOTE: Empty array [] means no forced I-frames
    params.FORCE_I_FRAMES = [];  % Disabled for GOP analysis
    
    % ======== Quantization Parameters ========
    
    % Quality factor for DCT coefficient quantization
    % RANGE: 0.5 to 10.0 (float)
    % EFFECT: Lower = better quality, larger files (0.5-2.0 is high quality)
    %         Higher = lower quality, smaller files (5.0+ is aggressive compression)
    % NOTE: This is the main quality control parameter
    params.QUALITY_FACTOR = 0.8;  % Much lower for high quality
    
    % Frequency weighting factor for quantization
    % RANGE: 0.1 to 2.0 (float)
    % EFFECT: Controls how aggressively high frequencies are compressed
    %         Lower = preserve more high-frequency detail
    %         Higher = more aggressive compression of high frequencies
    params.FREQ_WEIGHT_FACTOR = 0.2;  % Reduced significantly to preserve details
    
    % Special weighting for low-frequency (DC) components
    % RANGE: 0.1 to 1.0 (float)
    % EFFECT: Lower = better preserve important low frequencies
    %         Higher = more compression even in visually critical areas
    params.DC_SCALE_FACTOR = 0.8;  % Increased to maintain DC component fidelity
    
    % Size of low-frequency block to receive special treatment
    % RANGE: 1 to 8 (integer)
    % EFFECT: Controls how many low-frequency coefficients get special treatment
    %         Higher values preserve more of the basic structure
    params.DC_BLOCK_SIZE = 3;  % Back to original value
    
    % ======== P-Frame Parameters ========
    
    % P-frame quantization boost factor
    % RANGE: 1.0 to 2.0 (float)
    % EFFECT: Controls additional quantization for P-frames
    %         1.0 = same quantization as I-frames
    %         >1.0 = more aggressive quantization for P-frames
    % NOTE: Higher values create smaller P-frames but lower quality
    params.P_FRAME_QUANT_BOOST = 1.0;  % No extra quantization for P-frames
    
    % P-frame zero run enhancement
    % RANGE: true (1) or false (0)
    % EFFECT: When true, tries to create longer runs of zeros in P-frames
    %         to improve compression efficiency 
    params.ENHANCE_P_FRAME_ZEROS = false;  % Disable zero run enhancement
    
    % Maximum P-frames before refresh
    % RANGE: 1 to GOP_SIZE-1 (integer)
    % EFFECT: Forces an I-frame after this many P-frames, even within a GOP
    %         to prevent quality degradation
    % NOTE: Set to GOP_SIZE-1 to disable (normal GOP behavior)
    params.MAX_P_FRAMES_BEFORE_REFRESH = 5;  % More frequent refresh
    
    % ======== Enhancement Parameters ========
    
    % Apply median filtering to P-frames
    % RANGE: true (1) or false (0)
    % EFFECT: Smooths out noise in P-frames
    %         Can help with compression but may reduce details
    params.USE_MEDIAN_FILTER = false;  % Disable filtering to preserve details
    
    % Median filter window size
    % RANGE: [odd_number, odd_number], typically [3,3] or [5,5]
    % EFFECT: Larger values = more smoothing
    params.MEDIAN_FILTER_SIZE = [3, 3];
    
    % Apply sharpening to P-frames
    % RANGE: true (1) or false (0)
    % EFFECT: Enhances edges after decompression
    %         Can improve perceived quality but may amplify artifacts
    params.USE_SHARPENING = false;  % Disable sharpening
    
    % Sharpening strength
    % RANGE: 0.1 to 1.0 (float)
    % EFFECT: Controls how strong the sharpening effect is
    %         Higher values = more pronounced edges
    params.SHARPENING_STRENGTH = 0.2;
    
    % Minimum frame index to apply enhancements
    % RANGE: 1 to total frames (integer)
    % EFFECT: Only apply enhancements after this frame
    params.ENHANCE_AFTER_FRAME = 2;
end
