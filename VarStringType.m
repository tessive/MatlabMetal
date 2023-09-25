function type = VarStringType
%VarStringType Creates a coder.Type object for a variable string
%  Creates a coder.Type object representing a String object with variable
%  length.

%   Copyright 2023 Tessive LLC  See LICENSE file for full license information.
s = "mystring";
type = coder.typeof(s);
type.Properties.Value = coder.typeof('a', [1 Inf], [ 0 1 ]);

end
