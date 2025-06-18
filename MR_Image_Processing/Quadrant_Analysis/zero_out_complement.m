% Function to zero out regions of a matrix
function [varargout] = zero_out_complement(x_keep, y_keep, varargin)

if nargin < 3
    error('At least three inputs x_keep, y_keep, and a volume) are required.');
end

% Default matrices to empty unless passed as inputs
Vol1 = [];
Vol2 = [];
Vol3 = [];

% Process optional inputs
if ~isempty(varargin)
    for i = 1:length(varargin)
        if i == 1
            Vol1 = varargin{i}; % First optional input is Vol1
        elseif i == 2
            Vol2 = varargin{i}; % Second optional input is Vol2
        elseif i == 3
            Vol3 = varargin{i}; % Third optional input is Vol3
        else
            warning('Too many inputs, ignoring extra ones.');
        end
    end
end

% Full ranges for x and y
x_full = 1:size(Vol1, 1);
y_full = 1:size(Vol1, 2);

% Apply zeroing based on x_keep and y_keep
Vol1(setdiff(x_full, x_keep), :, :, :) = 0;
Vol2(setdiff(x_full, x_keep), :, :, :) = 0;
Vol3(setdiff(x_full, x_keep), :, :, :) = 0;
Vol1(:, setdiff(y_full, y_keep), :, :) = 0;
Vol2(:, setdiff(y_full, y_keep), :, :) = 0;
Vol3(:, setdiff(y_full, y_keep), :, :) = 0;

% Set outputs based on the requested number
if nargout >= 1
    varargout{1} = Vol1;
end
if nargout >=2
    varargout{2} = Vol2;
end
if nargout >=3
    varargout{3} = Vol3;
end