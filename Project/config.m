function params = temp_config()
    params.GOP_SIZE = 2;
    params.RESIDUAL_THRESHOLD = 0;
    params.TEST_MODE = 1;
    params.TEST_FRAMES = 30;
    params.QUALITY_FACTOR = 3.0;
    params.FREQ_WEIGHT_FACTOR = 0.6;
    params.DC_SCALE_FACTOR = 0.6;
    params.DC_BLOCK_SIZE = 3;
    params.USE_MEDIAN_FILTER = 1;
    params.MEDIAN_FILTER_SIZE = [3, 3];
    params.USE_SHARPENING = 0;
    params.SHARPENING_STRENGTH = 0.2;
    params.ENHANCE_AFTER_FRAME = 2;
    params.FORCE_I_FRAMES = [];
end
