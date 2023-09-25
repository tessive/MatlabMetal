classdef MetalComputePipelineState < handle %codegen
    
    properties (SetAccess = private)
        handle = uint64(0)
        message = ""
    end
    
        
        
    properties (Dependent, SetAccess = private)
        isValid              %True if the handle is valid
        threadExecutionWidth %The maximum number of simultaneous threads
        device               %The device on which the compute pipeline state was created
    end
    
    
    methods
    
        function obj = MetalComputePipelineState( varargin ) 
            %MetalComputePipelineState Constructor for a MetalComputePipelineState object
            % Create a new MetalComputePipelineState object given
            % MetalDevice and MetalFunction objects.
            %
            % With no arguments, will create an empty, invalid class.
            %
            % Call the isValid method to determine if the object was
            % successuflly created.
            %
            %  obj = MetalComputePipelineState( )
            %  obj = MetalComputePipelineState( device, func )
            

            
            obj.Initialize( varargin{:} );
            
        end
        
        
        function Initialize( obj, varargin )
            %Initialize Initialize or reinitialize a Compute Pipeline State
            % Reinitialize the MetalComputePipelineState object given
            % MetalDevice and MetalFunction objects, or another
            % MetalComputePipelineState to copy.
            %
            % Call the isValid method to determine if the object was
            % successuflly initialized.
            %
            %  obj.Initialize() %Empty initialize
            %  obj.Initialize( ComputePipelineObj ) %Copy initialize
            %  obj.Initialize( device, func )  %Initialize with device
            %  object and function object.
            
            Metal.FreeComputePipelineState( obj.handle );
            obj.handle = uint64(0);
            
            switch nargin
                case 1
                    return
                case 2
                    computepipelineobj = varargin{ 1 };
                    obj.handle = Metal.CopyComputePipelineState( computepipelineobj.handle );
                case 3
                    deviceobj = varargin{1};
                    func = varargin{2};
                    obj.handle = Metal.NewComputePipelineState( deviceobj.handle, func.handle );
                otherwise
                    return
            end
            
            if obj.handle == uint64(0)
                obj.message = Metal.LastError;
            end
            
        end

        
        function result = get.isValid( obj )
            %isValid Returns true if the handle is valid
            result = obj.handle ~= uint64(0);
        end
        
        function result = get.threadExecutionWidth( obj )
            %threadExecutionWidth Returns the number of simultaneous
            %threads
            result = Metal.ThreadExecutionWidth( obj.handle );
        end
        
        
        function device = get.device( obj )
            %Device Returns a MetalDevice object for the device on which
            %the ComputePipelineState was created.
            device = MetalDevice( Metal.ComputePipelineStateDevice( obj.handle ) );
        end
        
        
        function delete( obj )
            Metal.FreeComputePipelineState( obj.handle );
        end
    
    end
    
end