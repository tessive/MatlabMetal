classdef enumerationGrammar < mgrammar.grammar
%ENUMERATIONGRAMMAR Grammar for an enumeration block

%   Copyright 2023 Tessive LLC  See LICENSE file for full license information.

properties

    enumNames = {}
    enumValues = []
    
end

methods
    function obj = enumerationGrammar  

    end
    
    function addEnumNameAndValue(obj, name, value)
        obj.enumNames{end+1} = name;
        obj.enumValues(end+1) = value;
    end

    
    function value = blockarray(obj)
        %BLOCKARRAY Creates the ordered set of blocks to serialize
        import mgrammar.stringGrammar;
        import mgrammar.indenter;
        
        value = stringGrammar(obj.lf);
        value(end+1) = stringGrammar('enumeration');
        value(end+1) = indenter(4);
        

        for i=1:numel(obj.enumNames)
            value(end+1) = stringGrammar(obj.lf);
            value(end+1) = stringGrammar(obj.enumNames{i}); %#ok<*AGROW>
            value(end+1) = stringGrammar(sprintf('(%i)', obj.enumValues(i))); %#ok<*AGROW>
                        
        end

        value(end+1) = stringGrammar(obj.lf);
        value(end+1) = indenter(-4);

        value(end+1) = stringGrammar(['end', obj.lf]);

    end
    
    
end

end
