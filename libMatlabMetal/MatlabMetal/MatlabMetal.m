//
//  MatlabMetal.m
//  MatlabMetal
//
//  Created by Anthony Davis on 12/16/20.
//

#import <Foundation/Foundation.h>
#import <Metal/Metal.h>
#import "MatlabMetal.h"
#import "HandleStore.h"

NSString * ErrorString;

#pragma mark Error Handling

/**
 * Return a pointer to the text of the most recent error.
 *  @param error Allocated char buffer to receive the error message
 *  @param buffer_length Size of the allocated error buffer
 */
void mtlGetLastError( char * error, int buffer_length )
{
    @autoreleasepool {
        
        if (ErrorString)
            strncpy( error, ErrorString.UTF8String, buffer_length );
        else
            error[0] = '\0';
    }
}

void mtlStoreError( NSString * error_message )
{
    ErrorString = [ [NSString alloc] initWithString: error_message ];
}


#pragma mark Devices

/**
 * Get the number of installed Metal devices
 * @return The number of devices
 **/
unsigned int mtlNumberOfDevices( void )
{
    @autoreleasepool {
        NSArray<id<MTLDevice>> * devices = MTLCopyAllDevices();
        return (unsigned int) devices.count;
    }
}



/**
 * Get a DeviceHandle for the specified index
 * @param index Index of the device (zero-based up to mtlNumberOfDevices -1)
 * @return A DeviceHandle of the device at the index
 */
DeviceHandle mtlGetDeviceAtIndex( uint32_t index )
{
    @autoreleasepool {
        id HS = [ HandleStore getInstance ];
        NSArray<id<MTLDevice>> * devices = MTLCopyAllDevices();
        if ( index >= [ devices count ] )
        {
            mtlStoreError( @"Index out of bounds" );
            return (DeviceHandle)INVALID_HANDLE;
        }
        return [ HS Device2Handle: [ devices objectAtIndex:index ] ];
    }
}


/**
 * Return a mtlDeviceInfo struct for a Metal device pointed by a handle
 * @param device_handle Handle to a Device
 * @param deviceInfo A pointer to a preallocated mtlDeviceInfo struct
 * @return MTL_SUCCESS or MTL_ERROR
 **/
uint32_t mtlGetDeviceInfo(DeviceHandle device_handle, mtlDeviceInfo *deviceInfo)
{
    @autoreleasepool {
        id HS = [ HandleStore getInstance ];
        id<MTLDevice> device = [ HS Handle2Device:device_handle ];
        if (!device) {
            mtlStoreError( @"Invalid device handle." );
            return MTL_ERROR;
        }
        
        strncpy( deviceInfo->name, [ [ device name ] cStringUsingEncoding:NSUTF8StringEncoding ], METALLIB_MAX_STRING_LENGTH );
        deviceInfo->IsHeadless = [ device isHeadless ];
        deviceInfo->IsLowPower = [ device isLowPower ];
        deviceInfo->recommendedMaxWorkingSetSize = [ device recommendedMaxWorkingSetSize ];
        deviceInfo->RegistryID = [ device registryID ];
        return MTL_SUCCESS;
    }
}


/**
 * Determine if two device_handles refer to the same Device
 * @param device_handle1 Handle to a Device object
 * @param device_handle2 Handle to a Device object
 * @return uint8(1) if the device handles refer to the same Metal device, uint8(0) if they do not match.
 **/
uint8_t mtlSameDevice( DeviceHandle device_handle1, DeviceHandle device_handle2 )
{
    @autoreleasepool {
        id HS = [ HandleStore getInstance ];
        return ( [ [ HS Handle2Device:device_handle1 ] registryID ] == [ [ HS Handle2Device:device_handle2 ] registryID ] );
    }
}




/**
 * Get allocated memory for a device
 * @param device_handle Handle to a Device
 * @return The currently allocated memory in bytes, -1 on error
 */
