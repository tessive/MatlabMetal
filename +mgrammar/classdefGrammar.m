classdef classdefGrammar < mgrammar.grammar
%CLASSDEFGRAMMAR Top level grammar for a classdef file

%   Copyright 2023 Tessive LLC  See LICENSE file for full license information.
properties

    classname = '';
    inheritedClasses = {}
    classHelpSummary = '';
    mainClassHelp = mgrammar.grammar.empty
    enumerationBlocks = mgrammar.grammar.empty
    propertyBlocks = mgrammar.grammar.empty
    methodBlocks = mgrammar.grammar.empty
   
end

methods
    function obj = classdefGrammar(classname)
        obj.classname = classname;
    end
    
    function addInheritedClass(obj, classname)
        obj.inheritedClasses{end+1} = classname;
    end
    
    function addClassHelpSummary(obj, summary)
        obj.classHelpSummary = summary;
    end
    
    function addMainClassHelp(obj, helpblock)
        obj.mainClassHelp = helpblock;
    end
    
    function addEnumerationBlock(obj, enumblock)
        obj.enumerationBlocks(end+1) = enumblock;
    end
    
    function addMethodBlock(obj, methodblock)
        obj.methodBlocks(end+1) = methodblock;
    end
    
    function addPropertyBlock(obj, block)
        obj.propertyBlocks(end+1) = block;
    end
    
    function value = blockarray(obj)
        %BLOCKARRAY Creates the ordered set of blocks to serialize
        import mgrammar.stringGrammar;

        % Top file line
        value = stringGrammar(['classdef ', obj.classname]);
        if numel(obj.inheritedClasses) > 0
             value(end+1) = stringGrammar([' < ', obj.inheritedClasses{1}]);
        end
        
        for i=2:numel(obj.inheritedClasses)
             value(end+1) = stringGrammar([' & ', obj.inheritedClasses{i}]); %#ok<*AGROW>
        end
        
        % Add the comment line
        value(end+1) = stringGrammar([obj.lf, '%', upper(obj.classname), ' ', obj.classHelpSummary]);
        value(end+1) = stringGrammar(obj.lf);
        
        % Add in the rest of the body in order
        value = [value, obj.mainClassHelp, obj.enumerationBlocks, obj.propertyBlocks, obj.methodBlocks];

        % End
        value(end+1) = stringGrammar(['end', obj.lf']);
        
    end
    
    
end

end
