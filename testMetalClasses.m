classdef testMetalClasses < matlab.unittest.TestCase
    
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
        
        function testDevice( testCase )
            numDevices = Metal.NumberOfDevices;
            for i =  1:numDevices
                device = MetalDevice( i );
                testCase.verifyTrue( device.isValid );
                device2 = MetalDevice( i );
                testCase.verifyTrue( device2.isValid );
                device3 = MetalDevice( device2 );
                
                % Test that the isequal overload works to identify the
                % physical devices are the same.
                testCase.verifyEqual( device, device2 );
                
                % Verify the device object handles are different.
                testCase.verifyNotEqual( device.handle, device2.handle );
                
                % Test that the isequal overload works to identify the
                % physical copied device is the same even after free.
                testCase.verifyEqual( device, device3 );
                
                % Verify the device object handles are different.
                testCase.verifyNotEqual( device.handle, device3.handle );
            end
            device = MetalDevice( 0 );
            testCase.verifyFalse( device.isValid );
            device = MetalDevice( numDevices + 1 );
            testCase.verifyFalse( device.isValid );
        end

        function testCurrentDevice( testCase )
            metalconfig = Metal.Config;
            numdevices = size( metalconfig.gpuoptions, 1 );
            for i = 1:numdevices
                metalconfig.gpuoptionindex = i;
                device1 = MetalDevice( MetalDevice.CurrentDevice );
                for j = 1:numdevices
                    metalconfig.gpuoptionindex = j;
                    device2 = MetalDevice( MetalDevice.CurrentDevice );
                    testCase.assertEqual( device1.isequal( device2 ), i == j );

                end
            end

        end
        
        
        function testLibrary( testCase, TestSource )

            for i = 1 : Metal.NumberOfDevices
                device = MetalDevice( i );
                library = MetalLibrary( device, TestSource.source );
                testCase.verifyEqual( TestSource.isValid, library.isValid);
                if ~library.isValid
                    continue
                end
                device2 = library.device;
                testCase.verifyNotEqual( device.handle, device2.handle );
                testCase.verifyEqual( device, device2 );
            end
            
        end
        
        
        function testFunction( testCase, TestSource )
            
            if ~TestSource.isValid
                return
            end
            
            device = MetalDevice( 1 );
            library = MetalLibrary( device, TestSource.source );
            func = MetalFunction( library, TestSource.functionName );
            testCase.verifyTrue( func.isValid );
            
            func = MetalFunction( library, TestSource.functionName + "z" );
            testCase.verifyFalse( func.isValid );
            testCase.verifyEqual( func.message, "Library invalid or function name incorrect" );
        end
        
        
        function testComputePipelineState( testCase, TestSource )
            if ~TestSource.isValid
                return
            end
            
            device = MetalDevice( 1 );
            library = MetalLibrary( device, TestSource.source );
            func = MetalFunction( library, TestSource.functionName );
            compute_pipeline_state = MetalComputePipelineState( device, func );
            testCase.verifyTrue( compute_pipeline_state.isValid );
            device2 = compute_pipeline_state.device;
            testCase.verifyEqual( device, device2 );
        end
        
        
        function testCommandQueue( testCase )
            device = MetalDevice( 1 );
            command_queue = MetalCommandQueue( device );
            testCase.verifyTrue( command_queue.isValid );
            device2 = command_queue.device;
            testCase.verifyEqual( device, device2 );
        end
        
        
        function testBufferUInt16( testCase )
            device = MetalDevice( 1 );
            testdata = randi(65535, [1000, 1000, 3], 'uint16');
            
            buffer = MetalBuffer( device, testdata );
            testCase.verifyTrue( buffer.isValid );
            testCase.verifyEqual( buffer.numbytes, numel( testdata ) * 2 );
            
            testCase.verifyEqual( buffer.device, device );
            
            outdata = uint16( buffer );
            testCase.verifyEqual( outdata, testdata );
            
            outdata = single( buffer );
            testCase.verifyEqual( outdata, single(testdata));
            
            buffer2 = MetalBuffer( device, buffer ); % Test the copy constructor
            outdata = uint16( buffer2 );
            testCase.verifyEqual( outdata, testdata );
            
        end
        
        
        function testBufferSingle( testCase )
            device = MetalDevice( 1 );
            testdata = rand(1000, 1000, 3, 'single');
            
            buffer = MetalBuffer( device, testdata );
            testCase.verifyTrue( buffer.isValid );
            testCase.verifyEqual( buffer.numbytes, numel( testdata ) * 4 );
            
            testCase.verifyEqual( buffer.device, device );

            outdata = single( buffer );
            testCase.verifyEqual( outdata, testdata );
            
            outdata = uint16( buffer );
            testCase.verifyEqual( outdata, uint16( testdata ) );
            
            buffer2 = MetalBuffer( device, buffer ); % Test the copy constructor
            outdata= single( buffer2 );
            testCase.verifyEqual( outdata, testdata );
            
        end
        
        
        function testBufferMove( testCase )
            device = MetalDevice( 1 );
            testdata = rand(1000, 1000, 3, 'single');
            
            buffer = MetalBuffer( device, testdata );
            testCase.verifyTrue( buffer.isValid );
            
            buffer.device = device;
            testCase.verifyTrue( buffer.isValid );
            testCase.verifyTrue( buffer.device.isequal( device ));
            outdata = single( buffer );
            testCase.verifyEqual( outdata, testdata );
            
            
            if ~MetalDevice(2).isValid  %The second part of the test only works if we have two devices
                return
            end
            
            newdevice = MetalDevice(2);
            
            buffer.device = newdevice;
            testCase.verifyTrue( buffer.isValid );
            testCase.verifyTrue( buffer.device.isequal( newdevice ));
            
            outdata = single( buffer );
            testCase.verifyEqual( outdata, testdata );

        end
        
        
        function testBufferEmpty( testCase )
            device = MetalDevice( 1 );
            
            dimensions = [5000, 5000, 3];
            buffer = MetalBuffer( device, dimensions );
            testCase.verifyTrue( buffer.isValid );
            testCase.verifyEqual( buffer.numbytes, prod( dimensions ) * 4 );
            testCase.verifyEqual( buffer.dimensions, dimensions );
            
            dimensions = [5000, 5000, 3];
            buffer = MetalBuffer( device, dimensions, 'single' );
            testCase.verifyTrue( buffer.isValid );
            testCase.verifyEqual( buffer.numbytes, prod( dimensions ) * 4 );
            testCase.verifyEqual( buffer.dimensions, dimensions );
            
            dimensions = [5000, 5000, 3];
            buffer = MetalBuffer( device, dimensions, 'uint16' );
            testCase.verifyTrue( buffer.isValid );
            testCase.verifyEqual( buffer.numbytes, prod( dimensions ) * 2 );
            testCase.verifyEqual( buffer.dimensions, dimensions );
            
            dimensions = 5000;
            buffer = MetalBuffer( device, dimensions, 'uint16' );
            testCase.verifyTrue( buffer.isValid );
            testCase.verifyEqual( buffer.numbytes, prod( dimensions ) * 2 );
            testCase.verifyEqual( buffer.dimensions(1), dimensions );
            
        end
        
        
        function testCommandBuffer( testCase )
            device = MetalDevice( 1 );
            command_queue = MetalCommandQueue( device );
            testCase.verifyTrue( command_queue.isValid );
            command_buffer = MetalCommandBuffer( command_queue );
            testCase.verifyTrue( command_buffer.isValid );
            device2 = command_buffer.device;
            testCase.verifyEqual( device, device2 );
        end
        
                    
        
        function testCommandEncoder( testCase )
            device = MetalDevice( 1 );
            command_queue = MetalCommandQueue( device );
            testCase.verifyTrue( command_queue.isValid );
            command_buffer = MetalCommandBuffer( command_queue );
            testCase.verifyTrue( command_buffer.isValid );
            command_encoder = MetalCommandEncoder( command_buffer );
            testCase.verifyTrue( command_encoder.isValid );
        end
        
        
        
        function testProcessing( testCase, TestSource )
            if ~TestSource.isValid
                return
            end
            
            device = MetalDevice( 1 );
            library = MetalLibrary( device, TestSource.source );
            func = MetalFunction( library, TestSource.functionName );
            compute_pipeline_state = MetalComputePipelineState( device, func );
            testCase.verifyTrue( compute_pipeline_state.isValid );
            
            testdata = rand([ 5000, 5000, 3 ], 'single');
            input_buffer = MetalBuffer(device, testdata );
            output_buffer = MetalBuffer(device, size(testdata), 'single' );
            
            command_queue = MetalCommandQueue( device );
            testCase.verifyTrue( command_queue.isValid );
            command_buffer = MetalCommandBuffer( command_queue );
            testCase.verifyTrue( command_buffer.isValid );
            command_encoder = MetalCommandEncoder( command_buffer );
            testCase.verifyTrue( command_encoder.isValid );
            
            result = command_encoder.SetComputePipelineState( compute_pipeline_state );
            testCase.verifyEqual( result, uint32(1));
            result = command_encoder.SetBuffer( input_buffer, 1);
            testCase.verifyEqual( result, uint32(1));
            result = command_encoder.SetBuffer( output_buffer, 2);
            testCase.verifyEqual( result, uint32(1));
            result = command_encoder.SetThreadsAndShape( compute_pipeline_state, numel(testdata));
            testCase.verifyEqual( result, uint32(1));
            result = command_encoder.EndEncoding;
            testCase.verifyEqual( result, uint32(1));
            
            result = command_buffer.Commit;
            testCase.verifyEqual( result, uint32(1));
            result = command_buffer.WaitForCompletion;
            testCase.verifyEqual( result, uint32(1));
            
            testCase.verifyEqual( single( output_buffer ), testdata.^2);
            
            
        end
        
    end
end