classdef functionGrammar < mgrammar.grammar
%FUNCTIONGRAMMAR Grammar for a function

%   Copyright 2023 Tessive LLC  See LICENSE file for full license information.

properties (Access = private)
    innerBlocks = mgrammar.grammar.empty
    name = ''
    outVars = {}
    inVars = {}
    summary = ''
end

methods
    function obj = functionGrammar(name)
        obj.name = name;
    end

    function addOutVar(obj, outvar)
        obj.outVars{end+1} = outvar;
    end
    
    function addInVar(obj, invar)
        obj.inVars{end+1} = invar;
    end
    
    function addSummary(obj, summary)
        obj.summary = summary;
    end
    
    function addBlock(obj, block)
        obj.innerBlocks = [obj.innerBlocks, block];
    end
    
    function value = blockarray(obj)
        %BLOCKARRAY Creates the ordered set of blocks to serialize
        import mgrammar.indenter;
        import mgrammar.stringGrammar;
        
        value = obj.createFunctionHeader;
        value(end+1) = indenter(4);
        value = [value, obj.createSummaryLine];
        value = [value, obj.innerBlocks];
        
        value(end+1) = indenter(-4);
        
        value(end+1) = stringGrammar('end');
        value(end+1) = stringGrammar(obj.lf);
        value(end+1) = stringGrammar(obj.lf);

    end
    
    function value = createFunctionHeader(obj)
        %CREATEFUNCTIONHEADER Create the top line of the function.
        import mgrammar.stringGrammar;
        
        value = stringGrammar('function ');
        if numel(obj.outVars) > 1
            value(end+1) = stringGrammar('[');
        end
        
        if numel(obj.outVars) > 0
            value(end+1) = stringGrammar(obj.outVars{1});
        end
        
        for i=2:numel(obj.outVars)
            value(end+1) = stringGrammar([' , ',obj.outVars{1}]);
        end
        
        if numel(obj.outVars) > 1
            value(end+1) = stringGrammar(']');
        end
        
        if numel(obj.outVars) > 0
            value(end+1) = stringGrammar(' = ');
        end
        
        value(end+1) = stringGrammar(obj.name);
        
        if numel(obj.inVars) > 0
            value(end+1) = stringGrammar('( ');
            
            for i=1:numel(obj.inVars)
                value(end+1) = stringGrammar(obj.inVars{i});
                if i < numel(obj.inVars)
                    value(end+1) = stringGrammar(', ');
                end
            end
            
            value(end+1) = stringGrammar(' )');
        end        
        value(end+1) = stringGrammar(obj.lf);

    end
    
    function summaryline = createSummaryLine(obj)
        %CREATESUMMARYLINE make the first summary line of the function
        summaryline = mgrammar.stringGrammar(sprintf('%%%s %s\n', upper(obj.name), obj.summary));
        
    end
    
    
end

end
