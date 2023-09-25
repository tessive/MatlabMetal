classdef MetalCommandBuffer < handle %codegen

    %   Copyright 2023 Tessive LLC  See LICENSE file for full license information.
    
    properties (SetAccess = private)
        handle = uint64(0)  %Internal library handle
        message        %Error message if invalid
    end
        
    properties (Dependent, SetAccess = private)
        isValid   %True if the handle is valid
        device    %The device on which the command buffer exists
    end

    
    methods
    
        function obj = MetalCommandBuffer( varargin )
            %MetalCommandBuffer Constructor for a MetalCommandBuffer object
            % Create a new MetalCommandBuffer object.
            %
            % With no arguments, creates a null class.
            %
            % Given a MetalCommandQueue object to associate it with, will
            % allocate a new MetalCommandBuffer.
            %
            % Given a MetalCommandBuffer object, will construct a copy.
            %
            % Call the isValid method to determine if the object was
            % successuflly created.
            %
            %  obj = MetalCommandBuffer( command_queue )
            
            obj.Initialize( varargin{:} );
            
        end
        
        
        function Initialize( obj, varargin )
            %Initialize Initializer for a MetalCommandBuffer object
            % Initialize or reinitialize a new MetalCommandBuffer object.
            %
            % With no arguments, creates a null class.
            %
            % Given a MetalCommandQueue object to associate it with, will
            % allocate a new MetalCommandBuffer.
            %
            % Given a MetalCommandBuffer object, will construct a copy.
            %
            % Call the isValid method to determine if the object was
            % successuflly created.
            %
            %  obj = MetalCommandBuffer( command_queue )
            
            Metal.FreeCommandBuffer( obj.handle );
            obj.handle = uint64(0);
            obj.message = "Uninitialized";
            
            if nargin == 1
                return
            end
            
            input = varargin{1};
            switch( class( input ) )
                case 'MetalCommandQueue'
                    obj.handle = Metal.NewCommandBuffer( input.handle );
                    
                case 'MetalCommandBuffer'
                    obj.handle = Metal.CopyCommandBuffer( input.handle );
                    
                otherwise
            end
            
            if obj.handle == uint64(0)
                obj.message = Metal.LastError;
            end
            
        end
        
        
        function result = get.isValid( obj )
            %isValid Returns true if the handle is valid
            result = obj.handle ~= uint64(0);
        end
      
        
        function device = get.device( obj )
            device_handle = Metal.CommandBufferDevice( obj.handle );
            device = MetalDevice( device_handle );
        end
        
        
        function result = Commit( obj )
            %Commit Commit the command buffer for processing
            % Returns uint32(1) on success, uint32(0) on error (with
            % message placed in the "message" property.)
            
            result = Metal.CommitCommandBuffer( obj.handle );
            if result == uint32(0)
                obj.message = Metal.LastError;
            end
        end
        
        
        function result = WaitForCompletion( obj )
            %WaitForCompletion Wait for the command buffer to complete processing.
            % Returns uint32(1) on success, uint32(0) on error (with
            % message placed in the "message" property.)
            
            result = Metal.WaitForCompletion( obj.handle );
            if result == uint32(0)
                obj.message = Metal.LastError;
            end
        end
        
        
        function delete( obj )
            Metal.FreeCommandBuffer( obj.handle );
        end
    
    end
    
end