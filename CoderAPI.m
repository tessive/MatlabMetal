classdef CoderAPI < coder.ExternalDependency
    %CODERAPI Derived from coder.Externaldependency, SDK classes derived
    %from this class can have MEX files built using the APIBuilder class.  
    %
    %  See Also: APIBuilder

    %   Copyright 2023 Tessive LLC  See LICENSE file for full license information.
  
 
    methods
        function obj = CoderAPI
            obj = obj@coder.ExternalDependency;
        end
    end
    
    methods (Static, Abstract)
        MexMethodsAndArgs
        %MEXMETHODSANDARGS Supplies a list of all methods and arguments for
        %compilation of a MEX.  This should take the form:
        %
        %  function list = MexMethodsAndArgs
        %         list = APIBuilder.AddMethodAndArgs('method1', ...
        %                            coder.typeof('X',[1 4096],[0 1]), ...
        %                            coder.typeof( 0 ) ... (for all input arguments)
        %         list = APIBuilder.AddMethodAndArgs( list... The second call must include the list to be appended to.
        %                            'method2', ...
        %                            coder.typeof(0) ... (for all input arguments) 
        %  end
        
        BuildLibrary
        %BUILDLIBRARY This builds any required library for the API.  If
        %none is required, this should still be implemented and left empty.
        
        LibraryFiles
        %LIBRARYFILES Lists the files needed for static linking the library
        %built by BuildLibrary.  These are returned as a string array of
        %fully qualified path names as built by BuildLibrary.  Usually this
        %is the .a and .h files for the build. 
        
        MexName
        %Returns the name of the MEX file implementing the static methods,
        %does not have any extension.
        
    end
    
    methods (Static, Hidden)
        
        function list = AddMethodAndArgs( varargin )
            %ADDMETHODANDARGS Creates a list of methods and arguments
            % In order to build a MEX for the API, all methods that require
            % compiling and addition into the MEX should be listed in the
            % MexMethodsAndArgs method.
            %
            %  The first argument is either the name of the static method to
            %  include in the MEX (without any preceeding class name) if this
            %  is the first call to create a new list, or a list returned
            %  from a previous call to AddMethodAndArgs to append to, in
            %  which case the second argument is the method name.
            %
            %  The next argument is the number of output arguments the
            %  function will return.
            %
            %  All the remaining arguments are coder.typeof classes
            %  specifying the input argument types.
            %
            %  function list = MexMethodsAndArgs
            %         list = APIBuilder.AddMethodAndArgs('method1', ...
            %                            1, ... One output argument
            %                            coder.typeof('X',[1 4096],[0 1]), ...
            %                            coder.typeof( 0 ) ... (for all input arguments)
            %         list = APIBuilder.AddMethodAndArgs( list... The second call must include the list to be appended to.
            %                            'method2', ...
            %                            coder.typeof(0) ... (for all input arguments)
            %  end
            
            emptylist = struct('MethodName', {}, 'MethodArgs', {}, 'NumOutArgs', {});
            if nargin == 0
                list = emptylist;
                return;
            end
            
            switch class( varargin{ 1 } )
                case 'char'
                    list = emptylist;
                    MethodName = varargin{ 1 };
                    NumOutArgs = varargin{ 2 };
                    MethodArgsCell = varargin( 3 : end );
                    
                case 'struct'
                    list = varargin{ 1 };
                    MethodName = varargin{ 2 };
                    NumOutArgs = varargin{ 3 };
                    MethodArgsCell = varargin( 4 : end );
                otherwise
                    error( 'APIBuilder:AddMethodAndArgs:InvalidFirstArg', 'Invalid first argument');
                    
            end
            
            
            MethodArgs = {};
            for i = 1 : numel(MethodArgsCell)
                argument = MethodArgsCell{ i };
                if ~any(contains(superclasses( argument ), 'coder.Type'))
                    error( 'APIBuilder:AddMethodAndArgs:InvalidArgument', 'All arguments must be declared with coder.typeof.');
                end
                MethodArgs{ end + 1 } = argument; %#ok<AGROW>
            end
            
            list( end + 1 ) = struct('MethodName', MethodName, 'MethodArgs', {MethodArgs(:)}, 'NumOutArgs', NumOutArgs);
            
        end
        
        
        
        function [ varargout ] = RunMex( varargin )
            if coder.target('MATLAB')
                S = dbstack;
                CallerInfo = S(2);
                CallingFile = CallerInfo.file;
                [~, ClassName ] = fileparts( CallingFile );
                MEXName = eval([ClassName, '.MexName']);
                FullCallingMethod = CallerInfo.name;
                
                [~, CallingMethod] = strtok( FullCallingMethod, '.');
                CallingMethod = CallingMethod(2:end);
                
                MexFunctionName = [ ClassName, '_MEX_', CallingMethod ];
                [ varargout{ 1 : nargout } ] = feval( MEXName, MexFunctionName, varargin{:} );
                
                
            end
        end
        
        
    end
    

end