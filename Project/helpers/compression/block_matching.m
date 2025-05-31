function [mv_row, mv_col, best_match_block] = block_matching(current_mb, ref_frame, mb_row_start, mb_col_start, search_range)
% BLOCK_MATCHING - Finds the best match for a macroblock in a reference frame.
% Inputs:
%   current_mb      - The current macroblock (e.g., 8x8x3)
%   ref_frame       - The reference frame (full frame)
%   mb_row_start    - The top-left row of the current_mb in its original frame
%   mb_col_start    - The top-left col of the current_mb in its original frame
%   search_range    - How far to search (e.g., 7 for +/-7 pixels)
% Outputs:
%   mv_row          - Motion vector (row offset)
%   mv_col          - Motion vector (col offset)
%   best_match_block - The 8x8x3 block from ref_frame that best matches current_mb

    [mb_height, mb_width, num_channels] = size(current_mb);
    [ref_height, ref_width, ~] = size(ref_frame);

    min_sad = inf; % Sum of Absolute Differences
    mv_row = 0;
    mv_col = 0;
    best_match_block = zeros(size(current_mb));

    % --- Exhaustive Search Example --- 
    % Search window boundaries in the reference frame
    % (Ensure they don't go out of frame bounds)
    for r_offset = -search_range:search_range
        for c_offset = -search_range:search_range
            % Top-left corner of the candidate block in the reference frame
            ref_block_row_start = mb_row_start + r_offset;
            ref_block_col_start = mb_col_start + c_offset;

            % Check bounds: Ensure the candidate block is within the reference frame
            if ref_block_row_start >= 1 && ref_block_row_start + mb_height - 1 <= ref_height && ...
               ref_block_col_start >= 1 && ref_block_col_start + mb_width - 1 <= ref_width
                
                % Extract candidate block from reference frame
                candidate_block = ref_frame(ref_block_row_start : ref_block_row_start + mb_height - 1, ...
                                          ref_block_col_start : ref_block_col_start + mb_width - 1, :);

                % Calculate SAD (Sum of Absolute Differences) for all channels
                sad = sum(abs(current_mb(:) - candidate_block(:)));

                if sad < min_sad
                    min_sad = sad;
                    mv_row = r_offset;
                    mv_col = c_offset;
                    best_match_block = candidate_block;
                elseif sad == min_sad % Tie-breaking: prefer zero motion vector or smaller magnitude
                    if (r_offset^2 + c_offset^2) < (mv_row^2 + mv_col^2)
                        mv_row = r_offset;
                        mv_col = c_offset;
                        best_match_block = candidate_block;
                    end
                end
            end
        end
    end
    % If no valid block was found (e.g. current_mb is at border and search_range is large)
    % ensure best_match_block is the one at (0,0) offset if possible, or current_mb itself.
    if isinf(min_sad)
        % Fallback: use block at (0,0) offset if within bounds
        ref_block_row_start = mb_row_start;
        ref_block_col_start = mb_col_start;
        if ref_block_row_start >= 1 && ref_block_row_start + mb_height - 1 <= ref_height && ...
           ref_block_col_start >= 1 && ref_block_col_start + mb_width - 1 <= ref_width
            best_match_block = ref_frame(ref_block_row_start : ref_block_row_start + mb_height - 1, ...
                                         ref_block_col_start : ref_block_col_start + mb_width - 1, :);
            mv_row = 0;
            mv_col = 0;
        else
            % This case should ideally not happen if block is from a valid frame.
            % As a last resort, if no reference block can be formed, 
            % this might indicate an issue or a need for different handling.
            % For now, using the current_mb itself would mean zero residual, 
            % but this is not a true "match". Or, return an error/flag.
            warning('No valid reference block found for motion estimation. Using original block.');
            best_match_block = current_mb; % Or handle error
            mv_row = 0;
            mv_col = 0; 
        end
    end
end 