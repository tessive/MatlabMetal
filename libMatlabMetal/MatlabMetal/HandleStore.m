//
//  HandleStore.m
//  MatlabMetal
//
//  Created by Anthony Davis on 1/27/21.
//

#import <Foundation/Foundation.h>
#import "HandleStore.h"


@implementation HandleStore

static NSMutableDictionary * _devices = nil;
static NSInteger _next_device_handle = 1;

static NSMutableDictionary * _libraries = nil;
static NSInteger _next_library_handle = 1;

static NSMutableDictionary * _functions = nil;
static NSInteger _next_function_handle = 1;

static NSMutableDictionary * _compute_pipeline_states = nil;
static NSInteger _next_compute_pipeline_state = 1;

static NSMutableDictionary * _command_queues = nil;
static NSInteger _next_command_queue = 1;

static NSMutableDictionary * _buffers = nil;
static NSInteger _next_buffer = 1;

static NSMutableDictionary * _command_buffers = nil;
static NSInteger _next_command_buffer = 1;

static NSMutableDictionary * _command_encoders = nil;
static NSInteger _next_command_encoder = 1;

#pragma mark Lifecycle

+(id) getInstance
{
    static HandleStore *_sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedInstance = [[self alloc] init];
    });
    return _sharedInstance;
}


-(id) init
{
    if ((self = [super init]) != nil) {
        // Initialize the hash tables
        _devices = [ NSMutableDictionary new ];
        _libraries = [ NSMutableDictionary new ];
        _functions = [ NSMutableDictionary new ];
        _compute_pipeline_states = [ NSMutableDictionary new ];
        _command_queues = [ NSMutableDictionary new ];
        _buffers = [ NSMutableDictionary new ];
        _command_buffers = [ NSMutableDictionary new ];
        _command_encoders = [ NSMutableDictionary new ];
    }
    return self;
}

#pragma mark Handle Methods

-(id<MTLDevice>) Handle2Device:(DeviceHandle) handle
{
    return [_devices objectForKey:[NSNumber numberWithInteger:handle]];
}



-(DeviceHandle) Device2Handle:(id<MTLDevice>) obj
{
    if (obj == nil) {
        return ( DeviceHandle )INVALID_HANDLE;
    }
    
    [_devices setObject:obj forKey:[NSNumber numberWithInteger:_next_device_handle]];
    
    return (_next_device_handle++);
}


- (void)FreeDevice:(DeviceHandle)handle
{
    [ _devices removeObjectForKey:[NSNumber numberWithInteger:handle] ];
}



-(id<MTLLibrary>) Handle2Library:(LibraryHandle) handle
{
    return [_libraries objectForKey:[NSNumber numberWithInteger:handle]];
}


-(LibraryHandle) Library2Handle:(id<MTLLibrary>) obj
{
    if (obj == nil) {
        return ( LibraryHandle )INVALID_HANDLE;
    }
    
    [_libraries setObject:obj forKey:[NSNumber numberWithInteger:_next_library_handle]];
    
    return (_next_library_handle++);
}


- (void)FreeLibrary:(LibraryHandle)handle
{
    [ _libraries removeObjectForKey:[NSNumber numberWithInteger:handle] ];
}


-(id<MTLFunction>) Handle2Function:(FunctionHandle)handle
{
    return [_functions objectForKey:[NSNumber numberWithInteger:handle]];
}




- (FunctionHandle)Function2Handle:(id<MTLFunction>)obj
{
    if (obj == nil) {
        return ( FunctionHandle )INVALID_HANDLE;
    }
    
    [_functions setObject:obj forKey:[NSNumber numberWithInteger:_next_function_handle]];
    
    return (_next_function_handle++);
}


- (void)FreeFunction:(FunctionHandle)handle
{
    [ _functions removeObjectForKey:[NSNumber numberWithInteger:handle] ];
}


- (id<MTLComputePipelineState>)Handle2ComputePipelineState:(ComputePipelineStateHandle)handle
{
    return [_compute_pipeline_states objectForKey:[NSNumber numberWithInteger:handle]];
}



- (ComputePipelineStateHandle)ComputePipelineState2Handle:(id<MTLComputePipelineState>)obj
{
    if (obj == nil) {
        return ( ComputePipelineStateHandle )INVALID_HANDLE;
    }
    
    [_compute_pipeline_states setObject:obj forKey:[NSNumber numberWithInteger:_next_compute_pipeline_state]];
    
    return (_next_compute_pipeline_state++);
}



- (void)FreeComputePipelineState:(ComputePipelineStateHandle)handle
{
    [ _compute_pipeline_states removeObjectForKey:[NSNumber numberWithInteger:handle] ];
}



- (id<MTLCommandQueue>)Handle2CommandQueue:(CommandQueueHandle)handle
{
    return [_command_queues objectForKey:[NSNumber numberWithInteger:handle]];
}



- (CommandQueueHandle)CommandQueue2Handle:(id<MTLCommandQueue>)obj
{
    if (obj == nil) {
        return ( CommandQueueHandle )INVALID_HANDLE;
    }
    
    [_command_queues setObject:obj forKey:[NSNumber numberWithInteger:_next_command_queue]];
    
    return (_next_command_queue++);
}


- (void)FreeCommandQueue:(CommandQueueHandle)handle
{
    [ _command_queues removeObjectForKey:[NSNumber numberWithInteger:handle] ];
}



- (id<MTLBuffer>)Handle2Buffer:(BufferHandle)handle
{
    return [_buffers objectForKey:[NSNumber numberWithInteger:handle]];
}



- (BufferHandle)Buffer2Handle:(id<MTLBuffer>)obj
{
    if (obj == nil) {
        return ( BufferHandle )INVALID_HANDLE;
    }
    
    [_buffers setObject:obj forKey:[NSNumber numberWithInteger:_next_buffer]];
    
    return (_next_buffer++);
}


- (void)FreeBuffer:(BufferHandle)handle
{
    [ _buffers removeObjectForKey:[NSNumber numberWithInteger:handle] ];
}


- (id<MTLCommandBuffer>)Handle2CommandBuffer:(CommandBufferHandle)handle
{
    return [_command_buffers objectForKey:[NSNumber numberWithInteger:handle]];
}



- (CommandBufferHandle)CommandBuffer2Handle:(id<MTLCommandBuffer>)obj
{
    if (obj == nil) {
        return ( CommandBufferHandle )INVALID_HANDLE;
    }
    
    [_command_buffers setObject:obj forKey:[NSNumber numberWithInteger:_next_command_buffer]];
    
    return (_next_command_buffer++);
}


- (void)FreeCommandBuffer:(CommandBufferHandle)handle
{
    [ _command_buffers removeObjectForKey:[NSNumber numberWithInteger:handle] ];
}



- (id<MTLComputeCommandEncoder>)Handle2CommandEncoder:(CommandEncoderHandle)handle
{
    return [_command_encoders objectForKey:[NSNumber numberWithInteger:handle]];
}



- (CommandEncoderHandle)CommandEncoder2Handle:(id<MTLComputeCommandEncoder>)obj
{
    if (obj == nil) {
        return ( CommandBufferHandle )INVALID_HANDLE;
    }
    
    [_command_encoders setObject:obj forKey:[NSNumber numberWithInteger:_next_command_encoder]];
    
    return (_next_command_encoder++);
}


- (void)FreeCommandEncoder:(CommandEncoderHandle)handle
{
    [ _command_encoders removeObjectForKey:[NSNumber numberWithInteger:handle] ];
}

@end
