function MetalCallKernel(funcName, variables, kernel)
% METALCALLKERNAL Call a custom Metal kernel
%
% METALCALLKERNEL(FUNCNAME, VARIABLES, KERNEL)
%
% Calls a custom kernel routine FUNCNAME from the specified Metal KERNEL
% code, specifying VARIABLES as inputs.
%
% FUNCNAME is a character array with the name of a function inside 
% the character array KERNEL, which is objective C code for execution by Metal.
%
% VARIABLES is a cell array of MetalBuffer variables to be provided to the kernel.
%
% This function allows a user to call a custom kernel with minimal interaction with
% the GPU pipeline.
%
% Example:
%    funcName = 'scaleaccum';
%    eol = sprintf('\n');
%    kernel = ['#include <metal_stdlib>' eol 'using namespace metal;' eol ...
%          'kernel void scaleaccum(' eol ...
%          '   device float *vA [[ buffer(0) ]],' eol ...
%          '   constant float *vB [[ buffer(1) ]],' eol ...
%          '   constant float *scaleval[[ buffer(2) ]],' eol ...
%          '   uint id[[ thread_position_in_grid ]])' eol ...
%          '   {' eol ...
%          '       vA[id] += vB[id] * scaleval[0];' eol ...
%          '   }' eol ];
%    metalConfig = MetalConfig;
%    device = MetalDevice(metalConfig.gpudevice);
%    A = rand([200,300,100],'single');
%    B = rand([200,300,100],'single');
%    scaleVal = rand([1,1],'single');
%    clear bufferA bufferB bufferScale
%    bufferA = MetalBuffer(device,A);
%    bufferB = MetalBuffer(device,B);
%    bufferScale = MetalBuffer(device,scaleVal);
%    MetalCallKernel(funcName,{bufferA,bufferB,bufferScale},kernel);
%    GPUOutput = single(bufferA);
%    if all(abs(GPUOutput - (A+B*scaleVal))<0.0001), disp('calculation equal!'); end;

   % sdv 2024-07-02, following Tony Davis examples

arguments
    funcName (1,:) char {mustBeVector(funcName)}
    variables cell {mustBeVector(variables)}
    kernel (1,:) char {mustBeVector(kernel)}
end

 % check variables, all should be MetalBuffer objects on the same device

for i=1:numel(variables),
    assert(isa(variables{i},'MetalBuffer'));
    if i~=1,
        assert(variables{1}.device.isequal(variables{i}.device));
    end;
end;

% Next, we need to compile the kernel and get ready, but we only want to do
% this once. We have a persistent struct holding all the relevant classes,
% and we check if it is empty (first run) or if the device specified in the
% buffers has moved. In either case, we compile the kernel and create the
% necessary classes in the subroutine below.
persistent MetalCallKernelSetup;
if isempty(MetalCallKernelSetup)
    MetalCallKernelSetup = ConfigureMetalCallKernelSetup(variables{1}.device,funcName,kernel);
elseif ~MetalCallKernelSetup.Device.isequal( variables{1}.device ) | ...
    ~strcmp(MetalCallKernelSetup.funcName,funcName) | ...
    ~strcmp(MetalCallKernelSetup.kernel,kernel),
    MetalCallKernelSetup = ConfigureMetalCallKernelSetup(variables{1}.device,funcName,kernel);
end


command_buffer = MetalCommandBuffer( MetalCallKernelSetup.CommandQueue );
assert(command_buffer.isValid);
command_encoder = MetalCommandEncoder( command_buffer );
assert(command_encoder.isValid);
        
% Once we have a command encoder, we use that class to set up the function
% and its arguments. 

% Tell the command encoder we want to run the function, using the
% compute pipeline state created for the function.
result = command_encoder.SetComputePipelineState( MetalCallKernelSetup.Cps );
assert(result == uint32(1));

% Add the variables to the argument list
for i=1:numel(variables),
    result = command_encoder.SetBuffer(variables{i},i);
    assert(result == uint32(1));
end;

% Now we just need to tell the encoder how many elements are in the
% buffers to be processed. This needs the compute pipeline state again.
result = command_encoder.SetThreadsAndShape( MetalCallKernelSetup.Cps, prod(variables{1}.dimensions));
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



function MetalSetup = ConfigureMetalCallKernelSetup(device, funcName, kernel)

    MetalSetup.Device = device;
    MetalSetup.funcName = funcName;
    MetalSetup.kernel = kernel;
    
    %disp('Compiling library');
    
    MetalSetup.Library = MetalLibrary(MetalSetup.Device, string(MetalSetup.kernel));  % Compile the library
    assert(MetalSetup.Library.isValid,['Library compilation failed with message: ' char(MetalSetup.Library.message)]); 
    MetalSetup.Function = MetalFunction( MetalSetup.Library, string(MetalSetup.funcName)); % Create a Metal Function
    assert(MetalSetup.Function.isValid);
    MetalSetup.Cps = MetalComputePipelineState( MetalSetup.Device, MetalSetup.Function ); %Create the compute pipeline state
    assert(MetalSetup.Cps.isValid);
    MetalSetup.CommandQueue = MetalCommandQueue( MetalSetup.Device );
    assert(MetalSetup.CommandQueue.isValid);
    
end