int64_t mtlGetDeviceAllocatedMemory( DeviceHandle device_handle )
{
    @autoreleasepool {
        id HS = [ HandleStore getInstance ];
        id<MTLDevice> device = [ HS Handle2Device:device_handle ];
        if (!device) {
            mtlStoreError( @"Invalid device handle." );
            return -1;
        }
        return (int64_t)[ device currentAllocatedSize ];
    }
    
}



/** Copy a device
 * @param device_handle The handle of the device to copy
 */
DeviceHandle mtlCopyDevice( DeviceHandle device_handle )
{
    @autoreleasepool {
        id HS = [ HandleStore getInstance ];
        id<MTLDevice> device = [ HS Handle2Device:device_handle ];
        if (!device) {
            mtlStoreError( @"Invalid device handle." );
            return (DeviceHandle)INVALID_HANDLE;
        }
        
        return [ HS Device2Handle:device ];
    }
}


/** Free a device
 * @param device_handle The handle of the device to free
 */
void mtlFreeDevice( DeviceHandle device_handle )
{
    @autoreleasepool {
        [ [ HandleStore getInstance ] FreeDevice:device_handle ];
    }
}




#pragma mark Libraries

/** Create a new library on a device from source code.
 * @param device_handle Handle to a Device
 * @param source Null-terminated string of the source code to compile
 * @return LibraryHandle on success, INVALID_HANDLE on error.
 */
LibraryHandle mtlNewLibrary( DeviceHandle device_handle, const char * source )
{
    @autoreleasepool {
        id HS = [ HandleStore getInstance ];
        
        id<MTLDevice> device = [ HS Handle2Device:device_handle ];
        if (!device) {
            mtlStoreError( @"Invalid device handle." );
            return (LibraryHandle) INVALID_HANDLE;
        }
        
        NSError * error = nil;
        NSString *nsSource = [ NSString stringWithUTF8String:source ];
        MTLCompileOptions *options = [MTLCompileOptions new];
        options.fastMathEnabled = YES;
        id<MTLLibrary> library = [ device newLibraryWithSource:nsSource options:options error:&error ];
        
        if ( !library ) {
            mtlStoreError( [ error localizedDescription ] );
            return (LibraryHandle) INVALID_HANDLE;
        }
        
        return [ HS Library2Handle:library ];
    }
    
}

/** Return the device on which the library was created.
 * @param library_handle Handle to a Library
 * @return DeviceHandle on success, INVALID_HANDLE on error.
 */
DeviceHandle mtlLibraryDevice( LibraryHandle library_handle )
{
    @autoreleasepool {
        id HS = [ HandleStore getInstance ];
        
        id<MTLLibrary> library = [ HS Handle2Library:library_handle ];
        if (!library){
            mtlStoreError( @"Invalid library handle." );
            return (DeviceHandle) INVALID_HANDLE;
        }
        
        id<MTLDevice> device = [ library device ];
        if (!device) {
            mtlStoreError( @"Could not determine device for library" );
            return (DeviceHandle) INVALID_HANDLE;
        }
        return [ HS Device2Handle:device ];
    }
}


/** Free a library
 * @param library_handle The handle of the library to free
 */
void mtlFreeLibrary( LibraryHandle library_handle )
{
    @autoreleasepool {
        [ [ HandleStore getInstance ] FreeLibrary:library_handle ];
    }
}



#pragma mark Functions
/** Create a new function in a library
 * @param library_handle Handle to a Library
 * @param function_name Name of the function defined in the library
 * @return FunctionHandle on success, INVALID_HANDLE on error.
 */
FunctionHandle mtlNewFunction( LibraryHandle library_handle, const char * function_name )
{
    @autoreleasepool {
        id HS = [ HandleStore getInstance ];
        
        id<MTLLibrary> library = [ HS Handle2Library:library_handle ];
        if (!library){
            mtlStoreError( @"Invalid library handle." );
            return (FunctionHandle) INVALID_HANDLE;
        }
        
        NSString *ns_function_name = [ NSString stringWithUTF8String:function_name ];
        id<MTLFunction> function = [ library newFunctionWithName:ns_function_name ];
        
        if ( !function ){
            mtlStoreError( @"Library invalid or function name incorrect" );
            return (FunctionHandle) INVALID_HANDLE;
        }
        
        return [ HS Function2Handle:function ];
    }
}


