function result = is_i_frame(frame_idx, gop_size)
    % Check if a frame is an I-frame based on the GOP structure
    result = mod(frame_idx - 1, gop_size) == 0;
end 