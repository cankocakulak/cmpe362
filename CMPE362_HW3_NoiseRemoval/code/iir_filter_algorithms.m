%% IIR Filter Design Algorithms
% Contains modular functions for Butterworth, Chebyshev Type I, and Elliptic bandstop filters.
% Usage: Call these functions from your analysis script.

function [b, a] = iir_filter_algorithms(filter_type, n, Wn, varargin)
    % Main function that dispatches to the appropriate filter design function
    % Usage:
    %   [b, a] = iir_filter_algorithms('butterworth', n, Wn)
    %   [b, a] = iir_filter_algorithms('cheby1', n, Wn, Rp)
    %   [b, a] = iir_filter_algorithms('ellip', n, Wn, Rp, Rs)
    
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