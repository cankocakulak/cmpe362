function analyze_compression()
    % Script to analyze compression ratio and PSNR for both normal and improved implementations
    
    % Add helper directories to path
    addpath('./helpers/');
    addpath('./helpers/compression/');
    addpath('./helpers/decompression/');
    
    % Setup
    input_dir = './video_data/';
    normal_output_dir = './decompressed/';
    improved_output_dir = './decompressed_improved/';
    
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
    gop_sizes = [1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20, 21, 22, 23, 24, 25, 26, 27, 28, 29, 30];
    
    % Arrays to store results for both implementations
    compression_ratios_normal = zeros(size(gop_sizes));
    compression_ratios_improved = zeros(size(gop_sizes));
    file_sizes_mb_normal = zeros(size(gop_sizes));
    file_sizes_mb_improved = zeros(size(gop_sizes));
    
    % PSNR analysis for specific GOP sizes
    psnr_gop_sizes = [1, 15, 30];
    psnr_values_normal = cell(length(psnr_gop_sizes), 1);
    psnr_values_improved = cell(length(psnr_gop_sizes), 1);
    
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
        
        % Run normal compression
        fprintf('Running normal compression...\n');
        compress();
        
        % Measure normal compressed file size
        file_info = dir('result.bin');
        compressed_size_normal = file_info.bytes * 8;  % Convert bytes to bits
        file_sizes_mb_normal(i) = compressed_size_normal / (8*1024*1024);  % Convert bits to MB
        compression_ratios_normal(i) = uncompressed_size / compressed_size_normal;
        
        % Run improved compression
        fprintf('Running improved compression...\n');
        improved_compress();
        
        % Measure improved compressed file size
        file_info = dir('result_improved.bin');
        compressed_size_improved = file_info.bytes * 8;  % Convert bytes to bits
        file_sizes_mb_improved(i) = compressed_size_improved / (8*1024*1024);  % Convert bits to MB
        compression_ratios_improved(i) = uncompressed_size / compressed_size_improved;
        
        % For specific GOP sizes, calculate PSNR for both implementations
        if ismember(gop_size, psnr_gop_sizes)
            % Run normal decompression
            fprintf('Running normal decompression...\n');
            decompress();
            
            % Calculate PSNR for normal implementation
            psnr_idx = find(psnr_gop_sizes == gop_size);
            psnr_values_normal{psnr_idx} = calculate_psnr(input_dir, normal_output_dir, total_frames);
            
            % Run improved decompression
            fprintf('Running improved decompression...\n');
            improved_decompress();
            
            % Calculate PSNR for improved implementation
            psnr_values_improved{psnr_idx} = calculate_psnr(input_dir, improved_output_dir, total_frames);
            
            % Save PSNR results to files
            save(sprintf('psnr_gop_%d.mat', gop_size), 'psnr_values_normal');
            save(sprintf('psnr_improved_gop_%d.mat', gop_size), 'psnr_values_improved');
        end
        
        % Clear the cached config again before next iteration
        clear('config');
    end
    
    % Save compression ratio results separately
    save('compression_results.mat', 'gop_sizes', 'compression_ratios_normal', 'file_sizes_mb_normal');
    save('compression_improved_results.mat', 'gop_sizes', 'compression_ratios_improved', 'file_sizes_mb_improved');
    
    % Plot normal compression ratio
    figure;
    plot(gop_sizes, compression_ratios_normal, 'o-', 'LineWidth', 2);
    title('Compression Ratio vs GOP Size (Normal Implementation)');
    xlabel('GOP Size');
    ylabel('Compression Ratio');
    grid on;
    saveas(gcf, 'compression_ratio_plot.png');
    
    % Plot improved compression ratio
    figure;
    plot(gop_sizes, compression_ratios_improved, 'o-', 'LineWidth', 2);
    title('Compression Ratio vs GOP Size (Improved Implementation)');
    xlabel('GOP Size');
    ylabel('Compression Ratio');
    grid on;
    saveas(gcf, 'compression_ratio_improved_plot.png');
    
    % Plot normal PSNR curves
    figure;
    colors = {'r', 'g', 'b'};
    legends = {};
    hold on;
    for i = 1:length(psnr_gop_sizes)
        plot(1:length(psnr_values_normal{i}), psnr_values_normal{i}, [colors{i}, '-o'], 'LineWidth', 2);
        legends{i} = sprintf('GOP = %d', psnr_gop_sizes(i));
    end
    hold off;
    title('PSNR vs Frame Number for Different GOP Sizes (Normal Implementation)');
    xlabel('Frame Number');
    ylabel('PSNR (dB)');
    legend(legends);
    grid on;
    saveas(gcf, 'psnr_plot.png');
    
    % Plot improved PSNR curves
    figure;
    colors = {'r', 'g', 'b'};
    legends = {};
    hold on;
    for i = 1:length(psnr_gop_sizes)
        plot(1:length(psnr_values_improved{i}), psnr_values_improved{i}, [colors{i}, '-o'], 'LineWidth', 2);
        legends{i} = sprintf('GOP = %d', psnr_gop_sizes(i));
    end
    hold off;
    title('PSNR vs Frame Number for Different GOP Sizes (Improved Implementation)');
    xlabel('Frame Number');
    ylabel('PSNR (dB)');
    legend(legends);
    grid on;
    saveas(gcf, 'psnr_improved_plot.png');
    
    % Print normal results
    fprintf('\nNormal Compression Analysis Results:\n');
    fprintf('----------------------------\n');
    fprintf('GOP Size | Compression Ratio | File Size (MB)\n');
    for i = 1:length(gop_sizes)
        fprintf('%7d | %18.2f | %13.2f\n', gop_sizes(i), compression_ratios_normal(i), file_sizes_mb_normal(i));
    end
    
    % Print improved results
    fprintf('\nImproved Compression Analysis Results:\n');
    fprintf('----------------------------\n');
    fprintf('GOP Size | Compression Ratio | File Size (MB)\n');
    for i = 1:length(gop_sizes)
        fprintf('%7d | %18.2f | %13.2f\n', gop_sizes(i), compression_ratios_improved(i), file_sizes_mb_improved(i));
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