/** Free a function
 * @param function_handle The handle of the function to free
 */
void mtlFreeFunction( FunctionHandle function_handle )
{
    @autoreleasepool {
        [ [ HandleStore getInstance ] FreeFunction:function_handle ];
    }
}




#pragma mark Compute Pipeline States

/// Create a new compute pipeline state
/// @param device_handle The handle to the device on which the pipeline will be created
/// @param function_handle  The function for which the pipeline will be created.
ComputePipelineStateHandle mtlNewComputePipelineState( DeviceHandle device_handle, FunctionHandle function_handle )
{
    @autoreleasepool {
        id HS = [ HandleStore getInstance ];
        
        id<MTLDevice> device = [ HS Handle2Device:device_handle ];
        if (!device) {
            mtlStoreError( @"Invalid device handle.");
            return (ComputePipelineStateHandle) INVALID_HANDLE;
        }
        id<MTLFunction> function = [ HS Handle2Function:function_handle ];
        if (!function) {
            mtlStoreError( @"Invalid function handle." );
            return (ComputePipelineStateHandle) INVALID_HANDLE;
        }
        
        NSError * error = nil;
        id<MTLComputePipelineState> compute_pipeline_state = [ device newComputePipelineStateWithFunction:function error:&error ];
        
        if (!compute_pipeline_state) {
            mtlStoreError( [ error localizedDescription] );
            return (ComputePipelineStateHandle) INVALID_HANDLE;
        }
        
        return [ HS ComputePipelineState2Handle:compute_pipeline_state ];
    }
    
}


/** Return the device on which the compute pipeline state was created
 * @param compute_pipeline_state_handle The handle of the compute pipeline state
 * @return DeviceHandle on succes, INVALID_HANDLE on error.
 */
DeviceHandle mtlComputePipelineStateDevice( ComputePipelineStateHandle compute_pipeline_state_handle )
{
    @autoreleasepool {
        id HS = [ HandleStore getInstance ];
        
        id<MTLComputePipelineState> compute_pipeline_state = [ HS Handle2ComputePipelineState:compute_pipeline_state_handle ];
        if (!compute_pipeline_state) {
            mtlStoreError( @"Invalid compute pipeline state handle." );
            return (DeviceHandle)INVALID_HANDLE;
        }
        
        id<MTLDevice> device = [ compute_pipeline_state device ];
        if (!device) {
            mtlStoreError( @"Error retrieving device for compute pipeline state." );
            return (DeviceHandle)INVALID_HANDLE;
        }
        
        return [ HS Device2Handle:device ];
    }
}


/** Copy a pipeline state
 * @param compute_pipeline_state_handle The handle of the compute pipeline state to copy
 */
ComputePipelineStateHandle mtlCopyComputePipelineState( ComputePipelineStateHandle compute_pipeline_state_handle )
{
    @autoreleasepool {
        id HS = [ HandleStore getInstance ];
        
        id<MTLComputePipelineState> compute_pipeline_state = [ HS Handle2ComputePipelineState:compute_pipeline_state_handle ];
        if (!compute_pipeline_state) {
            mtlStoreError( @"Invalid compute pipeline state handle." );
            return (ComputePipelineStateHandle)INVALID_HANDLE;
        }
        
        return [ HS ComputePipelineState2Handle:compute_pipeline_state ];
    }
}

/** Determine the maximum number of simultaneous threads.
 * @param compute_pipeline_state_handle The handle of the compute pipeline state to query
 */
