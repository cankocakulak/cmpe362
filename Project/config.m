function params = config()
    params.GOP_SIZE = 15;
    params.RESIDUAL_THRESHOLD = 0;
    params.TEST_MODE = 0;
    params.TEST_FRAMES = 5;
    params.QUALITY_FACTOR = 0.8;
    params.FREQ_WEIGHT_FACTOR = 0.2;
    params.DC_SCALE_FACTOR = 0.8;
    params.DC_BLOCK_SIZE = 3;
    params.USE_MEDIAN_FILTER = 0;
    params.MEDIAN_FILTER_SIZE = [3, 3];
    params.USE_SHARPENING = 0;
    params.SHARPENING_STRENGTH = 0.2;
    params.ENHANCE_AFTER_FRAME = 2;
    params.FORCE_I_FRAMES = [];
end
