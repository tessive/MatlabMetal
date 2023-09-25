classdef Metal < CoderAPI  %#codegen
    %Class wrapping Metal functions
    
%   Copyright 2023 Tessive LLC  See LICENSE file for full license information.
    
    properties (Constant)
        HandleBaseType = 'uint64';
        InvalidHandle = uint64(0);
    end
    
   
    methods (Static, Hidden)
        
        function bName = getDescriptiveName(~)
            bName = 'Metal';
        end
        
        
        
        function name = MexName
            name = 'MetalMex';
        end
        
        
        
        function tf = isSupportedContext(~)
            tf = true;
        end
        
        
        
        function LibFiles = LibraryFiles
            localpath = fileparts( mfilename('fullpath') );
            libfile = fullfile( localpath, 'libMatlabMetal.a');
            
            LibFiles = string( libfile );
            LibFiles = [ LibFiles, ...
                fullfile( localpath, "MatlabMetal.h")];
            
        end
        
        
        
        function updateBuildInfo(buildInfo, ~)
            coder.extrinsic('computer');
            coder.extrinsic('fileparts');
            coder.extrinsic('fullfile');
            rootdir = coder.const(fileparts(mfilename('fullpath')));
            
            buildInfo.addIncludePaths( rootdir );
            
            libPriority = 1000;
            libPreCompiled = true;
            libLinkOnly = true;
            libName = 'libMatlabMetal.a';
            libPath = rootdir;
            libGroup = 'Metal';
            
            switch coder.const(computer)
                case {'MACI64', 'MACA64'}
                    
                    buildInfo.addLinkObjects( libName, libPath, ...
                        libPriority, libPreCompiled, libLinkOnly, libGroup);
                    buildInfo.addLinkFlags( '-framework Metal -framework Foundation');
                    
                case 'GLNXA64'
                    buildInfo.addLinkObjects( libName, libPath, ...
                        libPriority, libPreCompiled, libLinkOnly, libGroup);
                    
            end
            
        end
        
        
        
        function BuildLibrary( ~ )
            %BUILDLIBRARY Compile the helper lib file
            rootdir = fileparts(mfilename('fullpath'));
            libfile = fullfile(rootdir, 'libMatlabMetal.a');
            if exist(libfile, 'file')
                delete(libfile);
            end
            
            switch computer
                case {'MACI64', 'MACA64'}
                    projpath = fullfile(rootdir, 'libMatlabMetal', 'MatlabMetal', 'MatlabMetal.xcodeproj');
                    libpath = fullfile(rootdir, 'libMatlabMetal', 'MatlabMetal', 'build', 'Release');
                    
                    configuration = 'Release';
                    command = sprintf('xcodebuild -project %s -configuration %s', projpath, configuration);
                    system(command);
                    
                    copyfile(fullfile(libpath, '*.*'), rootdir, 'f');
                    
                case 'GLNXA64'
                    codepath = fullfile(rootdir, 'libMatlabMetal', 'MatlabMetal');
                    sourcefile = fullfile(codepath, 'MatlabMetal.cpp');

                    objfile = fullfile(codepath, 'matlabmetal.o');

                    
                    % Compile the main CPP file
                    command = ['g++ -std=c++11 -fPIC -c ', sourcefile, ' -o ', objfile ];
                    system(command);

                    
                    % Make an archive
                    command = ['ar rs ', libfile, ' ', objfile];
                    system(command);
                    
                    copyfile(fullfile(codepath, 'MatlabMetal.h'), rootdir, 'f');

                    
            end
            
            
        end
        
        
        
        function list = MexMethodsAndArgs
            
            if ~coder.target('MATLAB')
                list = [];
                return;
            end
            
            list = CoderAPI.AddMethodAndArgs( ...
                'LastError', ...
                1);
            
            list = CoderAPI.AddMethodAndArgs( list, ...
                'NumberOfDevices', ...
                1);

            list = CoderAPI.AddMethodAndArgs( list, ...
                'GetDeviceAtIndex', ...
                1, ...
                coder.typeof(0));
               
            list = CoderAPI.AddMethodAndArgs( list, ...
                'GetDeviceInfo', ...
                2, ...
                Metal.HandleBaseTypeClass );
            
            list = CoderAPI.AddMethodAndArgs( list, ...
                'IsSameDevice', ...
                1, ...
                Metal.HandleBaseTypeClass, ...
                Metal.HandleBaseTypeClass );
            
            list = CoderAPI.AddMethodAndArgs( list, ...
                'GetDeviceAllocatedMemory', ...
                1, ...
                Metal.HandleBaseTypeClass );
            
            list = CoderAPI.AddMethodAndArgs( list, ...
                'CopyDevice', ...
                1, ...
                Metal.HandleBaseTypeClass );
            
            list = CoderAPI.AddMethodAndArgs( list, ...
                'FreeDevice', ...
                0, ...
                Metal.HandleBaseTypeClass );
            
            list = CoderAPI.AddMethodAndArgs( list, ...
                'NewLibrary', ...
                1, ...
                coder.typeof(uint64(0)), ...
                VarStringType );
            
            list = CoderAPI.AddMethodAndArgs( list, ...
                'LibraryDevice', ...
                1, ...
                Metal.HandleBaseTypeClass );
            
            list = CoderAPI.AddMethodAndArgs( list, ...
                'FreeLibrary', ...
                0, ...
                Metal.HandleBaseTypeClass );
            
            list = CoderAPI.AddMethodAndArgs( list, ...
                'NewFunction', ...
                1, ...
                Metal.HandleBaseTypeClass, ...
                VarStringType );
            
            list = CoderAPI.AddMethodAndArgs( list, ...
                'FreeFunction', ...
                0, ...
                Metal.HandleBaseTypeClass );
            
            list = CoderAPI.AddMethodAndArgs( list, ...
                'NewComputePipelineState', ...
                1, ...
                Metal.HandleBaseTypeClass , ...
                Metal.HandleBaseTypeClass );
            
            list = CoderAPI.AddMethodAndArgs( list, ...
                'ComputePipelineStateDevice', ...
                1, ...
                Metal.HandleBaseTypeClass );
            
            list = CoderAPI.AddMethodAndArgs( list, ...
                'CopyComputePipelineState', ...
                1, ...
                Metal.HandleBaseTypeClass );
            
            list = CoderAPI.AddMethodAndArgs( list, ...
                'ThreadExecutionWidth', ...
                1, ...
                Metal.HandleBaseTypeClass );
            
            list = CoderAPI.AddMethodAndArgs( list, ...
                'FreeComputePipelineState', ...
                0, ...
                Metal.HandleBaseTypeClass );
            
            list = CoderAPI.AddMethodAndArgs( list, ...
                'NewCommandQueue', ...
                1, ...
                Metal.HandleBaseTypeClass );
            
            list = CoderAPI.AddMethodAndArgs( list, ...
                'CommandQueueDevice', ...
                1, ...
                Metal.HandleBaseTypeClass );
            
            list = CoderAPI.AddMethodAndArgs( list, ...
                'FreeCommandQueue', ...
                0, ...
                Metal.HandleBaseTypeClass );
            
            list = CoderAPI.AddMethodAndArgs( list, ...
                'NewBuffer', ...
                1, ...
                Metal.HandleBaseTypeClass, ...
                coder.typeof(0));
                        
            list = CoderAPI.AddMethodAndArgs( list, ...
                'CopyDataToBuffer', ...
                1, ...
                Metal.HandleBaseTypeClass, ...
                coder.typeof(uint8(0), [1 Inf] ));
            
            list = CoderAPI.AddMethodAndArgs( list, ...
                'CopyDataFromBuffer', ...
                2, ...
                Metal.HandleBaseTypeClass );
            
            list = CoderAPI.AddMethodAndArgs( list, ...
                'CopyUInt16DataToBuffer', ...
                1, ...
                Metal.HandleBaseTypeClass, ...
                coder.typeof(uint16(0), [Inf Inf Inf] ));
            
            list = CoderAPI.AddMethodAndArgs( list, ...
                'CopyUInt16DataFromBuffer', ...
                2, ...
                Metal.HandleBaseTypeClass, ...
                coder.typeof( double(0), [1 3]) );
            
            list = CoderAPI.AddMethodAndArgs( list, ...
                'CopySingleDataToBuffer', ...
                1, ...
                Metal.HandleBaseTypeClass, ...
                coder.typeof(single(0), [Inf Inf Inf] ));
            
            list = CoderAPI.AddMethodAndArgs( list, ...
                'CopySingleDataFromBuffer', ...
                2, ...
                Metal.HandleBaseTypeClass, ...
                coder.typeof( double(0), [1 3]) );
            
            list = CoderAPI.AddMethodAndArgs( list, ...
                'BufferSize', ...
                1, ...
                Metal.HandleBaseTypeClass );
            
            list = CoderAPI.AddMethodAndArgs( list, ...
                'BufferDevice', ...
                1, ...
                Metal.HandleBaseTypeClass );
            
            list = CoderAPI.AddMethodAndArgs( list, ...
                'FreeBuffer', ...
                0, ...
                Metal.HandleBaseTypeClass );
            
            list = CoderAPI.AddMethodAndArgs( list, ...
                'NewCommandBuffer', ...
                1, ...
                Metal.HandleBaseTypeClass );
            
            list = CoderAPI.AddMethodAndArgs( list, ...
                'CommandBufferDevice', ...
                1, ...
                Metal.HandleBaseTypeClass );
            
            list = CoderAPI.AddMethodAndArgs( list, ...
                'CopyCommandBuffer', ...
                1, ...
                Metal.HandleBaseTypeClass );
            
            list = CoderAPI.AddMethodAndArgs( list, ...
                'FreeCommandBuffer', ...
                0, ...
                Metal.HandleBaseTypeClass );
                
            list = CoderAPI.AddMethodAndArgs( list, ...
                'CommitCommandBuffer', ...
                1, ...
                Metal.HandleBaseTypeClass );
                
            list = CoderAPI.AddMethodAndArgs( list, ...
                'WaitForCompletion', ...
                1, ...
                Metal.HandleBaseTypeClass );
            
            list = CoderAPI.AddMethodAndArgs( list, ...
                'NewCommandEncoder', ...
                1, ...
                Metal.HandleBaseTypeClass );
            
            list = CoderAPI.AddMethodAndArgs( list, ...
                'FreeCommandEncoder', ...
                0, ...
                Metal.HandleBaseTypeClass );
            
            list = CoderAPI.AddMethodAndArgs( list, ...
                'SetComputePipelineState', ...
                1, ...
                Metal.HandleBaseTypeClass, ...
                Metal.HandleBaseTypeClass );
            
            list = CoderAPI.AddMethodAndArgs( list, ...
                'SetBuffer', ...
                1, ...
                Metal.HandleBaseTypeClass, ...
                Metal.HandleBaseTypeClass, ...
                coder.typeof(0) );
            
            list = CoderAPI.AddMethodAndArgs( list, ...
                'SetThreadsAndShape', ...
                1, ...
                Metal.HandleBaseTypeClass, ...
                Metal.HandleBaseTypeClass, ...
                coder.typeof(0, [1 3], [0 1] ) );
            
            list = CoderAPI.AddMethodAndArgs( list, ...
                'EndEncoding', ...
                1, ...
                Metal.HandleBaseTypeClass );
            
        end

        
    end
    
    methods (Static, Access = private)
        
        
        function devInfoStruct = rawDeviceInfoStruct
            %RawDeviceInfoStruct Returns an allocated mtlDeviceInfo struct associated
            %with the header file.
            
            devInfoStruct = struct(...
                'name', char(zeros(1,256, 'uint8')), ...
                'IsLowPower', uint8(0), ...
                'IsHeadless', uint8(0), ...
                'recommendedMaxWorkingSetSize', uint64(0), ...
                'RegistryID', uint64(0) ...
                );
            coder.cstructname(devInfoStruct, 'mtlDeviceInfo','extern','HeaderFile', 'MatlabMetal.h');
        end
        
        function devInfoStruct = ConvertRawDeviceInfoToMatlab( rawStruct )
            %ConvertRawDeviceInfoToMatlab Returns a Matlab friendly device info struct
            devInfoStruct = struct(...
                'name', string( trimszString( rawStruct.name)), ...
                'IsLowPower', logical( rawStruct.IsLowPower ), ...
                'IsHeadless', logical( rawStruct.IsHeadless ), ...
                'recommendedMaxWorkingSetSize', rawStruct.recommendedMaxWorkingSetSize, ...
                'RegistryID', rawStruct.RegistryID ...
                );
        end
        
        
        function basetype = HandleBaseTypeClass
            basetype = coder.typeof( cast( 0, Metal.HandleBaseType) );
        end
        
        
        function handletypeval = UIntToDeviceHandle( inthandle )
            coder.inline('always');
            handletypeval = cast( inthandle, 'like', coder.opaque('DeviceHandle', '0', 'HeaderFile', 'MatlabMetal.h'));
        end
        
        
        function handletypeval = UIntToLibraryHandle( inthandle )
            coder.inline('always');
            handletypeval = cast( inthandle, 'like', coder.opaque('LibraryHandle', '0', 'HeaderFile', 'MatlabMetal.h'));
        end
        
        
        function handletypeval = UIntToFunctionHandle( inthandle )
            coder.inline('always');
            handletypeval = cast( inthandle, 'like', coder.opaque('FunctionHandle', '0', 'HeaderFile', 'MatlabMetal.h'));
        end
              
        
        function handletypeval = UIntToComputePipelineStateHandle( inthandle )
            coder.inline('always');
            handletypeval = cast( inthandle, 'like', coder.opaque('ComputePipelineStateHandle', '0', 'HeaderFile', 'MatlabMetal.h'));
        end        
        
        
        function handletypeval = UIntToCommandQueueHandle( inthandle )
            coder.inline('always');
            handletypeval = cast( inthandle, 'like', coder.opaque('CommandQueueHandle', '0', 'HeaderFile', 'MatlabMetal.h'));
        end
        
        
        function handletypeval = UIntToBufferHandle( inthandle )
            coder.inline('always');
            handletypeval = cast( inthandle, 'like', coder.opaque('BufferHandle', '0', 'HeaderFile', 'MatlabMetal.h'));
        end
        
        
        function handletypeval = UIntToCommandBufferHandle( inthandle )
            coder.inline('always');
            handletypeval = cast( inthandle, 'like', coder.opaque('CommandBufferHandle', '0', 'HeaderFile', 'MatlabMetal.h'));
        end

        
        function handletypeval = UIntToCommandEncoderHandle( inthandle )
            coder.inline('always');
            handletypeval = cast( inthandle, 'like', coder.opaque('CommandEncoderHandle', '0', 'HeaderFile', 'MatlabMetal.h'));
        end

        
        function inthandle = HandleToUInt( handletypeval )
            coder.inline('always');
            inthandle = cast( handletypeval, Metal.HandleBaseType );
        end


    end  % end private static methods
    
    
    
    methods ( Static )
        
        function obj = Config
            %CONFIG Retrieves the MetalConfig class in use by Metal
            %  Returns the MetalConfig handle class which can be used to
            %  configure hardware options used by the Metal library.
            %
            %  See Also:  MetalConfig
            persistent pobj
            
            if isempty(pobj)
                pobj = MetalConfig;
            end
            obj = pobj;
            
        end
        
        
        
        function [ errorstring ] = LastError( )
            %LastError Retrieve the last error in the Metal system
            %   Returns the last error.
            %
            %   [ errorstring ] = Metal.LastError( )
            
            if coder.target('MATLAB')
                [ errorstring ] = CoderAPI.RunMex( );
                return
            end
            
            coder.cinclude( 'MatlabMetal.h' );
            szErrorstring = char( zeros(1,1024, 'uint8'));
            
            coder.ceval( 'mtlGetLastError', coder.ref( szErrorstring ), int32( 1024 ) );
            errorstring = string( trimszString( szErrorstring ) );
            
        end

        
        
        function [ num ] = NumberOfDevices( )
            %NumberOfDevices Get the number of Metal GPUs on the system
            %   Returns the number of Metal compatible GPUs attached.
            %
            %   [ num ] = Metal.NumberOfDevices( )
            
            if coder.target('MATLAB')
                [ num ] = CoderAPI.RunMex( );
                return
            end
            
            coder.cinclude( 'MatlabMetal.h' );
            numInt = uint32( 0 );
            
            numInt = coder.ceval( 'mtlNumberOfDevices' );
            num = double( numInt );
        end
        
        
        
        function [ device_handle ] = GetDeviceAtIndex( index )
            %GetDeviceAtIndex Return the handle for a device object
            %   Returns a handle to a MTLDevice at the one-based index,
            %   which relates to the index of the device as specified in
            %   the GetDeviceInfo array.  Handle is 0 on error.
            %
            %   [ device_handle ] = Metal.GetDeviceAtIndex( index )
            
            if coder.target('MATLAB')
                [ device_handle ] = CoderAPI.RunMex( index );
                return
            end
            
            coder.cinclude( 'MatlabMetal.h' );
            
            raw_handle = Metal.UIntToDeviceHandle(0);
            if (index > 0)
                raw_handle = coder.ceval( 'mtlGetDeviceAtIndex', uint32( index - 1 ) );
            end
            device_handle = Metal.HandleToUInt( raw_handle );

        end
        
     
        
        function [ result, deviceInfoStruct ] = GetDeviceInfo( device_handle )
            %GetDeviceInfo Get a struct with device information
            %   Returns a struct with Metal GPU device information.  Result
            %   is uint32(1) on success, uint32(0) on failure.
            %
            %   [ result, deviceInfoStruct ] = Metal.GetDeviceInfo( device_handle )
            
            if coder.target('MATLAB')
                [ result, deviceInfoStruct ] = CoderAPI.RunMex( device_handle );
                return
            end
            
            coder.cinclude( 'MatlabMetal.h' );

            raw_deviceInfoStruct = Metal.rawDeviceInfoStruct;
            result = uint32(0);
            result = coder.ceval( 'mtlGetDeviceInfo', Metal.UIntToDeviceHandle( device_handle ), coder.wref(raw_deviceInfoStruct) );
            deviceInfoStruct = Metal.ConvertRawDeviceInfoToMatlab( raw_deviceInfoStruct );
        end
        
        
        
        function [ deviceInfoStructArray, result ] = GetDeviceInfoArray
            %GetDeviceInfoArray Return an array of device info structs
            % Returns a device info struct for all devices on the system.
            %
            %  [ deviceInfoStructArray ] = Metal.GetDeviceInfoArray
            
            numDevices = Metal.NumberOfDevices;
            deviceInfoStructArray = repmat( Metal.ConvertRawDeviceInfoToMatlab( Metal.rawDeviceInfoStruct ), 1, numDevices );
            for i = 1:numDevices
                device = Metal.GetDeviceAtIndex(i);
                [result, deviceInfoStructArray(i) ] = Metal.GetDeviceInfo( device );
                if result == uint32(0)
                    return
                end
                Metal.FreeDevice( device );
            end
            
            
        end
        
        
        function [ isSame ] = IsSameDevice( device_handle1, device_handle2 )
            %IsSameDevice True if both device objects refer to the same device
            %   Returns true if both device handles refer to the same
            %   physical device on the system.
            %
            %  [ isSame ] = Metal.IsSameDevice( device_handle1, device_handle2 )
            
            if coder.target('MATLAB')
                [ isSame ] = CoderAPI.RunMex( device_handle1, device_handle2 );
                return
            end
            
            coder.cinclude( 'MatlabMetal.h' );
            returnval = uint8(0);
            returnval = coder.ceval( 'mtlSameDevice', ...
                Metal.UIntToDeviceHandle( device_handle1 ), ...
                Metal.UIntToDeviceHandle( device_handle2 ));
            isSame = logical( returnval );
        end
        
        
        
        function [ allocated_memory ] = GetDeviceAllocatedMemory( device_handle )
            %GetDeviceAllocatedMemory Return the memory allocated to a device
            %   Returns the memory allocated to a device, or -1 on error.
            % 
            %  [ allocated_memory ] = Metal.GetDeviceAllocatedMemory( device_handle )
            
            if coder.target('MATLAB')
                [ allocated_memory ] = CoderAPI.RunMex( device_handle );
                return
            end
            
            coder.cinclude( 'MatlabMetal.h' );
            raw_allocated_memory = int64(0);
            raw_allocated_memory = coder.ceval( 'mtlGetDeviceAllocatedMemory', Metal.UIntToDeviceHandle( device_handle ) );
            allocated_memory = double( raw_allocated_memory );
        end
        
        
        
        function [ new_device_handle ] = CopyDevice( device_handle )
            %CopyDevice Copy the device
            %   Copy the device referred to by the handle.
            %
            %  [ new_device_handle ] = Metal.CopyDevice( device_handle )
            
            if coder.target('MATLAB')
                [ new_device_handle ] = CoderAPI.RunMex( device_handle );
                return
            end
            
            raw_handle = Metal.UIntToDeviceHandle(0);
            coder.cinclude( 'MatlabMetal.h' );
            [ raw_handle ] = coder.ceval( 'mtlCopyDevice', Metal.UIntToDeviceHandle( device_handle ) );
            new_device_handle = Metal.HandleToUInt( raw_handle );
        end
        
        
        
        function FreeDevice( device_handle )
            %FreeDevice Free the device
            %   Free the device referred to by the handle.
            %
            %  Metal.FreeDevice( device_handle )
            
            coder.cinclude( 'MatlabMetal.h' );
            if device_handle == Metal.InvalidHandle
                return
            end
            
            if coder.target('MATLAB')
                CoderAPI.RunMex( device_handle );
                return
            end
            
            coder.ceval( 'mtlFreeDevice', Metal.UIntToDeviceHandle( device_handle ) );
        end
        
        
        
        function [ library_handle ] = NewLibrary( device_handle, source )
            %NewLibrary Create a new library from source code
            %  Accepts a device_handle and source as a string object.
            %  Returns a library_handle or uint64(0) on error.
            %
            %  [ library_handle ] = Metal.NewLibrary( device_handle, source )
            
            if coder.target('MATLAB')
                [ library_handle ] = CoderAPI.RunMex( device_handle, source );
                return
            end
            
            coder.cinclude( 'MatlabMetal.h' );
            raw_handle = Metal.UIntToLibraryHandle(0);
            char_source = NullTerminateString( source );
            raw_handle = coder.ceval( 'mtlNewLibrary', Metal.UIntToDeviceHandle( device_handle ), char_source );
            library_handle = Metal.HandleToUInt( raw_handle );
        end
        
        
        
        function [ device_handle ] = LibraryDevice( library_handle )
            %LibraryDevice Return the device the library was created on
            %   Return a handle to the device the library was create on.
            %   The handle will be newly created, so must be freed.
            %   Returns a device_handle or uint64(0) on error.
            %
            %  [ device_handle ] = Metal.LibraryDevice( library_handle )
            
            if coder.target('MATLAB')
                [ device_handle ] = CoderAPI.RunMex( library_handle );
                return
            end
            
            coder.cinclude( 'MatlabMetal.h' );
            raw_handle = Metal.UIntToDeviceHandle(0);
            raw_handle = coder.ceval( 'mtlLibraryDevice', Metal.UIntToLibraryHandle( library_handle ) );
            device_handle = Metal.HandleToUInt( raw_handle );
        end
        
        
        
        function FreeLibrary( library_handle )
            %FreeLibrary Free the library
            %   Free the library referred to by the handle.
            %
            %  Metal.FreeLibrary( library_handle )
            
            if coder.target('MATLAB')
                CoderAPI.RunMex( library_handle );
                return
            end
            
            coder.cinclude( 'MatlabMetal.h' );
            coder.ceval( 'mtlFreeLibrary', Metal.UIntToLibraryHandle( library_handle ) );
        end
        
        
        
        function [ function_handle ] = NewFunction( library_handle, function_name )
            %NewFunction Create a new function from a library
            %  Accepts a library_handle and the function name as a string object.
            %  Returns a function_handle or uint64(0) on error.
            %
            %  [ function_handle ] = Metal.NewFunction( library_handle, function_name )
            
            if coder.target('MATLAB')
                [ function_handle ] = CoderAPI.RunMex( library_handle, function_name );
                return
            end
            
            coder.cinclude( 'MatlabMetal.h' );
            raw_handle = Metal.UIntToFunctionHandle(0);
            char_function = NullTerminateString( function_name );
            raw_handle = coder.ceval( 'mtlNewFunction', Metal.UIntToLibraryHandle( library_handle ), char_function );
            function_handle = Metal.HandleToUInt( raw_handle );
        end
        
        
        
        function FreeFunction( function_handle )
            %FreeFunction Free the function
            %   Free the function referred to by the handle.
            %
            %  Metal.FreeFunction( function_handle )
            
            if coder.target('MATLAB')
                CoderAPI.RunMex( function_handle );
                return
            end
            
            coder.cinclude( 'MatlabMetal.h' );
            coder.ceval( 'mtlFreeFunction', Metal.UIntToFunctionHandle( function_handle ) );
        end
        
        
        
        function [ compute_pipeline_state_handle ] = NewComputePipelineState( device_handle, function_handle )
            %NewComputePipelineState Create a new compute pipeline state
            %  Accepts handles to a device and a function.
            %  Returns a compute_pipeline_state_handle or uint64(0) on error.
            %
            %  [ compute_pipeline_state_handle ] = Metal.NewComputePipelineState( device_handle, function_handle )
            
            if coder.target('MATLAB')
                [ compute_pipeline_state_handle ] = CoderAPI.RunMex( device_handle, function_handle );
                return
            end
            
            coder.cinclude( 'MatlabMetal.h' );
            raw_handle = Metal.UIntToComputePipelineStateHandle(0);
            raw_handle = coder.ceval( 'mtlNewComputePipelineState', ...
                Metal.UIntToDeviceHandle( device_handle ), ...
                Metal.UIntToFunctionHandle( function_handle ) );
            compute_pipeline_state_handle = Metal.HandleToUInt( raw_handle );
        end
        
        
        
        function [ device_handle ] = ComputePipelineStateDevice( compute_pipeline_state_handle )
            %ComputePipelineStateDevice Return the device the compute pipeline state was created on
            %   Return a handle to the device the compute pipeline state
            %   was created on. The handle will be newly created, so must
            %   be freed. Returns a device_handle or uint64(0) on error.
            %
            %  [ device_handle ] = Metal.ComputePipelineStateDevice( compute_pipeline_state_handle )
            
            if coder.target('MATLAB')
                [ device_handle ] = CoderAPI.RunMex( compute_pipeline_state_handle );
                return
            end
            
            coder.cinclude( 'MatlabMetal.h' );
            raw_handle = Metal.UIntToDeviceHandle(0);
            raw_handle = coder.ceval( 'mtlComputePipelineStateDevice', Metal.UIntToComputePipelineStateHandle( compute_pipeline_state_handle ) );
            device_handle = Metal.HandleToUInt( raw_handle );
        end
        
                
        
        
        function [ new_compute_pipeline_state_handle ] = CopyComputePipelineState( compute_pipeline_state_handle )
            %CopyComputePipelineState Copy the compute pipeline state
            %   Copy the compute pipeline state referred to by the handle.
            %
            %  [ new_compute_pipeline_state_handle ] = Metal.CopyComputePipelineState( compute_pipeline_state_handle )
            
            if coder.target('MATLAB')
                [ new_compute_pipeline_state_handle ] = CoderAPI.RunMex( compute_pipeline_state_handle );
                return
            end
            
            raw_handle = Metal.UIntToComputePipelineStateHandle(0);
            coder.cinclude( 'MatlabMetal.h' );
            [ raw_handle ] = coder.ceval( 'mtlCopyComputePipelineState', Metal.UIntToComputePipelineStateHandle( compute_pipeline_state_handle ) );
            new_compute_pipeline_state_handle = Metal.HandleToUInt( raw_handle );
        end
        
        
        
        function [ num_threads ] = ThreadExecutionWidth( compute_pipeline_state_handle )
            %ThreadExecutionWidth Return the number of threads simultaneously executed
            %   Returns the number of simultaneous threads in a SIMD group.
            %
            %  [ num_threads ] = Metal.ThreadExecutionWidth( compute_pipeline_state_handle )
            
            if coder.target('MATLAB')
                [ num_threads ] = CoderAPI.RunMex( compute_pipeline_state_handle );
                return
            end
            
            num_threads_raw = uint32(0);
            coder.cinclude( 'MatlabMetal.h' );
            [ num_threads_raw ] = coder.ceval( 'mtlThreadExecutionWidth', Metal.UIntToComputePipelineStateHandle( compute_pipeline_state_handle ) );
            num_threads = double( num_threads_raw );
        end
        
        
        
        function FreeComputePipelineState( compute_pipeline_state_handle )
            %FreeFunction Free the function
            %   Free the function referred to by the handle.
            %
            %  Metal.FreeFunction( function_handle )
            
            if coder.target('MATLAB')
                CoderAPI.RunMex( compute_pipeline_state_handle );
                return
            end
            
            coder.cinclude( 'MatlabMetal.h' );
            coder.ceval( 'mtlFreeComputePipelineState', Metal.UIntToComputePipelineStateHandle( compute_pipeline_state_handle ) );
        end
        
        
        
        function [ command_queue_handle ] = NewCommandQueue( device_handle )
            %NewCommandQueue Create a new command queue on a device
            %  Accepts a handle to a device 
            %  Returns a command_queue_handle or uint64(0) on error.
            %
            %  [ command_queue_handle ] = Metal.NewCommandQueue( device_handle )
            
            if coder.target('MATLAB')
                [ command_queue_handle ] = CoderAPI.RunMex( device_handle );
                return
            end
            
            coder.cinclude( 'MatlabMetal.h' );
            raw_handle = Metal.UIntToCommandQueueHandle(0);
            raw_handle = coder.ceval( 'mtlNewCommandQueue', ...
                Metal.UIntToDeviceHandle( device_handle ) );
            command_queue_handle = Metal.HandleToUInt( raw_handle );
        end
        
        
        
        function [ device_handle ] = CommandQueueDevice( command_queue_handle )
            %CommandQueueDevice Return the device the command queue was created on
            %   Return a handle to the device the command queue was create on.
            %   The handle will be newly created, so must be freed.
            %   Returns a device_handle or uint64(0) on error.
            %
            %  [ device_handle ] = Metal.CommandQueueDevice( command_queue_handle )
            
            if coder.target('MATLAB')
                [ device_handle ] = CoderAPI.RunMex( command_queue_handle );
                return
            end
            
            coder.cinclude( 'MatlabMetal.h' );
            raw_handle = Metal.UIntToDeviceHandle(0);
            raw_handle = coder.ceval( 'mtlCommandQueueDevice', Metal.UIntToCommandQueueHandle( command_queue_handle ) );
            device_handle = Metal.HandleToUInt( raw_handle );
        end
        
        
        
        function FreeCommandQueue( command_queue_handle )
            %FreeCommandQueue Free the Command Queue
            %   Free the command queue referred to by the handle.
            %
            %  Metal.FreeCommandQueue( command_queue_handle )
            
            if coder.target('MATLAB')
                CoderAPI.RunMex( command_queue_handle );
                return
            end
            
            coder.cinclude( 'MatlabMetal.h' );
            coder.ceval( 'mtlFreeCommandQueue', Metal.UIntToCommandQueueHandle( command_queue_handle ) );
        end
        
        
        
        function [ buffer_handle ] = NewBuffer( device_handle, numbytes )
            %NewBuffer Create a new memory buffer on a device
            %  Accepts a handle to a device and the number of bytes to
            %  allocate.
            %  Returns a buffer_handle or uint64(0) on error.
            %
            %  [ buffer_handle ] = Metal.NewBuffer( device_handle, numbytes )
            
            if coder.target('MATLAB')
                [ buffer_handle ] = CoderAPI.RunMex( device_handle, numbytes );
                return
            end
            
            coder.cinclude( 'MatlabMetal.h' );
            raw_handle = Metal.UIntToBufferHandle(0);
            raw_handle = coder.ceval( 'mtlNewBuffer', ...
                Metal.UIntToDeviceHandle( device_handle ), ...
                uint64( numbytes ) );
            buffer_handle = Metal.HandleToUInt( raw_handle );
        end
        
        
        
        function [ result ] = CopyDataToBuffer( buffer_handle, data )
            %CopyDataToBuffer Copy a uint8 vector into a buffer
            %  Given a handle to a buffer and a vector of uint8 data, will
            %  copy the data into the memory buffer.
            %
            %  Returns uint32(1) on succes, uint32(0) on failure.
            %  [ result ] = Metal.CopyDataToBuffer( buffer_handle, data )
            
            if coder.target('MATLAB')
                [ result ] = CoderAPI.RunMex( buffer_handle, data );
                return
            end
            
            coder.cinclude( 'MatlabMetal.h' );
            result = uint32(0);
            numbytes = uint64( numel( data ) );
            result = coder.ceval('-layout:any', 'mtlCopyDataToBuffer', ...
                Metal.UIntToBufferHandle( buffer_handle ), ...
                coder.rref( data ), ...
                numbytes );
        end
        
        
        
        function [ outdata, result ] = CopyDataFromBuffer( buffer_handle )
            %CopyDataFromBuffer Copy a uint8 vector from a buffer
            %  Given a handle to a buffer will copy the uint8 data from the memory buffer.
            %
            %  result is uint32(1) on succes, uint32(0) on failure.
            %  [ outdata, result ] = Metal.CopyDataFromBuffer( buffer_handle )
            
            if coder.target('MATLAB')
                [ outdata, result ] = CoderAPI.RunMex( buffer_handle );
                return
            end
            
            coder.cinclude( 'MatlabMetal.h' );
            result = uint32(0);
            numbytes = Metal.BufferSize( buffer_handle );
            outdata = coder.nullcopy( zeros( 1, numbytes, 'uint8'));
            result = coder.ceval('-layout:any', 'mtlCopyDataFromBuffer', ...
                Metal.UIntToBufferHandle( buffer_handle ), ...
                coder.wref( outdata ), ...
                uint64( numbytes ) );
        end
        
        
        function [ result ] = CopyUInt16DataToBuffer( buffer_handle, data )
            %CopyUInt16DataToBuffer Copy a uint16 three-dimensional array into a buffer
            %  Given a handle to a buffer and an array of uint16 data, will
            %  copy the data into the memory buffer.
            %
            %  Returns uint32(1) on succes, uint32(0) on failure.
            %  [ result ] = Metal.CopyUInt16DataToBuffer( buffer_handle, data )
            
            if coder.target('MATLAB')
                [ result ] = CoderAPI.RunMex( buffer_handle, data );
                return
            end
            
            coder.cinclude( 'MatlabMetal.h' );
            result = uint32(0);
            numbytes = uint64( numel( data ) * 2 );
            result = coder.ceval('-layout:any', 'mtlCopyDataToBuffer', ...
                Metal.UIntToBufferHandle( buffer_handle ), ...
                coder.rref( data ), ...
                numbytes );
        end
        
        
        
        function [ outdata, result ] = CopyUInt16DataFromBuffer( buffer_handle, dimensions )
            %CopyUInt16DataFromBuffer Copy a three-dimensional uint16 array from a buffer
            %  Given a handle to a buffer and the dimensions of the output
            %  array, will copy the uint16 data from the memory buffer.
            %
            %  Returns uint32(1) on succes, uint32(0) on failure.
            %  [ result ] = Metal.CopyUInt16DataToBuffer( buffer_handle, data )
            
            if coder.target('MATLAB')
                [ outdata, result ] = CoderAPI.RunMex( buffer_handle, dimensions );
                return
            end
            
            coder.cinclude( 'MatlabMetal.h' );
            result = uint32(0);
            outdata = coder.nullcopy( zeros( dimensions, 'uint16'));
            numbytes = uint64( prod( dimensions ) * 2 );
            result = coder.ceval('-layout:any', 'mtlCopyDataFromBuffer', ...
                Metal.UIntToBufferHandle( buffer_handle ), ...
                coder.wref( outdata ), ...
                numbytes );
        end
        
        
        
        function [ result ] = CopySingleDataToBuffer( buffer_handle, data )
            %CopySingleDataToBuffer Copy a float three-dimensional array into a buffer
            %  Given a handle to a buffer and an array of float data, will
            %  copy the data into the memory buffer.
            %
            %  Returns uint32(1) on succes, uint32(0) on failure.
            %  [ result ] = Metal.CopyFloatDataToBuffer( buffer_handle, data )
            
            if coder.target('MATLAB')
                [ result ] = CoderAPI.RunMex( buffer_handle, data );
                return
            end
            
            coder.cinclude( 'MatlabMetal.h' );
            result = uint32(0);
            numbytes = uint64( numel( data ) * 4 );
            result = coder.ceval('-layout:any', 'mtlCopyDataToBuffer', ...
                Metal.UIntToBufferHandle( buffer_handle ), ...
                coder.rref( data ), ...
                numbytes );
        end
        
        
        
        function [ outdata, result ] = CopySingleDataFromBuffer( buffer_handle, dimensions )
            %CopySingleDataFromBuffer Copy a three-dimensional single array from a buffer
            %  Given a handle to a buffer and the dimensions of the output
            %  array, will copy the float data from the memory buffer.
            %
            %  Returns uint32(1) on succes, uint32(0) on failure.
            %  [ result ] = Metal.CopyFloatDataToBuffer( buffer_handle, data )
            
            if coder.target('MATLAB')
                [ outdata, result ] = CoderAPI.RunMex( buffer_handle, dimensions );
                return
            end
            
            coder.cinclude( 'MatlabMetal.h' );
            result = uint32(0);
            outdata = coder.nullcopy( zeros( dimensions, 'single'));
            numbytes = uint64( prod( dimensions ) * 4 );
            result = coder.ceval('-layout:any', 'mtlCopyDataFromBuffer', ...
                Metal.UIntToBufferHandle( buffer_handle ), ...
                coder.wref( outdata ), ...
                numbytes );
        end
        
        
        
        function numbytes = BufferSize( buffer_handle )
            %BufferSize Determine the size of the buffer in bytes
            %   Return the size of the buffer in bytes. Returns 0 bytes on
            %   error.
            %
            %  numbytes = Metal.BufferSize( buffer_handle )
            
            if coder.target('MATLAB')
                numbytes = CoderAPI.RunMex( buffer_handle );
                return
            end
            
            coder.cinclude( 'MatlabMetal.h' );
            returnval = uint64(0);
            returnval = coder.ceval( 'mtlBufferSize', Metal.UIntToBufferHandle( buffer_handle ) );
            numbytes = double( returnval );
        end
        
        
        
        function [ device_handle ] = BufferDevice( buffer_handle )
            %BufferDevice Return the device the buffer was created on
            %   Return a handle to the device the buffer was create on.
            %   The handle will be newly created, so must be freed.
            %   Returns a device_handle or uint64(0) on error.
            %
            %  [ device_handle ] = Metal.BufferDevice( buffer_handle )
            
            if coder.target('MATLAB')
                [ device_handle ] = CoderAPI.RunMex( buffer_handle );
                return
            end
            
            coder.cinclude( 'MatlabMetal.h' );
            raw_handle = Metal.UIntToDeviceHandle(0);
            raw_handle = coder.ceval( 'mtlBufferDevice', Metal.UIntToBufferHandle( buffer_handle ) );
            device_handle = Metal.HandleToUInt( raw_handle );
        end
        
     
        
        function FreeBuffer( buffer_handle )
            %FreeBuffer Free the buffer
            %   Free the buffer referred to by the handle.
            %
            %  Metal.FreeBuffer( buffer_handle )
            coder.cinclude( 'MatlabMetal.h' );
            if buffer_handle == Metal.InvalidHandle
                return
            end
            
            if coder.target('MATLAB')
                CoderAPI.RunMex( buffer_handle );
                return
            end
            
            
            coder.ceval( 'mtlFreeBuffer', Metal.UIntToBufferHandle( buffer_handle ) );
        end
        
        
        
        function [ command_buffer_handle ] = NewCommandBuffer( command_queue_handle )
            %NewCommandBuffer Create a new command buffer for a command queue
            %  Accepts a handle to a command queue.
            %  Returns a command_buffer_handle or uint64(0) on error.
            %
            %  [ buffer_handle ] = Metal.NewCommandBuffer( command_queue_handle )
            
            if coder.target('MATLAB')
                [ command_buffer_handle ] = CoderAPI.RunMex( command_queue_handle );
                return
            end
            
            coder.cinclude( 'MatlabMetal.h' );
            raw_handle = Metal.UIntToCommandBufferHandle(0);
            raw_handle = coder.ceval( 'mtlNewCommandBuffer', ...
                Metal.UIntToCommandQueueHandle( command_queue_handle ) );
            command_buffer_handle = Metal.HandleToUInt( raw_handle );
        end
        
        
        
        function [ device_handle ] = CommandBufferDevice( command_buffer_handle )
            %CommandBufferDevice Return the device the command buffer was created on
            %   Return a handle to the device the command buffer was created on.
            %   The handle will be newly created, so must be freed.
            %   Returns a device_handle or uint64(0) on error.
            %
            %  [ device_handle ] = Metal.CommandBufferDevice( command_buffer_handle )
            
            if coder.target('MATLAB')
                [ device_handle ] = CoderAPI.RunMex( command_buffer_handle );
                return
            end
            
            coder.cinclude( 'MatlabMetal.h' );
            raw_handle = Metal.UIntToDeviceHandle(0);
            raw_handle = coder.ceval( 'mtlCommandBufferDevice', Metal.UIntToCommandBufferHandle( command_buffer_handle ) );
            device_handle = Metal.HandleToUInt( raw_handle );
        end
        
        
        function [ new_command_buffer_handle ] = CopyCommandBuffer( command_buffer_handle )
            %CopyCommandBuffer Copy a command buffer
            %   Copy the command buffer referred to by the handle.
            %
            %  new_command_buffer_handle = Metal.CopyCommandBuffer( command_buffer_handle )
            if coder.target('MATLAB')
                [ new_command_buffer_handle ] = CoderAPI.RunMex( command_buffer_handle );
                return
            end
            
            coder.cinclude( 'MatlabMetal.h' );
            raw_handle = Metal.UIntToCommandBufferHandle(0);
            raw_handle = coder.ceval( 'mtlCopyCommandBuffer', Metal.UIntToCommandBufferHandle( command_buffer_handle ) );
            new_command_buffer_handle = Metal.HandleToUInt( raw_handle );
        end
        
     
        
        function FreeCommandBuffer( command_buffer_handle )
            %FreeCommandBuffer Free the command buffer
            %   Free the command buffer referred to by the handle.
            %
            %  Metal.FreeCommandBuffer( command_buffer_handle )
            
            coder.cinclude( 'MatlabMetal.h' );
            if command_buffer_handle == Metal.InvalidHandle
                return
            end
            
            if coder.target('MATLAB')
                CoderAPI.RunMex( command_buffer_handle );
                return
            end
            coder.ceval( 'mtlFreeCommandBuffer', Metal.UIntToCommandBufferHandle( command_buffer_handle ) );
        end
        
        
        
        function result = CommitCommandBuffer( command_buffer_handle )
            %CommitCommandBuffer Commit the command buffer for processing
            %   Commit the command buffer referred to by the handle to the
            %   pipeline for processing. Returns uint32(1) on success,
            %   uint32(0) on error.
            %
            %  result = Metal.CommitCommandBuffer( command_buffer_handle )
            if coder.target('MATLAB')
                result = CoderAPI.RunMex( command_buffer_handle );
                return
            end
            
            coder.cinclude( 'MatlabMetal.h' );
            result = uint32(0);
            result = coder.ceval( 'mtlCommitCommandBuffer', Metal.UIntToCommandBufferHandle( command_buffer_handle ) );
        end
        
        
        function result = WaitForCompletion( command_buffer_handle )
            %WaitForCompletion Wait for a command buffer to finish processing
            %   Wait for the command buffer referred to by the handle to
            %   finish processing. Returns uint32(1) on success, uint32(0)
            %   on error.
            %
            %  result = Metal.WaitForCompletion( command_buffer_handle )
            if coder.target('MATLAB')
                result = CoderAPI.RunMex( command_buffer_handle );
                return
            end
            
            coder.cinclude( 'MatlabMetal.h' );
            result = uint32(0);
            result = coder.ceval( 'mtlWaitForCompletion', Metal.UIntToCommandBufferHandle( command_buffer_handle ) );
        end
        
        
        
        function [ command_encoder_handle ] = NewCommandEncoder( command_buffer_handle )
            %NewCommandEncoder Create a new command buffer for a command queue
            %  Accepts a handle to a command queue.
            %  Returns a command_buffer_handle or uint64(0) on error.
            %
            %  [ command_encoder_handle ] = Metal.NewCommandEncoder( command_buffer_handle )
            
            if coder.target('MATLAB')
                [ command_encoder_handle ] = CoderAPI.RunMex( command_buffer_handle );
                return
            end
            
            coder.cinclude( 'MatlabMetal.h' );
            raw_handle = Metal.UIntToCommandEncoderHandle(0);
            raw_handle = coder.ceval( 'mtlNewCommandEncoder', ...
                Metal.UIntToCommandBufferHandle( command_buffer_handle ) );
            command_encoder_handle = Metal.HandleToUInt( raw_handle );
        end
     
     
        
        function FreeCommandEncoder( command_encoder_handle )
            %FreeCommandEncoder Free the command encoder
            %   Free the command encoder referred to by the handle.
            %
            %  NOTE: It is essential that Metal.EndEncoding be called
            %  exactly once prior to freeing the encoder otherwise a
            %  segfault may occur.
            %
            %  Metal.FreeCommandEncoder( command_encoder_handle )
            coder.cinclude( 'MatlabMetal.h' );
            if command_encoder_handle == Metal.InvalidHandle
                return
            end
            
            if coder.target('MATLAB')
                CoderAPI.RunMex( command_encoder_handle );
                return
            end
            
            
            coder.ceval( 'mtlFreeCommandEncoder', Metal.UIntToCommandEncoderHandle( command_encoder_handle ) );
        end
        
        
        
        function result = SetComputePipelineState( command_encoder_handle, compute_pipeline_state )
            %SetComputePipelineState Set the compute pipeline state for the command buffer
            %   Set the compute pipeline state to use for processing.
            %   Returns uint32(1) on success, uint32(0) on error.
            %
            %  result = Metal.SetComputePipelineState( command_encoder_handle, compute_pipeline_state )
            if coder.target('MATLAB')
                result = CoderAPI.RunMex( command_encoder_handle, compute_pipeline_state );
                return
            end
            
            coder.cinclude( 'MatlabMetal.h' );
            result = uint32(0);
            result = coder.ceval( 'mtlSetComputePipelineState', ...
                Metal.UIntToCommandEncoderHandle( command_encoder_handle ), ...
                Metal.UIntToComputePipelineStateHandle( compute_pipeline_state ) );
        end
        
        
        function result = SetBuffer( command_encoder_handle, buffer_handle, index )
            %SetBuffer Set a buffer for the command buffer to use
            %   Set a buffer to be used by the command buffer as well as
            %   its position in the call (one-based). Returns uint32(1) on success,
            %   uint32(0) on error.
            %
            %  result = Metal.SetBuffer( command_encoder_handle, buffer_handle, index )
            if coder.target('MATLAB')
                result = CoderAPI.RunMex( command_encoder_handle, buffer_handle, index );
                return
            end
            
            coder.cinclude( 'MatlabMetal.h' );
            result = uint32(0);
            result = coder.ceval( 'mtlSetBuffer', ...
                Metal.UIntToCommandEncoderHandle( command_encoder_handle ), ...
                Metal.UIntToBufferHandle( buffer_handle ), ...
                uint32(index-1) );
        end
        
                
        
        function result = SetThreadsAndShape( command_encoder_handle, compute_pipeline_state_handle, dims )
            %SetThreadsAndShape Set the number of threads and the shape of the thread processing. 
            %  Needs the dimensions of the buffers to be processed (as a
            %  double vector). Returns uint32(1) on success, uint32(0) on
            %  error.
            %
            %  result = Metal.SetThreadsAndShape( command_encoder_handle, buffer_handle, dims )
            if coder.target('MATLAB')
                result = CoderAPI.RunMex( command_encoder_handle, compute_pipeline_state_handle, dims );
                return
            end
            
            dims_pad = [ 1 1 1 ];
            dims_pad( 1 : min(end, numel( dims )) ) = dims( 1 : min( end, 3 ));
            
            coder.cinclude( 'MatlabMetal.h' );
            result = uint32(0);
            result = coder.ceval( 'mtlSetThreadsAndShape', ...
                Metal.UIntToCommandEncoderHandle( command_encoder_handle ), ...
                Metal.UIntToComputePipelineStateHandle( compute_pipeline_state_handle ), ...
                uint32(dims_pad(1)), uint32(dims_pad(2)), uint32(dims_pad(3)) );
        end
        
        
        
        function result = EndEncoding( command_encoder_handle )
            %EndEncoding End encoding the commands
            %   End encoding of the command buffer
            %
            %  Metal.EndEncoding( command_encoder_handle )
            if coder.target('MATLAB')
                result = CoderAPI.RunMex( command_encoder_handle );
                return
            end
            
            coder.cinclude( 'MatlabMetal.h' );
            result = uint32(0);
            result = coder.ceval( 'mtlEndEncoding', Metal.UIntToCommandEncoderHandle( command_encoder_handle ) );
        end
        
    end
    
    
end
    
