%% IIR Filter Design Algorithms
% Contains modular functions for Butterworth, Chebyshev Type I, and Elliptic bandstop filters.
% Usage: Call these functions from your analysis script.

function [b, a] = iir_filter_algorithms(filter_type, n, Wn, varargin)
    % Main function that dispatches to the appropriate filter design function
    % Usage:
    %   [b, a] = iir_filter_algorithms('butterworth', n, Wn)
    %   [b, a] = iir_filter_algorithms('cheby1', n, Wn, Rp)
    %   [b, a] = iir_filter_algorithms('ellip', n, Wn, Rp, Rs)
    
    % Check inputs
    if ~isvector(Wn) || length(Wn) ~= 2
        error('Wn must be a 2-element vector [lower_cutoff upper_cutoff]/(fs/2)');
    end
    
    if Wn(1) <= 0 || Wn(2) >= 1 || Wn(1) >= Wn(2)
        error('Wn values must be in range (0,1) and Wn(1) < Wn(2)');
    end
    
    % Ensure filter order is reasonable
    if n < 1 || n > 50 || mod(n,1) ~= 0
        error('Filter order must be a positive integer up to 50');
    end
    
    fprintf('Designing %s filter with order %d, Wn=[%.4f %.4f]\n', filter_type, n, Wn(1), Wn(2));
    
    switch lower(filter_type)
        case 'butterworth'
            % Butterworth only needs n and Wn
            [b, a] = butter(n, Wn, 'stop');
            
        case 'cheby1'
            % Check if we have enough parameters
            if isempty(varargin)
                error('Chebyshev Type I filter requires Rp parameter');
            end
            
            % Get Rp (passband ripple)
            Rp = varargin{1};
            if Rp <= 0
                error('Rp must be greater than 0');
            end
            
            % Design Chebyshev Type I filter
            [b, a] = cheby1(n, Rp, Wn, 'stop');
            
        case 'ellip'
            % Check if we have enough parameters
            if length(varargin) < 2
                error('Elliptic filter requires Rp and Rs parameters');
            end
            
            % Get Rp (passband ripple) and Rs (stopband attenuation)
            Rp = varargin{1};
            Rs = varargin{2};
            
            if Rp <= 0
                error('Rp must be greater than 0');
            end
            
            if Rs <= 0
                error('Rs must be greater than 0');
            end
            
            % Design Elliptic filter
            [b, a] = ellip(n, Rp, Rs, Wn, 'stop');
            
        otherwise
            error('Unknown filter type: %s', filter_type);
    end
end

function [b, a] = design_butterworth(n, Wn)
    % Design a Butterworth bandstop filter
    [b, a] = butter(n, Wn, 'stop');
end

function [b, a] = design_cheby1(n, Rp, Wn)
    % Design a Chebyshev Type I bandstop filter
    [b, a] = cheby1(n, Rp, Wn, 'stop');
end

function [b, a] = design_ellip(n, Rp, Rs, Wn)
    % Design an Elliptic bandstop filter
    [b, a] = ellip(n, Rp, Rs, Wn, 'stop');
end 