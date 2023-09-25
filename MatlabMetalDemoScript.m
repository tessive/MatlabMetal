% This script shows how to use the MATLAB Metal classes to perform 
% simple computation.  It is intended to run as a cell-mode script, so 
% you can execute each section separately.

%% Simple Configuration

% The Metal configuration of the system is handled using a singleton class. 
% The instance of this class is retrieved from the Metal class using the
% static method "Config". 

metalConfig = Metal.Config;
disp(metalConfig);  %The disp command will show GPU information

% An array of strings of supported Metal devices resides in the
% "gpuoptions" property. Most computers only have one device, but for
% systems with multiple GPUs, this can select the active one. 
% To change which device is used by MATLAB Metal, simply set the
% "gpuoptionindex" parameter in the singleton class. 

metalConfig.gpuoptionindex = 1;  %Change this to use a different GPU
disp(metalConfig);

% This is mostly used to enumerate the device number for later use. In
% MATLAB Metal classes, if a Metal device number is needed, use
% metalConfig.gpudevice

disp(metalConfig.gpudevice);

%% Device class
%Metal devices are wrapped up in the MetalDevice class. To create a Device,
%simply construct it using the gpudevice index of the Metal Device you wish
%to use. 

metalConfig = Metal.Config;
device = MetalDevice( metalConfig.gpudevice );

%This creates a class pointing to the device instance, which can be used in
%later calls. The class will automatically destroy the instance when it
%goes out of MATLAB scope (all these classes will do this, so there is no
%need to keep track of the lifetime of the classes.) 

disp(device);
disp(device.info);

% The "isValid" flag can be used to make sure the class opened correctly.
% If there are multiple devices on the system, and multiple MetalDevice
% classes are instansiated, the equality operation can be used to see if
% any two MetalDevice classes point to the same actual hardware. 

%% Function Library
% To create executable kernels on the Metal system, a function library
% needs to be loaded and compiled. The MetalLibrary class makes this easy.
% The "source" parameter to MetalLibrary is a MATLAB string type (not char
% array). If there is a problem with compilation of the Metal code, it will
% be returned in the "message" parameter, and the "isValid" parameter will
% be false.

% For this demo, a MetalFunctionLibrary.mtl file is provided with some
% sample Metal functions.
metalConfig = Metal.Config;
device = MetalDevice( metalConfig.gpudevice );

libraryCode = string(fileread("MetalFunctionLibrary.mtl"));

library = MetalLibrary(device, libraryCode);
disp(library);

% The functions within the library are then registered, so each can be
% called. This is done by name of the function. 

zeroBuffFunction = MetalFunction( library, "zerobuff");
accumulateFunction = MetalFunction( library, "accumulate");
maxValFunction = MetalFunction( library, "maxval");
scaleAccumulateFunction = MetalFunction( library, "scaleaccum");

% As an example of an error, this is what it looks like if an invalid
% function name is provided:
invalidFunction = MetalFunction( library, "doesnotexist");
disp("We expect an error to follow here: ");
disp(invalidFunction);

% Once a function has been created, it needs to be associated with a Metal
% Compute Pipeline State, which is the wrapper for function execution. This
% is easily accomplished using the MetalComputePipelineState MATLAB class,
% which just needs a device to operate on as well as the function instance
% to be created.

zeroBuff_cps = MetalComputePipelineState( device, zeroBuffFunction );
accumulate_cps = MetalComputePipelineState( device, accumulateFunction );
maxVal_cps = MetalComputePipelineState( device, maxValFunction );
scaleAccumulateFunction = MetalComputePipelineState( device, scaleAccumulateFunction);

% Check that all these pipeline states are valid:
assert(zeroBuff_cps.isValid); 
assert(accumulate_cps.isValid); 
assert(maxVal_cps.isValid); 
assert(scaleAccumulateFunction.isValid); 



%% Buffers
% Data storage in the Metal system is handled through Metal Buffers, and
% the wrappers provided here support single precision floats and 16 bit
% integers. The MetalBuffer class allows easy creation and management of
% these arrays. It always creates three-dimensional arrays from a MATLAB
% standpoint. 

% Create a buffer with single-precision random data, then put it onto the
% GPU. 
metalConfig = Metal.Config;
device = MetalDevice( metalConfig.gpudevice );

RawData = rand([20, 30, 40], 'single');
FirstBuffer = MetalBuffer( device, RawData);
assert(FirstBuffer.isValid);

% Create a copy of the data into another GPU buffer. This calls the copy
% constructor of MetalBuffer.
CopyOfBuffer = MetalBuffer( device, FirstBuffer);