uint32_t mtlThreadExecutionWidth( ComputePipelineStateHandle compute_pipeline_state_handle )
{
    @autoreleasepool {
        id HS = [ HandleStore getInstance ];
        
        id<MTLComputePipelineState> compute_pipeline_state = [ HS Handle2ComputePipelineState:compute_pipeline_state_handle ];
        if (!compute_pipeline_state) {
            mtlStoreError( @"Invalid compute pipeline state handle." );
            return 0;
        }
        
        return (uint32_t)[ compute_pipeline_state threadExecutionWidth ];
    }
}



/** Free a pipeline state
 * @param compute_pipeline_state_handle The handle of the compute pipeline state to free
 */
void mtlFreeComputePipelineState( ComputePipelineStateHandle compute_pipeline_state_handle )
{
    @autoreleasepool {
        [ [ HandleStore getInstance ] FreeComputePipelineState:compute_pipeline_state_handle ];
    }
}



#pragma mark Command Queues

/// Create a new command queue
/// @param device_handle The handle to the device on which the queue will be created
CommandQueueHandle mtlNewCommandQueue( DeviceHandle device_handle )
{
    @autoreleasepool {
        id HS = [ HandleStore getInstance ];
        
        id<MTLDevice> device = [ HS Handle2Device:device_handle ];
        if (!device) {
            mtlStoreError( @"Invalid device handle." );
            return (CommandQueueHandle) INVALID_HANDLE;
        }
        
        id<MTLCommandQueue> command_queue = [ device newCommandQueue ];
        if (!command_queue) {
            mtlStoreError( @"Error creating command queue." );
            return (CommandQueueHandle) INVALID_HANDLE;
        }
        
        return [ HS CommandQueue2Handle:command_queue ];
    }
    
}



/** Return the device on which the command queue was created
 * @param command_queue_handle The handle of the command queue
 * @return DeviceHandle on succes, INVALID_HANDLE on error.
 */
DeviceHandle mtlCommandQueueDevice( CommandQueueHandle command_queue_handle )
{
    @autoreleasepool {
        id HS = [ HandleStore getInstance ];
        
        id<MTLCommandQueue> command_queue = [ HS Handle2CommandQueue:command_queue_handle ];
        if (!command_queue) {
            mtlStoreError( @"Invalid command queue handle." );
            return (DeviceHandle)INVALID_HANDLE;
        }
        
        id<MTLDevice> device = [ command_queue device ];
        if (!device) {
            mtlStoreError( @"Error retrieving device for command queue." );
            return (DeviceHandle)INVALID_HANDLE;
        }
        
        return [ HS Device2Handle:device ];
    }
}



/** Free a command queue
 * @param command_queue_handle The handle of the command queue to free
 */
void mtlFreeCommandQueue( CommandQueueHandle command_queue_handle )
{
    @autoreleasepool {
        [ [ HandleStore getInstance ] FreeCommandQueue:command_queue_handle ];
    }
}



#pragma mark Buffers
/** Create a new buffer on the GPU
 * @param device_handle The handle to the device on which the buffer will be created
 * @param bytes Size of the buffer in bytes
 * @return BufferHandle on success, INVALID_HANDLE on error.
 */
BufferHandle mtlNewBuffer( DeviceHandle device_handle, uint64_t bytes )
{
    @autoreleasepool {
        id HS = [ HandleStore getInstance ];
        
        id<MTLDevice> device = [ HS Handle2Device:device_handle ];
        if (!device) {
            mtlStoreError( @"Invalid device handle." );
            return (BufferHandle) INVALID_HANDLE;
        }
        
        id<MTLBuffer> buffer = [device newBufferWithLength:bytes options:MTLResourceStorageModeManaged];
        if (!buffer) {
            mtlStoreError( @"Error creating buffer." );
            return (BufferHandle) INVALID_HANDLE;
        }
        
        return [ HS Buffer2Handle:buffer ];
    }
    
}


