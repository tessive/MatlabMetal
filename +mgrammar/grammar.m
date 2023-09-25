classdef grammar < handle & matlab.mixin.Heterogeneous
%GRAMMAR Base class for syntax development

%   Copyright 2023 Tessive LLC  See LICENSE file for full license information.

properties (Constant)
    lf = char(10);
end


methods
    function obj = grammar

    end
    
    function outstring = serialize(obj)
        %SERIALIZE Convert the grammar into an output string
        
        outstring = char(zeros(0,1));
        indentlevelvector = [];
        indent = 0;
        for block = obj.blockarray
            if isa(block, 'mgrammar.indenter')
                indent = indent + block.indent;
            else
                newstring = serialize(block);
                outstring = [outstring, newstring]; %#ok<*AGROW>
                indentlevelvector = [indentlevelvector, ones(1, numel(newstring)).*indent];
            end
        end
        outstring = obj.indentStringBlock(outstring, indentlevelvector);
    end
    
    function value = blockarray(~)
        value = mgrammar.grammar.empty;
    end
    
    function instring = indentStringBlock(~, instring, indentlevelvector)
        
        %Find all the LFs
        indicesOfLfs = find(instring == char(10));
        for i = numel(indicesOfLfs):-1:1
            lfIndex = indicesOfLfs(i); 
            numspaces = indentlevelvector(min(lfIndex+1, end));
            instring = [instring(1:lfIndex), blanks(numspaces), instring(lfIndex+1:end)];
        end
        
    end


end

end
