//
//  main.cpp
//  TestMatlabMetal
//


#include <iostream>
#include "MatlabMetal.h"

using namespace std;

inline const char * const BoolToString(bool b)
{
  return b ? "TRUE" : "FALSE";
}


void printDevice( mtlDeviceInfo deviceStruct)
{
    cout << " Name:        " << deviceStruct.name << endl;
    cout << " WorkSize:    " << deviceStruct.recommendedMaxWorkingSetSize << endl;
    cout << " Registry ID: " << deviceStruct.RegistryID << endl;
    cout << " Low Power:   " << BoolToString( deviceStruct.IsLowPower ) << endl;
    cout << " Headless:    " << BoolToString( deviceStruct.IsHeadless ) << endl;
}


void printDevices( mtlDeviceInfo * devices, int numDevices)
{
    for (int i = 0; i < numDevices; i++)
    {
        cout << "[Device " << i << "]" << endl;
        printDevice( devices[i] );
        cout << endl;
    }
}


int main(int argc, const char * argv[]) {
    
    mtlDeviceInfo * deviceInfoStructs;
    DeviceHandle device;
    
    // Determine the number of devices
    int numDevices = mtlNumberOfDevices();

    // Get and print the device information
    deviceInfoStructs = (mtlDeviceInfo * )malloc( numDevices * sizeof(mtlDeviceInfo));
    for (int i = 0; i < numDevices; i++)
    {
        device = mtlGetDeviceAtIndex( i );
        mtlGetDeviceInfo(device, &deviceInfoStructs[i] );
        mtlFreeDevice(i);
    }
    
    printDevices(deviceInfoStructs, numDevices);
    free(deviceInfoStructs);
    
    // Select a device and retrieve the handle
    device = mtlGetDeviceAtIndex( numDevices - 1 );
    assert( device != INVALID_HANDLE );
    
    // Copy the device
    DeviceHandle dev1copy = mtlCopyDevice( device );
    assert( dev1copy != 0 );
    assert( mtlSameDevice( device, dev1copy ) );
    
    // Check that a second device handle to the same device will match
    DeviceHandle device2 = mtlGetDeviceAtIndex( numDevices - 1 );
    assert( device != device2 );
    assert( mtlSameDevice( device, device2 ) );
    mtlFreeDevice(device2);

    // *****  Build a valid library
    const char source[] = R"""(
        #include <metal_stdlib>
        using namespace metal;

        kernel void sqr(
            const device float *vIn [[ buffer(0) ]],
            device float *vOut [[ buffer(1) ]],
            uint id[[ thread_position_in_grid ]])
        {
            vOut[id] = vIn[id] * vIn[id];
        }
    )""";
    
    LibraryHandle library = mtlNewLibrary( device, source );
    assert( library != INVALID_HANDLE );
    device2 = mtlLibraryDevice( library );
    assert( mtlSameDevice( device, device2 ) );
    mtlFreeDevice( device2 );
           
    // *****   Build an invalid library
    const char invalidsource[] = R"""(
        #include <metal_stdlib>
        using namespace metal // Missing a semicolon here

        kernel void sqr(
            const device float *vIn [[ buffer(0) ]],
            device float *vOut [[ buffer(1) ]],
            uint id[[ thread_position_in_grid ]])
        {
            vOut[id] = vIn[id] * vIn[id];
        }
    )""";
    
    LibraryHandle invalidlibrary = mtlNewLibrary( device, invalidsource );
    assert( invalidlibrary == INVALID_HANDLE );
    char error[1024];
    cout << "Expecting a failed compilation message -> ";
    mtlGetLastError(error, 1024);
    cout << error << endl ;
    
    // Create a valid function
    FunctionHandle function = mtlNewFunction(library, "sqr");
    assert( function != INVALID_HANDLE);
    
    // Create an invalid function
    FunctionHandle invalidfunction = mtlNewFunction(library, "nonexist"); // This function does not exist.
    assert( invalidfunction == INVALID_HANDLE);
    cout << "Expecting an error creating function -> ";
    mtlGetLastError(error, 1024);
    cout << error << endl ;
    
    // Create a compute pipeline state
    ComputePipelineStateHandle compute_pipeline_state = mtlNewComputePipelineState( device, function );
    assert( compute_pipeline_state != INVALID_HANDLE );
    device2 = mtlComputePipelineStateDevice( compute_pipeline_state );
    assert( mtlSameDevice(device, device2));
    mtlFreeDevice(device2);
    
    // Create an invalid compute pipeline state
    ComputePipelineStateHandle invalid_compute_pipeline_state = mtlNewComputePipelineState( device, invalidfunction );
    assert( invalid_compute_pipeline_state == INVALID_HANDLE );
    cout << "Expecting an error creating pipeline state -> ";
    mtlGetLastError(error, 1024);
    cout << error << endl ;
    
    // Create a command queue
    CommandQueueHandle command_queue = mtlNewCommandQueue( device );
    assert( command_queue != INVALID_HANDLE);
    device2 = mtlCommandQueueDevice( command_queue );
    assert( mtlSameDevice(device, device2));
    mtlFreeDevice(device2);
    
    // Create a buffer
    uint32_t num_elements = 100E6;
    float * test_data, * return_data;
    test_data = (float *)malloc(num_elements * sizeof(float));
    return_data = (float *)malloc(num_elements * sizeof(float));
    uint64_t buffer_length = num_elements * sizeof(float);
    
    
    // Create a test set
    for (int i = 0; i < num_elements; i++)
        test_data[i] = 3.0f*(float)i + 10.0f;
    
    // Test repeated allocation and copy (look for memory leaks)
    for (int i = 0; i < 100; i++)
    {
        BufferHandle buffer = mtlNewBuffer(device, buffer_length );
        mtlCopyDataToBuffer( buffer, (uint8_t *)test_data, buffer_length );
        mtlFreeBuffer(buffer);
    }
    
    BufferHandle buffer = mtlNewBuffer(device, buffer_length );
    assert( buffer != INVALID_HANDLE );
    assert( mtlBufferSize(buffer) == buffer_length);
    device2 = mtlBufferDevice( buffer );
    assert( mtlSameDevice( device, device2 ) );
    mtlFreeDevice(device2);


    
    // Try copying too much data into the buffer
    uint32_t result = mtlCopyDataToBuffer( buffer, (uint8_t *)test_data, buffer_length + 1 );
    assert( result == MTL_ERROR );
    
    // Copy data into the buffer
    result = mtlCopyDataToBuffer( buffer, (uint8_t *)test_data, buffer_length );
    assert( result == MTL_SUCCESS );

    // Read data out of the buffer
    result = mtlCopyDataFromBuffer(buffer, (uint8_t *)return_data, buffer_length);
    assert( result == MTL_SUCCESS );
    
    // Verify the data
    for (int i = 0; i < num_elements; i++ )
        assert( test_data[i] == return_data[i] );
    
    // Check that deallocation works (this test may be a bit flaky depending on the device's lazy free of memory.)
    mtlFreeBuffer(buffer);
    assert( mtlBufferSize(buffer) == 0);
    int64_t StartingAllocation = mtlGetDeviceAllocatedMemory( device );
    for (int i = 0; i < 10; i++)
    {
        buffer = mtlNewBuffer( device, buffer_length );
        mtlFreeBuffer( buffer );
        assert( mtlGetDeviceAllocatedMemory( device ) == StartingAllocation );
    }
    
    
    // Create a command buffer
    CommandBufferHandle command_buffer = mtlNewCommandBuffer(command_queue);
    assert( command_buffer != INVALID_HANDLE );
    device2 = mtlCommandBufferDevice(command_buffer);
    assert( mtlSameDevice(device, device2));
    mtlFreeDevice(device2);
    
    // Create a command encoder
    CommandEncoderHandle command_encoder = mtlNewCommandEncoder(command_buffer);
    assert( command_encoder != INVALID_HANDLE );
    
    // Set up the function to run
    BufferHandle source_buffer = mtlNewBuffer( device, buffer_length );
    BufferHandle return_buffer = mtlNewBuffer( device, buffer_length );
    mtlCopyDataToBuffer( source_buffer, ( uint8_t * )test_data, buffer_length );
    
    result = mtlSetComputePipelineState(command_encoder, compute_pipeline_state );
    assert( result == MTL_SUCCESS );
    result = mtlSetBuffer(command_encoder, source_buffer, 0);
    assert( result == MTL_SUCCESS );
    result = mtlSetBuffer(command_encoder, return_buffer, 1);
    assert( result == MTL_SUCCESS );
    result = mtlSetThreadsAndShape( command_encoder, compute_pipeline_state,  num_elements, 1, 1 );
    assert( result == MTL_SUCCESS );
    result = mtlEndEncoding( command_encoder );
    assert( result == MTL_SUCCESS );
    result = mtlCommitCommandBuffer( command_buffer );
    assert( result == MTL_SUCCESS );
    result = mtlWaitForCompletion( command_buffer );
    assert( result == MTL_SUCCESS );
    
    // Check the results
    result = mtlCopyDataFromBuffer(return_buffer, (uint8_t *)return_data, buffer_length);
    assert( result == MTL_SUCCESS );
    for (int i = 0; i < num_elements; i++ )
        assert( return_data[i] == test_data[i] * test_data[i] );
    
    // Free the resources
    free( return_data );
    free( test_data );
    mtlFreeBuffer(source_buffer);
    mtlFreeBuffer(return_buffer);
    mtlFreeCommandEncoder(command_encoder);
    mtlFreeCommandBuffer(command_buffer);
    mtlFreeComputePipelineState(compute_pipeline_state);
    mtlFreeFunction(function);
    mtlFreeLibrary(library);
    mtlFreeDevice(device);
    
    return 0;
}



