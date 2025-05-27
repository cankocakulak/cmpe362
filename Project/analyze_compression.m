function analyze_compression()
    % Script to analyze compression ratio and PSNR for different GOP sizes
    
    % Add helper directories to path
    addpath('./helpers/');
    addpath('./helpers/compression/');
    addpath('./helpers/decompression/');
    
    % Setup
    input_dir = './video_data/';
    output_dir = './decompressed/';
    
    % Get list of frame files to calculate uncompressed size
    frame_files = dir(fullfile(input_dir, 'frame*.jpg'));
    total_frames = length(frame_files);
    
    % Sample a frame to get dimensions
    sample_frame = imread(fullfile(input_dir, frame_files(1).name));
    [height, width, channels] = size(sample_frame);
    
    % Calculate uncompressed size (in bits)
    uncompressed_size = width * height * 3 * 8 * total_frames;  % 24 bits per pixel
    fprintf('Uncompressed size: %.2f MB (%d bits)\n', uncompressed_size/(8*1024*1024), uncompressed_size);
    
    % GOP sizes to test
    gop_sizes = [1, 2, 3, 5, 10, 15, 20, 30];
    
    % Arrays to store results
    compression_ratios = zeros(size(gop_sizes));
    file_sizes_mb = zeros(size(gop_sizes));
    
    % PSNR analysis for specific GOP sizes
    psnr_gop_sizes = [1, 15, 30];
    psnr_values = cell(length(psnr_gop_sizes), 1);
    
    % Save original config
    orig_config = config();
    
    % Main analysis loop
    for i = 1:length(gop_sizes)
        gop_size = gop_sizes(i);
        fprintf('\nAnalyzing GOP size %d...\n', gop_size);
        
        % Create new config with current GOP size
        cfg = orig_config;
        cfg.GOP_SIZE = gop_size;
        cfg.TEST_MODE = false;  % Use all frames
        cfg.FORCE_I_FRAMES = [];  % Don't force any I-frames
        
        % Save the updated configuration
        save_config(cfg);
        
        % Clear any cached config
        clear('config');
        
        % Run compression
        compress();
        
        % Measure compressed file size
        file_info = dir('result.bin');
        compressed_size = file_info.bytes * 8;  % Convert bytes to bits
        file_sizes_mb(i) = compressed_size / (8*1024*1024);  % Convert bits to MB
        
        % Calculate compression ratio
        compression_ratios(i) = uncompressed_size / compressed_size;
        
        % For specific GOP sizes, calculate PSNR
        if ismember(gop_size, psnr_gop_sizes)
            % Run decompression
            decompress();
            
            % Calculate PSNR
            psnr_idx = find(psnr_gop_sizes == gop_size);
            psnr_values{psnr_idx} = calculate_psnr(input_dir, output_dir, total_frames);
            
            % Save PSNR results to file
            save(sprintf('psnr_gop_%d.mat', gop_size), 'psnr_values');
        end
        
        % Clear the cached config again before next iteration
        clear('config');
    end
    
    % Save compression ratio results
    save('compression_results.mat', 'gop_sizes', 'compression_ratios', 'file_sizes_mb');
    
    % Plot compression ratio vs GOP size
    figure;
    plot(gop_sizes, compression_ratios, 'o-', 'LineWidth', 2);
    title('Compression Ratio vs GOP Size');
    xlabel('GOP Size');
    ylabel('Compression Ratio');
    grid on;
    saveas(gcf, 'compression_ratio_plot.png');
    
    % Plot PSNR curves
    figure;
    colors = {'r', 'g', 'b'};
    legends = {};
    
    hold on;
    for i = 1:length(psnr_gop_sizes)
        plot(1:length(psnr_values{i}), psnr_values{i}, [colors{i}, '-o'], 'LineWidth', 2);
        legends{i} = sprintf('GOP = %d', psnr_gop_sizes(i));
    end
    hold off;
    
    title('PSNR vs Frame Number for Different GOP Sizes');
    xlabel('Frame Number');
    ylabel('PSNR (dB)');
    legend(legends);
    grid on;
    saveas(gcf, 'psnr_plot.png');
    
    % Restore original configuration
    save_config(orig_config);
    
    % Print results
    fprintf('\nCompression Analysis Results:\n');
    fprintf('----------------------------\n');
    fprintf('GOP Size | Compression Ratio | File Size (MB)\n');
    for i = 1:length(gop_sizes)
        fprintf('%7d | %18.2f | %13.2f\n', gop_sizes(i), compression_ratios(i), file_sizes_mb(i));
    end
