classdef propertyblockGrammar < mgrammar.grammar
%PROPERTYBLOCKGRAMMAR Grammar for a property block

%   Copyright 2023 Tessive LLC  See LICENSE file for full license information.

properties (Access = private)
    propertyBlocks = mgrammar.grammar.empty
    Attributes = ''
end

methods
    function obj = propertyblockGrammar  

    end

    function setAttributes(obj, attributes)
        obj.Attributes = attributes;
    end
    
    function addProperty(obj, block)
        obj.propertyBlocks(end+1) = block;
    end
    
    function value = blockarray(obj)
        %BLOCKARRAY Creates the ordered set of blocks to serialize
        import mgrammar.stringGrammar;
        import mgrammar.indenter;
        
        value = stringGrammar('properties');
        if ~isempty(obj.Attributes)
            value(end+1) = stringGrammar(sprintf(' (%s)', obj.Attributes));
        end
        value(end+1) = stringGrammar(obj.lf);

        value(end+1) = indenter(4);
        for block = obj.propertyBlocks
            value(end+1) = block; %#ok<*AGROW>
        end
        value(end+1) = indenter(-4);
        value(end+1) = stringGrammar('end');
        value(end+1) = stringGrammar(obj.lf);
        value(end+1) = stringGrammar(obj.lf);

    end
    
    
end

end
