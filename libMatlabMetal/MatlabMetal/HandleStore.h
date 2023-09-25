//
#ifndef HandleStore_h
#define HandleStore_h

#import "MatlabMetal.h"
#import <Metal/Metal.h>

@interface HandleStore : NSObject


/**
 * Return the singleton handle store instance
 **/
+(id) getInstance;

-(id<MTLDevice>) Handle2Device:(DeviceHandle) handle;
-(DeviceHandle) Device2Handle:(id<MTLDevice>) obj;
-(void) FreeDevice:(DeviceHandle) handle;

-(id<MTLLibrary>) Handle2Library:(LibraryHandle) handle;
-(LibraryHandle) Library2Handle:(id<MTLLibrary>) obj;
-(void) FreeLibrary:(LibraryHandle) handle;

-(id<MTLFunction>) Handle2Function:(FunctionHandle) handle;
-(FunctionHandle) Function2Handle:(id<MTLFunction>) obj;
-(void) FreeFunction:(FunctionHandle) handle;

-(id<MTLComputePipelineState>) Handle2ComputePipelineState:(ComputePipelineStateHandle) handle;
-(ComputePipelineStateHandle) ComputePipelineState2Handle:(id<MTLComputePipelineState>) obj;
-(void) FreeComputePipelineState:(ComputePipelineStateHandle) handle;

-(id<MTLCommandQueue>) Handle2CommandQueue:(CommandQueueHandle) handle;
-(CommandQueueHandle) CommandQueue2Handle:(id<MTLCommandQueue>) obj;
-(void) FreeCommandQueue:(CommandQueueHandle) handle;

-(id<MTLBuffer>) Handle2Buffer:(BufferHandle) handle;
-(BufferHandle) Buffer2Handle:(id<MTLBuffer>) obj;
-(void) FreeBuffer:(BufferHandle) handle;

-(id<MTLCommandBuffer>) Handle2CommandBuffer:(CommandBufferHandle) handle;
-(CommandBufferHandle) CommandBuffer2Handle:(id<MTLCommandBuffer>) obj;
-(void) FreeCommandBuffer:(CommandBufferHandle) handle;

-(id<MTLComputeCommandEncoder>) Handle2CommandEncoder:(CommandEncoderHandle) handle;
-(CommandEncoderHandle) CommandEncoder2Handle:(id<MTLComputeCommandEncoder>) obj;
-(void) FreeCommandEncoder:(CommandEncoderHandle) handle;

@end


#endif /* HandleStore_h */
