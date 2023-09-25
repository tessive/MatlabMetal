function data = bound(data, varargin)  %#codegen
%BOUND Bound data between two values
%  Given an array, will clamp the data to be between two specified scalar
%  values. 
%
%  data = bound(data, valarray)
%  data = bound(data, val1, val2)
%
%  Example:
%     data = 1:5;
%     data = bound(data, 2, 4)
%     data = 
%        2 2 3 4 4
%
%    data = 1:5
%    valarray = 2:0.5:4
%    data = bound(data, valarray)
%     data = 
%        2 2 3 4 4

%   Copyright 2023 Tessive LLC  See LICENSE file for full license information.

switch nargin
    case 2
        minval = min(varargin{1});
        maxval = max(varargin{1});
    case 3
        val1 = varargin{1};
        val2 = varargin{2};
        maxval = max(val1, val2);
        minval = min(val1, val2);
    otherwise
        minval = 0;
        maxval = 1;
        
end


data = max(min(data, maxval), minval);

end