/** Copy data into the GPU buffer
 * @param buffer_handle The handle to the buffer to copy data into
 * @param data A pointer to data to copy into the GPU buffer
 * @param bytes Number of bytes to copy
 * @return MTL_SUCCESS or MTL_ERROR
 */
uint32_t mtlCopyDataToBuffer( BufferHandle buffer_handle, const void * data, uint64_t bytes )
{
    @autoreleasepool {
        id HS = [ HandleStore getInstance ];
        
        id<MTLBuffer> buffer = [ HS Handle2Buffer:buffer_handle ];
        if (!buffer) {
            mtlStoreError( @"Invalid buffer handle." );
            return MTL_ERROR;
        }
        
        if ( bytes > [ buffer length ])
        {
            mtlStoreError( @"Buffer too small to copy data." );
            return MTL_ERROR;
        }
        memcpy( [ buffer contents ], data, bytes );
        [ buffer didModifyRange:NSMakeRange(0 , bytes) ];
        return MTL_SUCCESS;
    }
}


/** Copy data from the GPU buffer
 * @param buffer_handle The handle to the buffer to copy data from
 * @param data A pointer to copy the data into
 * @param bytes Number of bytes to copy
 * @return MTL_SUCCESS or MTL_ERROR
 */
uint32_t mtlCopyDataFromBuffer( BufferHandle buffer_handle, void * data, uint64_t bytes )
{
    @autoreleasepool {
        id HS = [ HandleStore getInstance ];
        
        id<MTLBuffer> buffer = [ HS Handle2Buffer:buffer_handle ];
        if (!buffer) {
            mtlStoreError( @"Invalid buffer handle." );
            return MTL_ERROR;
        }
        
        if ( bytes > [ buffer length ])
        {
            mtlStoreError( @"Buffer smaller than specified number of bytes to copy." );
            return MTL_ERROR;
        }
        
        id <MTLCommandQueue> commandQueue = [ [buffer device] newCommandQueue ];
        id <MTLCommandBuffer> commandBuffer = [ commandQueue commandBuffer ];
        // Synchronize the managed buffer.
        id <MTLBlitCommandEncoder> blitCommandEncoder = [ commandBuffer blitCommandEncoder ];
        [ blitCommandEncoder synchronizeResource: buffer ];
        [ blitCommandEncoder endEncoding ];
        [commandBuffer commit];
        [ commandBuffer waitUntilCompleted ];
        
        memcpy( data, [ buffer contents ], bytes );
        return MTL_SUCCESS;
    }
}


/** Return the size of a buffer
 * @param buffer_handle The handle of the buffer to free
 * @return MTL_ERROR if the buffer is of zero size or does not exist, size of the allocated buffer otherwise.
 */
uint64_t mtlBufferSize( BufferHandle buffer_handle )
{
    @autoreleasepool {
        id HS = [ HandleStore getInstance ];
        
        id<MTLBuffer> buffer = [ HS Handle2Buffer:buffer_handle ];
        if (!buffer) {
            mtlStoreError( @"Invalid buffer handle." );
            return MTL_ERROR;
        }
        return [ buffer length ];
    }
}



/** Return the device on which the buffer was created
 * @param buffer_handle The handle of the buffer to free
 * @return DeviceHandle on succes, INVALID_HANDLE on error.
 */
DeviceHandle mtlBufferDevice( BufferHandle buffer_handle )
{
    @autoreleasepool {
        id HS = [ HandleStore getInstance ];
        
        id<MTLBuffer> buffer = [ HS Handle2Buffer:buffer_handle ];
        if (!buffer) {
            mtlStoreError( @"Invalid buffer handle." );
            return (DeviceHandle)INVALID_HANDLE;
        }
        
        id<MTLDevice> device = [ buffer device ];
        if (!device) {
            mtlStoreError( @"Error retrieving device for buffer." );
            return (DeviceHandle)INVALID_HANDLE;
        }
        
        return [ HS Device2Handle:device ];
    }
}



/** Free a GPU buffer
 * @param buffer_handle The handle of the buffer to free
 */
