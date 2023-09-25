classdef testMetal < matlab.unittest.TestCase
    
    methods (TestClassSetup)
        function OnlyRunIfHasMetal( testCase )
            config = Metal.Config;
            testCase.assumeTrue( ~isempty( config.gpuoptions ) );
        end
    end
    
    
    properties ( TestParameter )
        TestSource = { ...
            struct(...
            "source", ...
            "#include <metal_stdlib>" + newline + ...
            "using namespace metal;" + newline + ...
            "" + newline + ...
            "kernel void sqr(" + newline + ...
            "    const device float *vIn [[ buffer(0) ]]," + newline + ...
            "    device float *vOut [[ buffer(1) ]]," + newline + ...
            "    uint id[[ thread_position_in_grid ]])" + newline + ...
            "{" + newline + ...
            "    vOut[id] = vIn[id] * vIn[id];" + newline + ...
            "}" + newline, ...
            "isValid", true, ...
            "functionName", "sqr" ), ...
            struct(...
            "source", ...
            "#include <metal_stdlib>" + newline + ...
            "using namespace metal" + newline + ... %Missing semicolon
            "" + newline + ...
            "kernel void sqr(" + newline + ...
            "    const device float *vIn [[ buffer(0) ]]," + newline + ...
            "    device float *vOut [[ buffer(1) ]]," + newline + ...
            "    uint id[[ thread_position_in_grid ]])" + newline + ...
            "{" + newline + ...
            "    vOut[id] = vIn[id] * vIn[id];" + newline + ...
            "}" + newline, ...
            "isValid", false, ...
            "functionName", "sqr" ) ...
            }
    end
    
    
    methods (Test)
        
        function testListingDevices( testCase )
            numDevices = Metal.NumberOfDevices();
            testCase.verifyGreaterThan( numDevices, 0);
            
            [ Devices, result ] = Metal.GetDeviceInfoArray();
            testCase.verifyEqual( numel(Devices), numDevices);
            testCase.verifyEqual( result, uint32(1));
        end
        
        
        function testDeviceHandles( testCase )
            numDevices = Metal.NumberOfDevices();
            testCase.verifyGreaterThan( numDevices, 0 );
            
            device = Metal.GetDeviceAtIndex( numDevices );
            testCase.verifyGreaterThan( device, 0 );
            
            device2 = Metal.GetDeviceAtIndex( numDevices );
            testCase.verifyGreaterThan( device2, 0 );
            testCase.verifyNotEqual( device, device2 );
            testCase.verifyTrue( Metal.IsSameDevice( device, device2) );
            
            invalid_device = Metal.GetDeviceAtIndex( numDevices + 1 );
            testCase.verifyEqual( invalid_device, uint64(0) );
            
            errormessage = Metal.LastError;
            testCase.verifyEqual( errormessage, "Index out of bounds");
            
            allocatedMemory = Metal.GetDeviceAllocatedMemory( device );
            testCase.verifyGreaterThan( allocatedMemory, 0);
            
            Metal.FreeDevice( device );
            Metal.FreeDevice( device2 );
            
        end
        
        
        function testLibraryCreation( testCase, TestSource )
            numDevices = Metal.NumberOfDevices();
            testCase.verifyGreaterThan( numDevices, 0 );
            
            device = Metal.GetDeviceAtIndex( numDevices );
            testCase.verifyGreaterThan( device, 0, Metal.LastError );
            
            library = Metal.NewLibrary( device, TestSource.source);
            if TestSource.isValid
                testCase.verifyGreaterThan( library, 0, Metal.LastError );
                device2 = Metal.LibraryDevice( library );
                testCase.verifyTrue( Metal.IsSameDevice( device, device2 ) );
                Metal.FreeDevice( device2 );
            else
                testCase.verifyEqual( library, uint64(0) );
                testCase.verifyTrue( contains( Metal.LastError, "expected ';'") );
            end
            
            Metal.FreeDevice( device );
            Metal.FreeLibrary( library );
        end
        
        
        function testFunctionCreation( testCase, TestSource )
            
            if ~TestSource.isValid
                return
            end

            device = Metal.GetDeviceAtIndex( 1 );
            testCase.verifyGreaterThan( device, 0, Metal.LastError );

            library = Metal.NewLibrary( device, TestSource.source);
            testCase.verifyGreaterThan( library, 0, Metal.LastError );
            
            func = Metal.NewFunction( library, TestSource.functionName );
            testCase.verifyGreaterThan( func, 0, Metal.LastError );
            
            invalid_func = Metal.NewFunction( library, TestSource.functionName + "z" );
            testCase.verifyEqual( invalid_func, uint64(0) );

            Metal.FreeFunction( func );
            Metal.FreeLibrary( library );
            Metal.FreeDevice( device );
            
        end
        
        function testComputePipelineState( testCase, TestSource )
            if ~TestSource.isValid
                return
            end
            
            device = Metal.GetDeviceAtIndex( 1 );
            testCase.verifyGreaterThan( device, 0, Metal.LastError );
            
            library = Metal.NewLibrary( device, TestSource.source);
            testCase.verifyGreaterThan( library, 0, Metal.LastError );
            
            func = Metal.NewFunction( library, TestSource.functionName );
            testCase.verifyGreaterThan( func, 0, Metal.LastError );
            
            compute_pipeline_state = Metal.NewComputePipelineState( device, func );
            testCase.verifyGreaterThan( compute_pipeline_state, 0, Metal.LastError );
            device2 = Metal.ComputePipelineStateDevice( compute_pipeline_state );
            testCase.verifyTrue( Metal.IsSameDevice( device, device2 ) );
            Metal.FreeDevice( device2 );
            
            Metal.FreeComputePipelineState( compute_pipeline_state );
            Metal.FreeFunction( func );
            Metal.FreeLibrary( library );
            Metal.FreeDevice( device );
            
        end
        
        
        function testCommandQueue( testCase )
            device = Metal.GetDeviceAtIndex( 1 );
            command_queue = Metal.NewCommandQueue( device );
            testCase.verifyGreaterThan( command_queue, 0, Metal.LastError );
            device2 = Metal.CommandQueueDevice( command_queue );
            testCase.verifyTrue( Metal.IsSameDevice( device, device2 ) );
            
            Metal.FreeCommandQueue( command_queue );
            Metal.FreeDevice( device  );
            Metal.FreeDevice( device2 );
        end
        
        
                
        
        function testBufferUInt8( testCase  )
            device = Metal.GetDeviceAtIndex( 1 );
            testdata = randi(256, [1, 300000], 'uint8');
            
            buffer = Metal.NewBuffer( device, numel(testdata) );
            testCase.verifyGreaterThan( buffer, 0, Metal.LastError );
            testCase.verifyEqual( Metal.BufferSize( buffer ), numel(testdata));
            device2 = Metal.BufferDevice( buffer );
            testCase.verifyTrue( Metal.IsSameDevice( device, device2 ) );
            Metal.FreeDevice( device2 );
            
            toobigdata = randi( 256, [1 numel(testdata)+1], 'uint8');
            result = Metal.CopyDataToBuffer( buffer, toobigdata );
            testCase.verifyEqual( result, uint32(0) );
            
            result = Metal.CopyDataToBuffer( buffer, testdata );
            testCase.verifyEqual( result, uint32(1), Metal.LastError);
            
            [ returndata, result ] = Metal.CopyDataFromBuffer( buffer );
            testCase.verifyEqual( result, uint32(1), Metal.LastError);
            testCase.verifyEqual( testdata, returndata );
            
            Metal.FreeBuffer( buffer  );
            testCase.verifyEqual( Metal.BufferSize( buffer ), 0);
            Metal.FreeDevice( device );
        end
        
                
        
        function testBufferUInt16( testCase  )
            device = Metal.GetDeviceAtIndex( 1 );
            testdata = randi(65535, [1000, 1000, 3], 'uint16');
            
            buffer = Metal.NewBuffer( device, numel(testdata) * 2 );
            testCase.verifyGreaterThan( buffer, 0, Metal.LastError );
            testCase.verifyEqual( Metal.BufferSize( buffer ), numel(testdata)*2);
            device2 = Metal.BufferDevice( buffer );
            testCase.verifyTrue( Metal.IsSameDevice( device, device2 ) );
            Metal.FreeDevice( device2 );
            
            toobigdata = randi( 65535, size(testdata)+1, 'uint16');
            result = Metal.CopyUInt16DataToBuffer( buffer, toobigdata );
            testCase.verifyEqual( result, uint32(0) );
            
            result = Metal.CopyUInt16DataToBuffer( buffer, testdata );
            testCase.verifyEqual( result, uint32(1), Metal.LastError);
            
            [ returndata, result ] = Metal.CopyUInt16DataFromBuffer( buffer, size(testdata));
            testCase.verifyEqual( result, uint32(1), Metal.LastError);
            testCase.verifyEqual( testdata, returndata );
            
            Metal.FreeBuffer( buffer  );
            testCase.verifyEqual( Metal.BufferSize( buffer ), 0);
            Metal.FreeDevice( device );
        end
        
        
        function testBufferSingle( testCase  )
            device = Metal.GetDeviceAtIndex( 1 );
            testdata = rand( 1000, 1000, 3, 'single');
            
            buffer = Metal.NewBuffer( device, numel(testdata) * 4 );
            testCase.verifyGreaterThan( buffer, 0, Metal.LastError );
            testCase.verifyEqual( Metal.BufferSize( buffer ), numel(testdata)*4);
            device2 = Metal.BufferDevice( buffer );
            testCase.verifyTrue( Metal.IsSameDevice( device, device2 ) );
            Metal.FreeDevice( device2 );
            
            toobigdata = rand( size(testdata)+1, 'single');
            result = Metal.CopySingleDataToBuffer( buffer, toobigdata );
            testCase.verifyEqual( result, uint32(0) );
            
            result = Metal.CopySingleDataToBuffer( buffer, testdata );
            testCase.verifyEqual( result, uint32(1), Metal.LastError);
            
            [ returndata, result ] = Metal.CopySingleDataFromBuffer( buffer, size(testdata));
            testCase.verifyEqual( result, uint32(1), Metal.LastError);
            testCase.verifyEqual( testdata, returndata );
            
            Metal.FreeBuffer( buffer  );
            testCase.verifyEqual( Metal.BufferSize( buffer ), 0);
            Metal.FreeDevice( device );
        end
        
        
        function testCommandBuffers( testCase )
            device = Metal.GetDeviceAtIndex( 1 );
            command_queue = Metal.NewCommandQueue( device );
            testCase.verifyGreaterThan( command_queue, 0, Metal.LastError );
            
            command_buffer = Metal.NewCommandBuffer( command_queue );
            testCase.verifyGreaterThan( command_buffer, 0, Metal.LastError );
            
            device2 = Metal.CommandBufferDevice( command_buffer );
            testCase.verifyTrue( Metal.IsSameDevice( device, device2 ) );
            
            Metal.FreeCommandBuffer( command_buffer );
            Metal.FreeCommandQueue( command_queue );
            Metal.FreeDevice( device  );
            Metal.FreeDevice( device2 );
        end
        
        
        function testCommandEncoders( testCase )
            device = Metal.GetDeviceAtIndex( 1 );
            command_queue = Metal.NewCommandQueue( device );
            testCase.verifyGreaterThan( command_queue, 0, Metal.LastError );
            
            command_buffer = Metal.NewCommandBuffer( command_queue );
            testCase.verifyGreaterThan( command_buffer, 0, Metal.LastError );
            
            command_encoder = Metal.NewCommandEncoder( command_buffer );
            testCase.verifyGreaterThan( command_encoder, 0, Metal.LastError );
            
            Metal.EndEncoding( command_encoder );
            Metal.FreeCommandEncoder( command_encoder );
            Metal.FreeCommandBuffer( command_buffer );
            Metal.FreeCommandQueue( command_queue );
            Metal.FreeDevice( device  );
        end
        
        
        function testProcessing( testCase, TestSource )
            
            if ~TestSource.isValid
                return
            end
            
            % Compile the source and create the function
            device = Metal.GetDeviceAtIndex( 1 );
            testCase.verifyGreaterThan( device, 0, Metal.LastError );
            
            library = Metal.NewLibrary( device, TestSource.source);
            testCase.verifyGreaterThan( library, 0, Metal.LastError );
            
            func = Metal.NewFunction( library, TestSource.functionName );
            testCase.verifyGreaterThan( func, 0, Metal.LastError );
            
            compute_pipeline_state = Metal.NewComputePipelineState( device, func );
            testCase.verifyGreaterThan( compute_pipeline_state, 0, Metal.LastError );

            command_queue = Metal.NewCommandQueue( device );
            testCase.verifyGreaterThan( command_queue, 0, Metal.LastError );
            
            
            % Create the data buffers and load test data into one of them.
            testdata = rand([ 5000, 5000, 3 ], 'single');
            input_buffer = Metal.NewBuffer( device, numel(testdata) * 4 );
            testCase.verifyGreaterThan( input_buffer, 0, Metal.LastError );
            result = Metal.CopySingleDataToBuffer( input_buffer, testdata );
            testCase.verifyEqual( result, uint32(1), Metal.LastError);
            output_buffer = Metal.NewBuffer( device, numel(testdata) * 4 );
            testCase.verifyGreaterThan( output_buffer, 0, Metal.LastError );
            

            % Create the command buffer and command encoder
            command_buffer = Metal.NewCommandBuffer( command_queue );
            testCase.verifyGreaterThan( command_buffer, 0, Metal.LastError );
            
            command_encoder = Metal.NewCommandEncoder( command_buffer );
            testCase.verifyGreaterThan( command_encoder, 0, Metal.LastError );

            % Encode the commands
            result = Metal.SetComputePipelineState( command_encoder, compute_pipeline_state );
            testCase.verifyEqual( result, uint32(1), Metal.LastError);
            result = Metal.SetBuffer( command_encoder, input_buffer, 1 );
            testCase.verifyEqual( result, uint32(1), Metal.LastError);
            result = Metal.SetBuffer( command_encoder, output_buffer, 2 );
            testCase.verifyEqual( result, uint32(1), Metal.LastError);
            result = Metal.SetThreadsAndShape( command_encoder, compute_pipeline_state, numel( testdata )  );
            testCase.verifyEqual( result, uint32(1), Metal.LastError);
            result = Metal.EndEncoding( command_encoder );
            testCase.verifyEqual( result, uint32(1), Metal.LastError);
            
            % Commit the command buffer and wait for completion
            result = Metal.CommitCommandBuffer( command_buffer );
            testCase.verifyEqual( result, uint32(1), Metal.LastError);
            result = Metal.WaitForCompletion( command_buffer );
            testCase.verifyEqual( result, uint32(1), Metal.LastError);
            
            % Get the returned data and check.
            [ returndata, result ] = Metal.CopySingleDataFromBuffer( output_buffer, size(testdata));
            testCase.verifyEqual( result, uint32(1), Metal.LastError);
            testCase.verifyEqual( returndata, testdata.^2 );
            
            % Free all resources used
            Metal.FreeCommandEncoder( command_encoder );
            Metal.FreeCommandBuffer( command_buffer );
            Metal.FreeBuffer( output_buffer );
            Metal.FreeBuffer( input_buffer );
            Metal.FreeCommandQueue( command_queue );
            Metal.FreeComputePipelineState( compute_pipeline_state );
            Metal.FreeFunction( func );
            Metal.FreeLibrary( library );
            Metal.FreeDevice( device );
            
        end
        
        
        
    end
    
end