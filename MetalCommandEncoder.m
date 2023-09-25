classdef MetalCommandEncoder < handle %codegen
    
    properties (SetAccess = private)
        handle = uint64(0)  %Internal library handle
        message = ""        %Error message if invalid
    end
        
    properties (Dependent, SetAccess = private)
        isValid   %True if the handle is valid
    end
    
    properties (Access = private)
        EncodingEnded = false
    end

    
    methods
    
        function obj = MetalCommandEncoder( command_buffer )
            %MetalCommandEncoder Constructor for a MetalCommandEncoder object
            % Create a new MetalCommandEncoder object given a
            % MetalCommandBuffer object to associate it with.
            %
            % Call the isValid method to determine if the object was
            % successuflly created.
            %
            %  obj = MetalCommandEncoder( command_buffer )
            
            obj.handle = Metal.NewCommandEncoder( command_buffer.handle );
            if obj.handle == uint64(0)
                obj.message = Metal.LastError;
            end
            
        end
        
        
        function result = get.isValid( obj )
            %isValid Returns true if the handle is valid
            result = obj.handle ~= uint64(0);
        end
        
        
        function result = SetComputePipelineState( obj, compute_pipeline_state )
            %SetComputePipelineState Set the compute pipeline state to use
            % Returns uint32(1) on success, uint32(0) on error (with
            % message placed in the "message" property.)
            
            result = Metal.SetComputePipelineState( obj.handle, compute_pipeline_state.handle );
            if result == uint32(0)
                obj.message = Metal.LastError;
            end
        end
        
        
        function result = SetBuffer( obj, buffer, index )
            %SetBuffer Set a buffer as an argument at index (one-based)
            %  Given a MetalBuffer object and an index of the argument
            %  position (one-based), will associate the buffer with the
            %  function.
            %
            %  Returns uint32(1) on success, uint32(0) on error (with
            %  message placed in the "message" property.)
            
            result = Metal.SetBuffer( obj.handle, buffer.handle, index );
            if result == uint32(0)
                obj.message = Metal.LastError;
            end
        end
        
        
        function result = SetThreadsAndShape( obj, compute_pipeline_state, dims )
            %SetThreadsAndShape Set the shape of the data and thread setup
            %  Given a MetalComputePipelineState object and the dimensions
            %  of the buffer data (up to three dimensions), will set the
            %  size and shape of processing.
            %
            %  Returns uint32(1) on success, uint32(0) on error (with
            %  message placed in the "message" property.)
            
            result = Metal.SetThreadsAndShape( obj.handle, compute_pipeline_state.handle, dims );
            if result == uint32(0)
                obj.message = Metal.LastError;
            end
        end
        
        
        function result = EndEncoding( obj )
            %EndEncoding End the encoding operations
            %  Signals the end of encoding pipeline operations.
            %
            %  Returns uint32(1) on success, uint32(0) on error (with
            %  message placed in the "message" property.)
            
            result = Metal.EndEncoding( obj.handle );
            if result == uint32(0)
                obj.message = Metal.LastError;
            end
            obj.EncodingEnded = true;
        end
        
        
        function delete( obj )
            if ~obj.EncodingEnded 
                obj.EndEncoding;
            end
            Metal.FreeCommandEncoder( obj.handle );
        end
    
    end
    
end