void mtlFreeBuffer( BufferHandle buffer_handle )
{
    @autoreleasepool {
        id HS = [ HandleStore getInstance ];
        id<MTLBuffer> buffer = [ HS Handle2Buffer:buffer_handle ];
        if (!buffer) {
            mtlStoreError( @"Invalid buffer handle." );
            return;
        }
        [ HS FreeBuffer:buffer_handle ];
    }
}


#pragma mark Command Buffers

/** Create a command buffer
 * @param command_queue_handle A handle to a command queue on which to create the command buffer
 * @return A command buffer handle or INVALID_HANDLE
 */
CommandBufferHandle mtlNewCommandBuffer( CommandQueueHandle command_queue_handle )
{
    @autoreleasepool {
        id HS = [ HandleStore getInstance ];
        
        id<MTLCommandQueue> command_queue = [ HS Handle2CommandQueue:command_queue_handle ];
        if (!command_queue) {
            mtlStoreError( @"Invalid command queue handle." );
            return (CommandBufferHandle)INVALID_HANDLE;
        }
        
        id<MTLCommandBuffer> command_buffer = [ command_queue commandBuffer ];
        if (!command_buffer)
        {
            mtlStoreError( @"Error creating the command buffer." );
            return (CommandBufferHandle)INVALID_HANDLE;
        }
        
        return [ HS CommandBuffer2Handle:command_buffer ];
    }
    
}



/** Return the device on which the command buffer was created
 * @param command_buffer_handle The handle of the command buffer
 * @return DeviceHandle on succes, INVALID_HANDLE on error.
 */
DeviceHandle mtlCommandBufferDevice( CommandBufferHandle command_buffer_handle )
{
    @autoreleasepool {
        id HS = [ HandleStore getInstance ];
        
        id<MTLCommandBuffer> command_buffer = [ HS Handle2CommandBuffer:command_buffer_handle ];
        if (!command_buffer) {
            mtlStoreError( @"Invalid command buffer handle." );
            return (DeviceHandle)INVALID_HANDLE;
        }
        
        id<MTLDevice> device = [ command_buffer device ];
        if (!device) {
            mtlStoreError( @"Error retrieving device for command buffer." );
            return (DeviceHandle)INVALID_HANDLE;
        }
        
        return [ HS Device2Handle:device ];
    }
}



/** Copy a command buffer
 * @param command_buffer_handle The handle of the command buffer to copy
 */
CommandBufferHandle mtlCopyCommandBuffer( CommandBufferHandle command_buffer_handle )
{
    @autoreleasepool {
        id HS = [ HandleStore getInstance ];
        
        id<MTLCommandBuffer> command_buffer = [ HS Handle2CommandBuffer:command_buffer_handle ];
        if (!command_buffer) {
            mtlStoreError( @"Invalid command buffer handle." );
            return (CommandBufferHandle)INVALID_HANDLE;
        }
        
        return [ HS CommandBuffer2Handle:command_buffer ];
    }
}



/** Free a command buffer
 * @param command_buffer_handle The handle of the command buffer to free
 */
void mtlFreeCommandBuffer( CommandBufferHandle command_buffer_handle )
{
    @autoreleasepool {
        id HS = [ HandleStore getInstance ];
        [ HS FreeCommandBuffer:command_buffer_handle ];
    }
}


/** Commit a command buffer for execution
 * @param command_buffer_handle The handle of the command buffer to free
 * @return MTL_SUCCESS or MTL_ERROR
 */
uint32_t mtlCommitCommandBuffer( CommandBufferHandle command_buffer_handle )
{
    @autoreleasepool {
        id HS = [ HandleStore getInstance ];
        
        id<MTLCommandBuffer> command_buffer = [ HS Handle2CommandBuffer:command_buffer_handle ];
        if (!command_buffer) {
            mtlStoreError( @"Invalid command buffer handle." );
            return MTL_ERROR;
        }
        
        [command_buffer commit];
        return MTL_SUCCESS;
    }
    
}


