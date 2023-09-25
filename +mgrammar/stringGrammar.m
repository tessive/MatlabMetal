classdef stringGrammar < mgrammar.grammar
%STRINGGRAMMAR Grammar that wraps a single character string

%   Copyright 2023 Tessive LLC  See LICENSE file for full license information.
properties

    stringval
    
end

methods
    function obj = stringGrammar(stringval)
        %STRINGGRAMMAR Grammar that wraps a single character string
        obj.stringval = stringval;

    end
    
    function outstring = serialize(obj)
        %SERIALIZE Return a string representing the rendered output

        outstring = obj.stringval;
        
    end

    
end

end