end

function save_config(cfg)
    % Create a temporary function to save the updated configuration
    fid = fopen('config.m', 'w');
    
    fprintf(fid, 'function params = config()\n');  % Changed function name to match file
    fprintf(fid, '    params.GOP_SIZE = %d;\n', cfg.GOP_SIZE);
    fprintf(fid, '    params.RESIDUAL_THRESHOLD = %d;\n', cfg.RESIDUAL_THRESHOLD);
    fprintf(fid, '    params.TEST_MODE = %d;\n', cfg.TEST_MODE);
    fprintf(fid, '    params.TEST_FRAMES = %d;\n', cfg.TEST_FRAMES);
    fprintf(fid, '    params.QUALITY_FACTOR = %.1f;\n', cfg.QUALITY_FACTOR);
    fprintf(fid, '    params.FREQ_WEIGHT_FACTOR = %.1f;\n', cfg.FREQ_WEIGHT_FACTOR);
    fprintf(fid, '    params.DC_SCALE_FACTOR = %.1f;\n', cfg.DC_SCALE_FACTOR);
    fprintf(fid, '    params.DC_BLOCK_SIZE = %d;\n', cfg.DC_BLOCK_SIZE);
    fprintf(fid, '    params.USE_MEDIAN_FILTER = %d;\n', cfg.USE_MEDIAN_FILTER);
    fprintf(fid, '    params.MEDIAN_FILTER_SIZE = [%d, %d];\n', ...
        cfg.MEDIAN_FILTER_SIZE(1), cfg.MEDIAN_FILTER_SIZE(2));
    fprintf(fid, '    params.USE_SHARPENING = %d;\n', cfg.USE_SHARPENING);
    fprintf(fid, '    params.SHARPENING_STRENGTH = %.1f;\n', cfg.SHARPENING_STRENGTH);
    fprintf(fid, '    params.ENHANCE_AFTER_FRAME = %d;\n', cfg.ENHANCE_AFTER_FRAME);
    
    % Handle force I-frames (could be empty)
    if isempty(cfg.FORCE_I_FRAMES)
        fprintf(fid, '    params.FORCE_I_FRAMES = [];\n');
    else
        fprintf(fid, '    params.FORCE_I_FRAMES = [');
        fprintf(fid, '%d,', cfg.FORCE_I_FRAMES(1:end-1));
        fprintf(fid, '%d];\n', cfg.FORCE_I_FRAMES(end));
    end
    
    fprintf(fid, 'end\n');
    fclose(fid);
end

function psnr_values = calculate_psnr(original_dir, decompressed_dir, num_frames)
    % Calculate PSNR for each frame
    psnr_values = zeros(num_frames, 1);
    
    for frame_idx = 1:num_frames
        % Read original frame
        original_path = fullfile(original_dir, sprintf('frame%03d.jpg', frame_idx));
        original = double(imread(original_path));
        
        % Read decompressed frame
        decompressed_path = fullfile(decompressed_dir, sprintf('frame%03d.jpg', frame_idx));
        decompressed = double(imread(decompressed_path));
        
        % Calculate MSE
        mse = mean((original(:) - decompressed(:)).^2);
        
        % Calculate PSNR
        if mse == 0
            psnr_values(frame_idx) = 100;  % Arbitrary high value for perfect match
        else
            max_pixel = 255.0;
            psnr_values(frame_idx) = 20 * log10(max_pixel / sqrt(mse));
        end
        
        fprintf('Frame %d, PSNR: %.2f dB\n', frame_idx, psnr_values(frame_idx));
    end
end 