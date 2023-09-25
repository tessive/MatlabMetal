classdef indenter < mgrammar.grammar
%INDENTER Block signaling an indent or de-indent

%   Copyright 2023 Tessive LLC  See LICENSE file for full license information.


properties
    indent = 0
end

methods
    function obj = indenter(indent)
        obj.indent = indent;

    end

end

end
