classdef MetalCommandQueue < handle %codegen
    
    properties (SetAccess = private)
        handle = uint64(0)
        message = ""
    end
    
        
    properties (Dependent, SetAccess = private)
        isValid   %True if the handle is valid
        device    %The device on which the command queue was created
    end
    
    
    methods
    
        function obj = MetalCommandQueue( device )
            %MetalCommandQueue Constructor for a MetalCommandQueue object
            % Create a new MetalCommandQueue object given a
            % MetalDevice object.
            %
            % Call the isValid method to determine if the object was
            % successuflly created.
            %
            %  obj = MetalCommandQueue( device )
            
            obj.UpdateDevice( device );
            
        end
        
        function result = get.isValid( obj )
            %isValid Returns true if the handle is valid
            result = obj.handle ~= uint64(0);
        end
        
        function device = get.device( obj )
            %Device Returns a MetalDevice object for the device on which
            %the command queue was created.
            device = MetalDevice( Metal.CommandQueueDevice( obj.handle ) );
        end
        
        function UpdateDevice( obj, device )
            %UpdateDevice Change the queue to a new device (creates a new
            %queue on the system)
            
            Metal.FreeCommandQueue( obj.handle );
            obj.handle = Metal.NewCommandQueue( device.handle );
            if obj.handle == uint64(0)
                obj.message = Metal.LastError;
            end
        end
        
        
        function delete( obj )
            Metal.FreeCommandQueue( obj.handle );
        end
    
    end
    
    methods (Static)
        
        function command_queue = CurrentCommandQueue
            %CurrentCommandQueue Returns the current command queue for the
            %device selected in Metal.Config
            
            persistent internal_command_queue
            
            selected_device =  MetalDevice.CurrentDevice;
            
            if isempty( internal_command_queue )
                internal_command_queue = MetalCommandQueue( selected_device );
            end
            
            if ( ~isequal( selected_device, internal_command_queue.device ) )
                internal_command_queue.UpdateDevice( selected_device );
            end
            
            command_queue = internal_command_queue;

        end
    end
    
end