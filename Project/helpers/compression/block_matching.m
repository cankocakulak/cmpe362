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
    found_any_block = false; % Flag to see if any valid block is processed

    % --- Exhaustive Search Example --- 
    for r_offset = -search_range:search_range
        for c_offset = -search_range:search_range
            ref_block_row_start = mb_row_start + r_offset;
            ref_block_col_start = mb_col_start + c_offset;

            if ref_block_row_start >= 1 && ref_block_row_start + mb_height - 1 <= ref_height && ...
               ref_block_col_start >= 1 && ref_block_col_start + mb_width - 1 <= ref_width
                
                found_any_block = true;
                candidate_block = ref_frame(ref_block_row_start : ref_block_row_start + mb_height - 1, ...
                                          ref_block_col_start : ref_block_col_start + mb_width - 1, :);
                sad = sum(abs(current_mb(:) - candidate_block(:)));

                if sad < min_sad
                    min_sad = sad;
                    mv_row = r_offset;
                    mv_col = c_offset;
                    best_match_block = candidate_block;
                elseif sad == min_sad 
                    if (r_offset^2 + c_offset^2) < (mv_row^2 + mv_col^2)
                        mv_row = r_offset;
                        mv_col = c_offset;
                        best_match_block = candidate_block;
                    end
                end
            end
        end
    end
    
    if ~found_any_block
         warning('Block_matching: No valid blocks found in search window for MB at (%d,%d). Check search_range or frame boundaries.', mb_row_start, mb_col_start);
    end

    if isinf(min_sad) 
        % Fallback logic as before
        ref_block_row_start = mb_row_start;
        ref_block_col_start = mb_col_start;
        if ref_block_row_start >= 1 && ref_block_row_start + mb_height - 1 <= ref_height && ...
           ref_block_col_start >= 1 && ref_block_col_start + mb_width - 1 <= ref_width
            best_match_block = ref_frame(ref_block_row_start : ref_block_row_start + mb_height - 1, ...
                                         ref_block_col_start : ref_block_col_start + mb_width - 1, :);
            mv_row = 0;
            mv_col = 0;
        else
            warning('Block_matching: Fallback failed for MB at (%d,%d). No reference block could be formed.', mb_row_start, mb_col_start);
            best_match_block = current_mb; 
            mv_row = 0;
            mv_col = 0; 
        end
    end
end 