function outstring = NullTerminateString( instring ) %codegen
%NULLTERMINATESTRING Null terminates a string
%  Given a string or character array, converts to a char array and places a
%  null-terminator on the end, creating a C style string.  The resulting
%  buffer can be handed to C functions.
%
%  Example:  
%   outstring = NullTerminateString( instring );
%
%  See Also: trimszString, deblank

%   Copyright 2023 Tessive LLC  See LICENSE file for full license information.

outstring = [ char(instring), char(0) ]; 

end
