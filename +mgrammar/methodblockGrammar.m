classdef methodblockGrammar < mgrammar.grammar
%METHODBLOCKGRAMMAR Grammar for a method block

%   Copyright 2023 Tessive LLC  See LICENSE file for full license information.

properties (Access = private)
    functionBlocks = mgrammar.grammar.empty
    Attributes = ''
end

methods
    function obj = methodblockGrammar  

    end

    function setAttributes(obj, attributes)
        obj.Attributes = attributes;
    end
    
    function addFunctionBlock(obj, block)
        obj.functionBlocks(end+1) = block;
    end
    
    function value = blockarray(obj)
        %BLOCKARRAY Creates the ordered set of blocks to serialize
        import mgrammar.stringGrammar;
        import mgrammar.indenter;
        
        value = stringGrammar('methods');
        if ~isempty(obj.Attributes)
            value(end+1) = stringGrammar(sprintf(' (%s)', obj.Attributes));
        end
        value(end+1) = stringGrammar(obj.lf);

        value(end+1) = indenter(4);
        for block = obj.functionBlocks
            value(end+1) = block; %#ok<*AGROW>
        end
        value(end+1) = indenter(-4);
        value(end+1) = stringGrammar('end');
        value(end+1) = stringGrammar(obj.lf);
        value(end+1) = stringGrammar(obj.lf);

    end
    
    
end

end