% Data can be retrieved from a buffer simply by calling the "single"
% overload. We'll pull the data from the buffer and compare it with the
% original. 
ReturnedData = single(CopyOfBuffer);
%There's no need to explicitly delete these buffers, but you can whenever
%you are done with them. They have normal lifecycle rules like any MATLAB
%class, so will deallocate themselves when they go out of scope. 
delete(CopyOfBuffer);
delete(FirstBuffer); 
assert(isequal(RawData,ReturnedData)); 

%% Creating function arguments and calling functions
% This is where everything comes together. It's just a little bit tricky,
% but we'll walk through it. It's not so bad!

% First, let's get our data put into a couple of buffers. For this example,
% we will accumulate one buffer into another.  Essentially, for every
% element in bufferA, we will sum the corresponding element from bufferB
% into it. This is in the MetalFunctionLibrary.mtl file, in the
% "accumulate" function. 

A = rand([2000, 3000, 100], 'single');
B = rand([2000, 3000, 100], 'single');
tic
GoldenOutput = A + B; %Compute the answer in MATLAB on the CPU directly.
toc

metalConfig = Metal.Config;
device = MetalDevice( metalConfig.gpudevice );
bufferA = MetalBuffer( device, A );
bufferB = MetalBuffer( device, B );

% Now we need to get our function compiled and ready
libraryCode = string(fileread("MetalFunctionLibrary.mtl")); % Load the source code
library = MetalLibrary(device, libraryCode);  % Compile the library
assert(library.isValid);
accumulateFunction = MetalFunction( library, "accumulate"); % Create a Metal Function
assert(accumulateFunction.isValid);
accumulate_cps = MetalComputePipelineState( device, accumulateFunction ); %Create the compute pipeline state
assert(accumulate_cps.isValid);

% Next, we need to get ready for function execution. The building blocks
% for this are the Command Queue, the Command Buffer, and the Command
% Encoder. The command queue is the full processing queue for all commands
% executed. The command buffer handles the execution of a specific command,
% and the command encoder is used to set up the function to be called and
% the arguments for that function. 

command_queue = MetalCommandQueue( device );
assert(command_queue.isValid);
command_buffer = MetalCommandBuffer( command_queue );
assert(command_buffer.isValid);
command_encoder = MetalCommandEncoder( command_buffer );
assert(command_encoder.isValid);
            
% Once we have a command encoder, we use that class to set up the function
% and its arguments. 

% Tell the command encoder we want to run the accumulate function, using the
% compute pipeline state created for the function.
result = command_encoder.SetComputePipelineState( accumulate_cps );
assert(result == uint32(1));

% Set the first argument to bufferA, the second argument to bufferB
result = command_encoder.SetBuffer( bufferA, 1);
assert(result == uint32(1));
result = command_encoder.SetBuffer( bufferB, 2);
assert(result == uint32(1));

% Now we just need to tell the encoder how many elements are in the
% buffers to be processed. This needs the compute pipeline state again.
result = command_encoder.SetThreadsAndShape( accumulate_cps, numel(A));
assert(result == uint32(1));

% Once all the arguments and thread information has been set, tell the
% encoder we are done encoding information.
result = command_encoder.EndEncoding;
assert(result == uint32(1));

% Now we're ready to run the command. The command encoder is already
% associate with a command buffer, which itself has a command queue to run
% in. So all we need to do is commit it to run and wait for it to be done.
% Notice that we can commit multiple command buffers at the same time and
% then wait for each to be done. 
tic
result = command_buffer.Commit;
assert(result == uint32(1));
result = command_buffer.WaitForCompletion;
assert(result == uint32(1));
toc

% Now we can pull the data back from bufferA and see if it matches our
% MATLAB computed version.
MetalProcessedBufferA = single(bufferA);
assert(isequal( MetalProcessedBufferA, GoldenOutput));

%% Use of this library in practice
% In real use, it's useful to wrap up the setup in a function. Here's an
% example of a function that applies output = B + A * scaleval, where B and
% A are buffers of the same size and scaleval is a scalar buffer.
%
% Look at ScaleAccumulate.m to see how these classes can be set up to make
% a cleaner function that handles the kernel source code and setup. 

A = rand([2000, 3000, 100], 'single');
B = rand([2000, 3000, 100], 'single');
scaleVal = rand([1,1], 'single');
tic
GoldenOutput = A + B * scaleVal; %Compute the answer in MATLAB on the CPU directly.
toc

bufferA = MetalBuffer(device, A);
bufferB = MetalBuffer(device, B);
bufferScale = MetalBuffer(device, scaleVal);
tic
ScaleAccumulate(bufferA, bufferB, bufferScale);
toc
GPUOutput = single(bufferA);

assert(~any(abs(GPUOutput-GoldenOutput) > 0.001, 'all'));





