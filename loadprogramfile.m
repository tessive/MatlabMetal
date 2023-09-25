function text = loadprogramfile( filename )
%LOADPROGRAMFILE Load a text file

%   Copyright 2023 Tessive LLC  See LICENSE file for full license information.
text = uint8(fileread(filename));

end