/** Wait for a command buffer to complete
 * @param command_buffer_handle The handle of the command buffer to free
 * @return MTL_SUCCESS or MTL_ERROR
 */
uint32_t mtlWaitForCompletion( CommandBufferHandle command_buffer_handle )
{
    @autoreleasepool {
        id HS = [ HandleStore getInstance ];
        
        id<MTLCommandBuffer> command_buffer = [ HS Handle2CommandBuffer:command_buffer_handle ];
        if (!command_buffer) {
            mtlStoreError( @"Invalid command buffer handle." );
            return MTL_ERROR;
        }
        
        [command_buffer waitUntilCompleted];
        return MTL_SUCCESS;
    }
    
}


#pragma mark Command Encoders
/** Create a command encoder
 * @param command_buffer_handle A handle to a command buffer on which to create the command encoder
 * @return A handle to a command encoder or INVALID_HANDLE on error
 */
CommandEncoderHandle mtlNewCommandEncoder( CommandBufferHandle command_buffer_handle )
{
    @autoreleasepool {
        id HS = [ HandleStore getInstance ];
        
        id<MTLCommandBuffer> command_buffer = [ HS Handle2CommandBuffer:command_buffer_handle ];
        if (!command_buffer) {
            mtlStoreError( @"Invalid command buffer handle." );
            return (CommandEncoderHandle)INVALID_HANDLE;
        }
        
        id<MTLComputeCommandEncoder> command_encoder = [ command_buffer computeCommandEncoderWithDispatchType:MTLDispatchTypeSerial ];
        if (!command_encoder)
        {
            mtlStoreError( @"Error creating the command encoder." );
            return (CommandEncoderHandle)INVALID_HANDLE;
        }
        
        return [ HS CommandEncoder2Handle:command_encoder ];
    }
}


/** Free a command encoder
 * @param command_encoder_handle The handle of the command encoder to free
 */
void mtlFreeCommandEncoder( CommandEncoderHandle command_encoder_handle )
{
    @autoreleasepool {
        id HS = [ HandleStore getInstance ];
        [ HS FreeCommandEncoder:command_encoder_handle ];
    }
}


/** Set a compute pipeline state (the function to execute) to a command buffer via its command encoder
 * @param command_encoder_handle The handle of the command encoder to use
 * @return MTL_SUCCESS or MTL_ERROR
 */
uint32_t mtlSetComputePipelineState( CommandEncoderHandle command_encoder_handle, ComputePipelineStateHandle compute_pipeline_state_handle )
{
    @autoreleasepool {
        id HS = [ HandleStore getInstance ];
        
        id<MTLComputeCommandEncoder> command_encoder = [ HS Handle2CommandEncoder:command_encoder_handle ];
        if (!command_encoder) {
            mtlStoreError( @"Invalid command encoder handle." );
            return MTL_ERROR;
        }
        
        id<MTLComputePipelineState> compute_pipeline_state = [ HS Handle2ComputePipelineState:compute_pipeline_state_handle ];
        if (!compute_pipeline_state) {
            mtlStoreError( @"Invalid compute pipeline state handle." );
            return MTL_ERROR;
        }
        
        [ command_encoder setComputePipelineState:compute_pipeline_state ];
        
        
        return MTL_SUCCESS;
    }
}



/** Associate a GPU buffer with a command buffer via its command encoder
 * @param command_encoder_handle The handle of the command encoder to use
 * @param buffer_handle The handle of a buffer to associate with the command encoder
 * @param index The index of the association, zero-based.
 * @return MTL_SUCCESS or MTL_ERROR
 */
