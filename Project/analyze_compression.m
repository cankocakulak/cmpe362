function analyze_compression()
    % Add functions from utils.m
    addpath('./');
    
    % Analyze compression performance for different GOP sizes
    
    % Parameters
    gop_sizes = [1, 5, 10, 15, 20, 25, 30];
    input_dir = './video_data/';
    output_dir = './decompressed/';
    
    % Get list of original frames
    orig_frames = dir(fullfile(input_dir, 'frame*.jpg'));
    total_frames = length(orig_frames);
    
    % Sort frame files by number
    frame_numbers = zeros(total_frames, 1);
    for i = 1:total_frames
        frame_name = orig_frames(i).name;
        frame_numbers(i) = str2double(regexp(frame_name, '\d+', 'match'));
    end
    [frame_numbers, sort_idx] = sort(frame_numbers);
    orig_frames = orig_frames(sort_idx);
    
    % Prepare results storage
    compression_ratios = zeros(length(gop_sizes), 1);
    psnr_values = zeros(length(gop_sizes), total_frames);
    
    % Uncompressed size (bits)
    uncompressed_size = 480 * 360 * 24 * total_frames;
    
    % Analyze each GOP size
    for g = 1:length(gop_sizes)
        gop_size = gop_sizes(g);
        fprintf('\nAnalyzing GOP size %d\n', gop_size);
        
        % Update GOP size in compress.m
        update_gop_size('compress.m', gop_size);
        
        % Compress
        compress();
        
        % Decompress
        update_gop_size('decompress.m', gop_size);
        decompress();
        
        % Calculate compression ratio
        compressed_file = dir('result.bin');
        compressed_size = compressed_file.bytes * 8;  % Convert to bits
        compression_ratio = uncompressed_size / compressed_size;
        compression_ratios(g) = compression_ratio;
        
        fprintf('Compression ratio: %.2f\n', compression_ratio);
        
        % Calculate PSNR for each frame
        for i = 1:total_frames
            % Read original frame
            orig_path = fullfile(input_dir, orig_frames(i).name);
            orig_frame = imread(orig_path);
            
            % Read decompressed frame
            decomp_path = fullfile(output_dir, sprintf('frame%03d.jpg', i));
            decomp_frame = imread(decomp_path);
            
            % Calculate PSNR
            psnr_values(g, i) = calculate_psnr(orig_frame, decomp_frame);
        end
        
        fprintf('Average PSNR: %.2f dB\n', mean(psnr_values(g, :)));
    end
    
    % Plot compression ratio vs GOP size
    figure;
    plot(gop_sizes, compression_ratios, 'o-', 'LineWidth', 2);
    title('Compression Ratio vs GOP Size');
    xlabel('GOP Size');
    ylabel('Compression Ratio');
    grid on;
    saveas(gcf, 'compression_ratio.png');
    
    % Plot PSNR for selected GOP sizes
    figure;
    hold on;
    
    % Choose 3 GOP sizes to plot (1, 15, 30)
    plot_indices = [1, find(gop_sizes == 15), find(gop_sizes == 30)];
    colors = {'r', 'g', 'b'};
    
    for i = 1:length(plot_indices)
        idx = plot_indices(i);
        if ~isempty(idx)
            plot(1:total_frames, psnr_values(idx, :), colors{i}, 'LineWidth', 2);
        end
    end
    
    title('PSNR vs Frame Number');
    xlabel('Frame Number');
    ylabel('PSNR (dB)');
    legend({'GOP=1', 'GOP=15', 'GOP=30'});
    grid on;
    saveas(gcf, 'psnr.png');
end

% Helper function to update GOP size in a file
function update_gop_size(filename, gop_size)
    % Read file content
    fid = fopen(filename, 'r');
    content = fread(fid, '*char')';
    fclose(fid);
    
    % Update GOP_SIZE
    pattern = 'GOP_SIZE\s*=\s*\d+';
    replacement = sprintf('GOP_SIZE = %d', gop_size);
    content = regexprep(content, pattern, replacement);
    
    % Write updated content
    fid = fopen(filename, 'w');
    fwrite(fid, content);
    fclose(fid);
end 