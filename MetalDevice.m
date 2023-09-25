classdef MetalDevice < handle %codegen
    
    properties (SetAccess = private)
        handle = uint64(0)  %Internal library handle
        message = ""        %Error message if invalid
    end
    
    
        
    properties (Dependent, SetAccess = private)
        isValid   %True if the handle is valid
        info      %Struct of device information
    end
    
    
    methods
    
        function obj = MetalDevice( input )
            %MetalDevice Constructor for a MetalDevice object
            % If a double float is provided, create a new MetalDevice
            % object given the index (one-based) of the device on the
            % system as listed by Metal.GetDevices
            %
            % If a uint64 value is provided, create a new MetalDevice
            % object using the input as a device_handle (without copying).
            %
            % If a MetalDevice is used as the input, will create a copy.
            %
            % Call the isValid method to determine if the object was
            % successuflly initialized.
            %
            % obj = MetalDevice( index )
            
            obj.SwitchDevice( input );
        end
        
        function result = get.isValid( obj )
            %isValid Returns true if the handle is valid
            result = obj.handle ~= uint64(0);
        end
        
        function SwitchDevice( obj,  input )
            %SwitchDevice Initializer for a MetalDevice object
            % If a double float is provided, initialize the MetalDevice
            % object given the index (one-based) of the device on the
            % system as listed by Metal.GetDevices
            %
            % If a uint64 value is used as the input, will use this as the
            % handle to the MetalDevice without a copy.
            %
            % If a MetalDevice is used as the input, will create a copy.
            %
            % Call the isValid method to determine if the object was
            % successuflly initialized.
            %
            % obj = MetalDevice( index )
            
            Metal.FreeDevice( obj.handle );
            obj.handle = uint64(0);
            
            switch class( input )
                case 'MetalDevice'
                    obj.handle = Metal.CopyDevice( input.handle );
                case 'uint64'
                    obj.handle = input;
                otherwise
                    obj.handle = Metal.GetDeviceAtIndex( input );
            end

        end
        
        
        function value = get.info(obj)
            
            [result, value] = Metal.GetDeviceInfo( obj.handle );
            if result == uint32(0)
                obj.message = Metal.LastError;
            end
        end
        
        
        function result = isequal( self, other )
            result = Metal.IsSameDevice( self.handle, other.handle );
        end
        
        function delete( obj )
            Metal.FreeDevice( obj.handle );
        end
    
    end
    
    methods (Static)
        
        function obj = CurrentDevice
            %CurrentDevice Return a MetalDevice object for the currently
            %selected device in Metal.Config
            
            persistent CachedDeviceID MetalDeviceObj
            
            config = Metal.Config;
            if isempty( CachedDeviceID ) || isempty( MetalDeviceObj )
                CachedDeviceID = config.gpudevice;
                MetalDeviceObj =  MetalDevice( CachedDeviceID );
            end
            
            if CachedDeviceID ~= config.gpudevice
                CachedDeviceID = config.gpudevice;
                MetalDeviceObj.SwitchDevice( CachedDeviceID );
            end
            
            
            obj = MetalDeviceObj;
            
        end
        
    end
    
    
end