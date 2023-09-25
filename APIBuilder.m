classdef APIBuilder
%APIBuilder A support class for working with classes derived from CoderAPI
%
% See Also:  CoderAPI
    
%   Copyright 2023 Tessive LLC  See LICENSE file for full license information.
    methods (Static)
        
        function BuildLibrary( InClass, isMexBuild )
            arguments
                InClass
                isMexBuild = false;
            end
            %BUILDLIBRARY Build the library associated with the API
            %  A static method accepting a CoderAPI-derived class as input.
            %  The optional argument isMexBuild is true if the library
            %  build is intended for use in a MEX file.
            InClass.BuildLibrary( isMexBuild );
           
        end
        
        
        
        function CopyLibrary( InClass, Destination, DoBuild )
            % COPYLIBRARY Copy the precompiled library and headers
            %  Copy the precompiled library to the specified location after building them.
            %  Optionally command if the rebuild is to be performed.
            %
            %  Example:
            %     APIBuilder.CopyLibrary( InClass, Destination, [DoBuild] )
            arguments
                InClass
                Destination
                DoBuild = true
            end
            
            if DoBuild
                APIBuilder.BuildLibrary( InClass );
            end
            
            Files = InClass.LibraryFiles;
            
            for i = 1 : numel( Files )
                copyfile( Files(i), Destination );
            end
        end
        
        
        
        function CopySharedLibraries( InClass, Destination, elevated )
            % COPYSHAREDLIBRARIES Copy the required shared libs for the library
            %  Copy the required shared libraries to the specified location.
            %
            %  If the 'elevated' flag is given, the commands will be executed in sudo,
            %  or elevated permissions mode.
            %
            %  Example:
            %     APIBuilder.CopySharedLibraries( InClass, Destination )
            %
            %  or
            %
            %    APIBuilder.CopySharedLibraries( InClass, Destination 'elevated')
            
            arguments
                InClass
                Destination
                elevated = false
            end
            
            % The SharedLibraryFiles is an optional method of the incoming
            % class.  If specified, files can be copied to the runtime
            % directory.
            try
                Files = InClass.SharedLibraryFiles;
            catch
                Files = string.empty;
            end
            
            for i = 1 : numel( Files )
                APIBuilder.CopyFileAndSetExecutable( Files(i), Destination, elevated );
            end

        end
        
        
        
        function BuildMex( InClass )
            %BUILDMEX Build the MEX file needed to use the API
            %  A static method accepting a CoderAPI-derived class as input.
            
            MexName = InClass.MexName;
            
            APIBuilder.BuildLibrary( InClass, true );
            APIBuilder.MakeMexWrappers( InClass );
            
            
            % Create configuration object of class 'coder.MexCodeConfig'.
            cfg = coder.config('mex');
            cfg.TargetLang = 'C++';
            cfg.GenerateReport = true;
            cfg.SaturateOnIntegerOverflow = false;
            cfg.IntegrityChecks = false;
            cfg.ResponsivenessChecks = false;

            % Put the function names, arguments, and number of output agruments together in a cell array
            MexList = InClass.MexMethodsAndArgs;
            arglist = {};
            for i=1:numel( MexList )
                arglist{ end + 1 } = APIBuilder.MethodNameToMexFunctionName( InClass, MexList(i).MethodName ); %#ok<*AGROW>

                arglist{ end + 1 } = '-args';
                arglist{ end + 1 } = MexList(i).MethodArgs;
                
                arglist{ end + 1 } = '-nargout';
                arglist{ end + 1 } = MexList(i).NumOutArgs;

            end
            
            % Invoke MATLAB Coder.
            prevdir = pwd;
            cd( APIBuilder.SDKDir( InClass ) );
            codegen('-config', cfg, ...
                '-o', MexName, ...
                arglist{:});
            cd(prevdir);
            
            APIBuilder.CopySharedLibraries( InClass, fullfile(matlabroot, 'bin', lower(computer) ) , 'elevated');
            
            APIBuilder.RemoveMexWrapperDir( InClass );
        end
        
        
        
    end
    
    
    
    
    methods (Static, Hidden) 
        
        function MakeMexWrappers( InClass )
            %MAKEMEXWRAPPERS Make Wrapper functions for each method
            MexList = InClass.MexMethodsAndArgs;
            MexFuncDir = APIBuilder.MexWrapperDir( InClass );
            APIBuilder.CreateEmptyMexWrapperDir( InClass );
            
            for i = 1:numel(MexList)
                StaticFunc = [class(InClass), '.', MexList(i).MethodName];
                WrapperFuncName = APIBuilder.MethodNameToMexFunctionName( InClass, MexList(i).MethodName );
                Filename = fullfile( MexFuncDir, [WrapperFuncName, '.m']);
                APIBuilder.MakeWrapperFunc( Filename, WrapperFuncName, StaticFunc );
                
            end
        end
        
        function MakeWrapperFunc( Filename, WrapperFuncName, FuncToCall )
            %MAKEWRAPPERFUNC Create a simple wrapper .m file to call
            %another function.

            import mgrammar.functionGrammar;
            import mgrammar.stringGrammar;
            
            functionblock = functionGrammar( WrapperFuncName );
            functionblock.addInVar( 'varargin' );
            functionblock.addOutVar( '[ varargout ]' );
            
            block = stringGrammar(sprintf('[varargout{1:nargout}] = %s( varargin{:} );\n', FuncToCall ));
            
            functionblock.addBlock( block );
            
            fid = fopen( Filename, 'w' );
            fwrite(fid, functionblock.serialize);
            fclose(fid);
            
        end
        
        function LibDir = SDKDir( InClass )
            %SDKDIR Returns the directory of the SDK definition m file
            LibDir = fileparts( which( class( InClass ) ) );
            [ ~, lastnode ] = fileparts( LibDir );
            if startsWith( lastnode, '@')
                LibDir = fileparts( LibDir );
            end
            
        end
        
        function MexWrapperDir = MexWrapperDir( InClass )
            %MEXWRAPPERDIR Returns the directory for the MEX wrapper files
            MexWrapperDir = fullfile( APIBuilder.SDKDir( InClass ), [class( InClass ), 'MexWrappers'] );
        end
        
        function CreateEmptyMexWrapperDir( InClass )
            % Create the empty MEX wrapper function directory (empty if it
            % exists) and add to the path.
            APIBuilder.RemoveMexWrapperDir( InClass );
            mkdir( APIBuilder.MexWrapperDir( InClass ) );
            addpath( APIBuilder.MexWrapperDir( InClass ) );
            
        end
        
        function MexFunctionName = MethodNameToMexFunctionName( InClass, MethodName )
            % Convert a static method name to its corresponding MEX
            % function name (which is somewhat mangled to prevent confusion
            % on the MATLAB path )
            
            ClassName = class( InClass );
            MexFunctionName = [ ClassName, '_MEX_', MethodName ];
            
        end
        
        function RemoveMexWrapperDir( InClass )
            %Delete the MEX wrapper function directory and remove from the
            %path.
            MexFuncDir = APIBuilder.MexWrapperDir( InClass );
            
            if exist( MexFuncDir, 'dir' )
                rmpath( MexFuncDir );
                rmdir( MexFuncDir, 's' );
            end
        end
        
        
        
        function CopyFileAndSetExecutable( infile, outfiledir, elevated )
            arguments
                infile
                outfiledir
                elevated = false
            end
            
            if elevated
                sudo = "sudo ";
            else
                sudo = "";
            end
            
            [~,infilename, ext] = fileparts(infile);
            
            outfile = fullfile(outfiledir, infilename + ext);
            
            cmdstr = sudo + "cp -fL " + infile + " " + outfile;
            system(cmdstr);
            
            [~,~,ext] = fileparts(outfile);
            
            if strcmpi( ext, ".so")
                cmdstr = sudo + "chmod 755 " + outfile;
                system(cmdstr);
            end
           
            
        end
        
    end

end
