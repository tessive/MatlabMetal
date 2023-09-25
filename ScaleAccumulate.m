function ScaleAccumulate( bufferA, bufferB, bufferScale)
% SCALEACCUMULATE Scale an array by a scalar and accumulate, using Metal
% This is a Metal implementation of scaling and accumulating two buffers.
% It implements A = A + B * scaleval, where A and B are Metal buffers containing three-dimensional
% single precision float arrays, and scaleval is a single precision scalar
% in a Metal buffer.


% First, make sure the buffers are on the same device.
% The "isequal" method is helpful for this. It will return true if two
% MetalDevice instances point to the same physical hardware.
assert(bufferA.device.isequal(bufferB.device));
assert(bufferA.device.isequal(bufferScale.device));

% Next, we need to compile the kernel and get ready, but we only want to do
% this once. We have a persistent struct holding all the relevant classes,
% and we check if it is empty (first run) or if the device specified in the
% buffers has moved. In either case, we compile the kernel and create the
% necessary classes in the subroutine below.
persistent MetalSetup;
if isempty(MetalSetup)
    MetalSetup = ConfigureMetalSetup;
elseif ~MetalSetup.Device.isequal( bufferA.device )
    MetalSetup = ConfigureMetalSetup(bufferA.device);
end


command_buffer = MetalCommandBuffer( MetalSetup.CommandQueue );
assert(command_buffer.isValid);
command_encoder = MetalCommandEncoder( command_buffer );
assert(command_encoder.isValid);
        
% Once we have a command encoder, we use that class to set up the function
% and its arguments. 

% Tell the command encoder we want to run the scaleaccum function, using the
% compute pipeline state created for the function.
result = command_encoder.SetComputePipelineState( MetalSetup.Cps );
assert(result == uint32(1));

% Set the first argument to bufferA, the second argument to bufferB,
% and the third to bufferScale.
result = command_encoder.SetBuffer( bufferA, 1);
assert(result == uint32(1));
result = command_encoder.SetBuffer( bufferB, 2);
assert(result == uint32(1));
result = command_encoder.SetBuffer( bufferScale, 3);
assert(result == uint32(1));

% Now we just need to tell the encoder how many elements are in the
% buffers to be processed. This needs the compute pipeline state again.
result = command_encoder.SetThreadsAndShape( MetalSetup.Cps, prod(bufferA.dimensions));
assert(result == uint32(1));

% Once all the arguments and thread information has been set, tell the
% encoder we are done encoding information.
result = command_encoder.EndEncoding;
assert(result == uint32(1));

% Now we're ready to run the command. The command encoder is already
% associate with a command buffer, which itself has a command queue to run
% in. So all we need to do is commit it to run and wait for it to be done.

result = command_buffer.Commit;
assert(result == uint32(1));
result = command_buffer.WaitForCompletion;
assert(result == uint32(1));


end



function MetalSetup = ConfigureMetalSetup(varargin)

    if nargin == 0
        metalConfig = Metal.Config;
        MetalSetup.Device = MetalDevice( metalConfig.gpudevice );
    else
        MetalSetup.Device = varargin{1};
    end
    
    disp('Compiling library');
    
    libraryCode = string(fileread("MetalFunctionLibrary.mtl")); % Load the source code
    MetalSetup.Library = MetalLibrary(MetalSetup.Device, libraryCode);  % Compile the library
    assert(MetalSetup.Library.isValid);
    MetalSetup.Function = MetalFunction( MetalSetup.Library, "scaleaccum"); % Create a Metal Function
    assert(MetalSetup.Function.isValid);
    MetalSetup.Cps = MetalComputePipelineState( MetalSetup.Device, MetalSetup.Function ); %Create the compute pipeline state
    assert(MetalSetup.Cps.isValid);
    MetalSetup.CommandQueue = MetalCommandQueue( MetalSetup.Device );
    assert(MetalSetup.CommandQueue.isValid);
    
end