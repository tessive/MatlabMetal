function outstring = trimszString(instring) %codegen
%TRIMSZSTRING Trims a null-terminated (C style) string
%  Given a string that may contain a null character indicating the
%  termination of the string (C style string), will return a MATLAB string
%  that has been resized to that length.
%
%  Example:  
%   instring = 'Some string that may be from a C call with things in it';
%   instring(12) = char(0);
%   outstring = trimszString(instring)
%
%  See Also: deblank, NullTerminateString

%   Copyright 2023 Tessive LLC  See LICENSE file for full license information.
%  Copyright 2015 Tessive LLC

ind = find(instring == char(0), 1);
if isempty(ind)
    ind = numel(instring)+1;
end
outstring = instring(1:min(end, ind(1)-1));

end

