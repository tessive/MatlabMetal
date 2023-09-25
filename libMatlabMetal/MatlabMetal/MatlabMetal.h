//
//  MatlabMetal.hpp
//  MatlabMetal
//
//  Created by Anthony Davis on 12/16/20.
//

#ifndef MatlabMetal_h
#define MatlabMetal_h

#include <stdio.h>
#include <stdint.h>

typedef uint64_t DeviceHandle;
typedef uint64_t LibraryHandle;
typedef uint64_t FunctionHandle;
typedef uint64_t ComputePipelineStateHandle;
typedef uint64_t CommandQueueHandle;
typedef uint64_t BufferHandle;
typedef uint64_t CommandBufferHandle;
typedef uint64_t CommandEncoderHandle;

#define INVALID_HANDLE ( (uint64_t) 0 )
#define MTL_SUCCESS 1
#define MTL_ERROR 0



#define METALLIB_MAX_STRING_LENGTH 256
/**
 * Metal Device Information Struct
 **/
typedef struct {
    char name[METALLIB_MAX_STRING_LENGTH];
    uint8_t IsLowPower;
    uint8_t IsHeadless;
    uint64_t recommendedMaxWorkingSetSize;
    uint64_t RegistryID;
} mtlDeviceInfo;


#ifdef  __cplusplus
extern "C" {
#endif

#pragma mark Error Handling
/**
 * Return a pointer to the text of the most recent error.
 *  @param error Allocated char buffer to receive the error message
 *  @param buffer_length Size of the allocated error buffer
 */
void mtlGetLastError( char * error, int buffer_length );


#pragma mark Devices
/**
 * Get the number of installed Metal devices
 * @return The number of devices
 **/
unsigned int mtlNumberOfDevices( void );


/**
 * Get a DeviceHandle for the specified index
 * @param index Index of the device (zero-based up to mtlNumberOfDevices -1)
 * @return A DeviceHandle of the device at the index, INVALID_HANDLE on error
 */
DeviceHandle mtlGetDeviceAtIndex( uint32_t index );


/**
 * Return a mtlDeviceInfo struct for a Metal device pointed by a handle
 * @param device_handle Handle to a Device
 * @param deviceInfo A pointer to a preallocated mtlDeviceInfo struct
 * @return MTL_SUCCESS or MTL_ERROR
 **/
uint32_t mtlGetDeviceInfo(DeviceHandle device_handle, mtlDeviceInfo *deviceInfo);


/**
 * Determine if two device_handles refer to the same Device
 * @param device_handle1 Handle to a Device object
 * @param device_handle2 Handle to a Device object
 * @return uint8(1) if the device handles refer to the same Metal device, uint8(0) if they do not match.
 **/
uint8_t mtlSameDevice( DeviceHandle device_handle1, DeviceHandle device_handle2 );


/**
 * Get allocated memory for a device
 * @param device_handle Handle to a Device
 * @return The currently allocated memory in bytes, -1 on error
 */
int64_t mtlGetDeviceAllocatedMemory( DeviceHandle device_handle );


/** Copy a device
 * @param device_handle The handle of the device to copy
 */
DeviceHandle mtlCopyDevice( DeviceHandle device_handle );


/** Free a device
 * @param device_handle The handle of the device to free
 */
void mtlFreeDevice( DeviceHandle device_handle );


#pragma mark Libraries
/** Create a new library on a device from source code.
 * @param device_handle Handle to a Device
 * @param source Null-terminated string of the source code to compile
 * @return LibraryHandle on success, INVALID_HANDLE on error.
 */
LibraryHandle mtlNewLibrary( DeviceHandle device_handle, const char * source );


/** Return the device on which the library was created.
 * @param library_handle Handle to a Library
 * @return DeviceHandle on success, INVALID_HANDLE on error.
 */
DeviceHandle mtlLibraryDevice( LibraryHandle library_handle );


/** Free a library
 * @param library_handle The handle of the library to free
 */
void mtlFreeLibrary( LibraryHandle library_handle );


#pragma mark Functions
/** Create a new function in a library
 * @param library_handle Handle to a Library
 * @param function_name Name of the function defined in the library
 * @return FunctionHandle on success, INVALID_HANDLE on error.
 */
FunctionHandle mtlNewFunction( LibraryHandle library_handle, const char * function_name );


/** Free a function
 * @param function_handle The handle of the function to free
 */
void mtlFreeFunction( FunctionHandle function_handle );


#pragma mark Compute Pipeline States
/** Create a new compute pipeline state
 * @param device_handle The handle to the device on which the pipeline will be created
 * @param function_handle  The function for which the pipeline will be created.
 * @return ComputePipelineStateHandle on success, INVALID_HANDLE on error.
 */
ComputePipelineStateHandle mtlNewComputePipelineState( DeviceHandle device_handle, FunctionHandle function_handle );


/** Return the device on which the compute pipeline state was created
 * @param compute_pipeline_state_handle The handle of the compute pipeline state
 * @return DeviceHandle on succes, INVALID_HANDLE on error.
 */
DeviceHandle mtlComputePipelineStateDevice( ComputePipelineStateHandle compute_pipeline_state_handle );


/** Copy a pipeline state
 * @param compute_pipeline_state_handle The handle of the compute pipeline state to copy
 */
ComputePipelineStateHandle mtlCopyComputePipelineState( ComputePipelineStateHandle compute_pipeline_state_handle );

/** Determine the maximum number of simultaneous threads.
 * @param compute_pipeline_state_handle The handle of the compute pipeline state to query
 */
uint32_t mtlThreadExecutionWidth( ComputePipelineStateHandle compute_pipeline_state_handle );


/** Free a pipeline state
 * @param compute_pipeline_state_handle The handle of the compute pipeline state to free
 */
void mtlFreeComputePipelineState( ComputePipelineStateHandle compute_pipeline_state_handle );


#pragma mark Command Queues
/** Create a new command queue
 * @param device_handle The handle to the device on which the queue will be created
 * @return CommandQueueHandle on success, INVALID_HANDLE on error.
 */
CommandQueueHandle mtlNewCommandQueue( DeviceHandle device_handle );


/** Return the device on which the command queue was created
 * @param command_queue_handle The handle of the command queue
 * @return DeviceHandle on succes, INVALID_HANDLE on error.
 */
DeviceHandle mtlCommandQueueDevice( CommandQueueHandle command_queue_handle );


/** Free a command queue
 * @param command_queue_handle The handle of the command queue to free
 */
void mtlFreeCommandQueue( CommandQueueHandle command_queue_handle );


#pragma mark Buffers
/** Create a new buffer on the GPU
 * @param device_handle The handle to the device on which the buffer will be created
 * @param bytes Size of the buffer in bytes
 * @return BufferHandle on success, INVALID_HANDLE on error.
 */
BufferHandle mtlNewBuffer( DeviceHandle device_handle, uint64_t bytes );


/** Copy data into the GPU buffer
 * @param buffer_handle The handle to the buffer to copy data into
 * @param data A pointer to data to copy into the GPU buffer
 * @param bytes Number of bytes to copy
 * @return MTL_SUCCESS or MTL_ERROR
 */
uint32_t mtlCopyDataToBuffer( BufferHandle buffer_handle, const void * data, uint64_t bytes );


/** Copy data from the GPU buffer
 * @param buffer_handle The handle to the buffer to copy data from
 * @param data A pointer to copy the data into
 * @param bytes Number of bytes to copy
 * @return MTL_SUCCESS or MTL_ERROR
 */
uint32_t mtlCopyDataFromBuffer( BufferHandle buffer_handle, void * data, uint64_t bytes );


/** Return the size of a buffer
 * @param buffer_handle The handle of the buffer to free
 * @return MTL_ERROR if the buffer is of zero size or does not exist, size of the allocated buffer otherwise.
 */
uint64_t mtlBufferSize( BufferHandle buffer_handle );


/** Return the device on which the buffer was created
 * @param buffer_handle The handle of the buffer to free
 * @return DeviceHandle on succes, INVALID_HANDLE on error.
 */
DeviceHandle mtlBufferDevice( BufferHandle buffer_handle );


/** Free a GPU buffer
 * @param buffer_handle The handle of the buffer to free
 */
void mtlFreeBuffer( BufferHandle buffer_handle );


#pragma mark Command Buffers
/** Create a command buffer
 * @param command_queue_handle A handle to a command queue on which to create the command buffer
 * @return A handle to a command buffer or INVALID_HANDLE on error
 */
CommandBufferHandle mtlNewCommandBuffer( CommandQueueHandle command_queue_handle );



/** Return the device on which the command buffer was created
 * @param command_buffer_handle The handle of the command buffer
 * @return DeviceHandle on succes, INVALID_HANDLE on error.
 */
DeviceHandle mtlCommandBufferDevice( CommandBufferHandle command_buffer_handle );


/** Copy a command buffer
 * @param command_buffer_handle The handle of the command buffer to copy
 */
CommandBufferHandle mtlCopyCommandBuffer( CommandBufferHandle command_buffer_handle );


/** Free a command buffer
 * @param command_buffer_handle The handle of the command buffer to free
 */
void mtlFreeCommandBuffer( CommandBufferHandle command_buffer_handle );


/** Commit a command buffer for execution
 * @param command_buffer_handle The handle of the command buffer to free
 * @return MTL_SUCCESS or MTL_ERROR
 */
uint32_t mtlCommitCommandBuffer( CommandBufferHandle command_buffer_handle );

/** Wait for a command buffer to complete
 * @param command_buffer_handle The handle of the command buffer to free
 * @return MTL_SUCCESS or MTL_ERROR
 */
uint32_t mtlWaitForCompletion( CommandBufferHandle command_buffer_handle );


#pragma mark Command Encoders
/** Create a command encoder
 * @param command_buffer_handle A handle to a command buffer on which to create the command encoder
 * @return A handle to a command encoder or INVALID_HANDLE on error
 */
CommandEncoderHandle mtlNewCommandEncoder( CommandBufferHandle command_buffer_handle );


/** Free a command encoder
 * @param command_encoder_handle The handle of the command encoder to free
 */
void mtlFreeCommandEncoder( CommandEncoderHandle command_encoder_handle );


/** Set a compute pipeline state (the function to execute) to a command buffer via its command encoder
 * @param command_encoder_handle The handle of the command encoder to use
 * @return MTL_SUCCESS or MTL_ERROR
 */
uint32_t mtlSetComputePipelineState( CommandEncoderHandle command_encoder_handle, ComputePipelineStateHandle compute_pipeline_state_handle );


/** Associate a GPU buffer with a command buffer via its command encoder
 * @param command_encoder_handle The handle of the command encoder to use
 * @param buffer_handle The handle of a buffer to associate with the command encoder
 * @param index The index of the association, zero-based.
 * @return MTL_SUCCESS or MTL_ERROR
 */
uint32_t mtlSetBuffer( CommandEncoderHandle command_encoder_handle, BufferHandle buffer_handle, uint32_t index );


/** Specify the thread count and organization
 * @param command_encoder_handle The handle of the command encoder to use
 * @param compute_pipeline_state_handle The handle of the compute pipeline state which will be executed
 * @param width The size of the first dimension (usuall numelements for a one-dimensional array)
 * @param height The size of the second dimension (usually 1 for a one-dimensional array)
 * @param depth The size of the third dimension (usually 1 for a one-dimensional array)
 * @return MTL_SUCCESS or MTL_ERROR
 */
uint32_t mtlSetThreadsAndShape( CommandEncoderHandle command_encoder_handle, ComputePipelineStateHandle compute_pipeline_state_handle,  uint32_t width, uint32_t height, uint32_t depth );


/** End encoding
 * @param command_encoder_handle The handle of the command encoder
 * @return MTL_SUCCESS or MTL_ERROR
 */
uint32_t mtlEndEncoding( CommandEncoderHandle command_encoder_handle );



#ifdef  __cplusplus
}
#endif


#endif /* MatlabMetal_hpp */