uint32_t mtlSetBuffer( CommandEncoderHandle command_encoder_handle, BufferHandle buffer_handle, uint32_t index )
{
    @autoreleasepool {
        id HS = [ HandleStore getInstance ];
        
        id<MTLComputeCommandEncoder> command_encoder = [ HS Handle2CommandEncoder:command_encoder_handle ];
        if (!command_encoder) {
            mtlStoreError( @"Invalid command encoder handle." );
            return MTL_ERROR;
        }
        
        id<MTLBuffer> buffer = [ HS Handle2Buffer:buffer_handle ];
        if (!buffer) {
            mtlStoreError( @"Invalid buffer handle." );
            return MTL_ERROR;
        }
        
        [ command_encoder setBuffer:buffer offset:0 atIndex:index ];
        
        return MTL_SUCCESS;
    }
}


MTLSize CalculateThreadgroupSize( MTLSize gridSize, NSUInteger max_threads )
{
    @autoreleasepool {
        MTLSize threadgroupSize;
        threadgroupSize.width = gridSize.width;
        threadgroupSize.depth = gridSize.depth;
        threadgroupSize.height = gridSize.height;
        while( ( threadgroupSize.width * threadgroupSize.depth * threadgroupSize.height ) > max_threads )
        {
            threadgroupSize.width = MAX( (int)((double)threadgroupSize.width / 1.01), 1 );
            threadgroupSize.depth = MAX( (int)((double)threadgroupSize.depth / 1.01), 1 );
            threadgroupSize.height = MAX( (int)((double)threadgroupSize.height / 1.01), 1 );
        }
        return threadgroupSize;
    }
}


/** Specify the thread count and organization
 * @param command_encoder_handle The handle of the command encoder to use
 * @param compute_pipeline_state_handle The handle of the compute pipeline state which will be executed
 * @param width The size of the first dimension (usuall numelements for a one-dimensional array)
 * @param height The size of the second dimension (usually 1 for a one-dimensional array)
 * @param depth The size of the third dimension (usually 1 for a one-dimensional array)
 * @return MTL_SUCCESS or MTL_ERROR
 */
uint32_t mtlSetThreadsAndShape( CommandEncoderHandle command_encoder_handle, ComputePipelineStateHandle compute_pipeline_state_handle,  uint32_t width, uint32_t height, uint32_t depth )
{
    @autoreleasepool {
        id HS = [ HandleStore getInstance ];
        
        if ( ( width == 0 ) || ( height == 0 ) || ( depth ==0 ) )
            return MTL_ERROR;
        
        id<MTLComputeCommandEncoder> command_encoder = [ HS Handle2CommandEncoder:command_encoder_handle ];
        if (!command_encoder) {
            mtlStoreError( @"Invalid command encoder handle." );
            return MTL_ERROR;
        }
        
        id<MTLComputePipelineState> compute_pipeline_state = [ HS Handle2ComputePipelineState:compute_pipeline_state_handle ];
        if (!compute_pipeline_state) {
            mtlStoreError( @"Invalid compute pipeline state handle." );
            return MTL_ERROR;
        }
        
        MTLSize gridSize = MTLSizeMake( width, height, depth );
        NSUInteger max_threads_per_threadgroup = compute_pipeline_state.maxTotalThreadsPerThreadgroup;
        MTLSize threadgroupSize = CalculateThreadgroupSize( gridSize, max_threads_per_threadgroup );
        [ command_encoder dispatchThreads:gridSize threadsPerThreadgroup:threadgroupSize ];
        
        return MTL_SUCCESS;
    }
}


/** End encoding
 * @param command_encoder_handle The handle of the command encoder
 * @return MTL_SUCCESS or MTL_ERROR
 */
uint32_t mtlEndEncoding( CommandEncoderHandle command_encoder_handle )
{
    @autoreleasepool {
        id HS = [ HandleStore getInstance ];
        
        id<MTLComputeCommandEncoder> command_encoder = [ HS Handle2CommandEncoder:command_encoder_handle ];
        if (!command_encoder) {
            mtlStoreError( @"Invalid command encoder handle." );
            return MTL_ERROR;
        }
        
        [ command_encoder endEncoding ];
        
        return MTL_SUCCESS;
    }
}

