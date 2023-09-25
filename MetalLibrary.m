classdef MetalLibrary < handle %codegen
    
    properties (SetAccess = private)
        handle = uint64(0)
        message = "Uninitialized"
    end
    
        
        
    properties (Dependent, SetAccess = private)
        isValid   %True if the handle is valid
        device    %The device on which the library was created
    end
    
    
    methods
    
        function obj = MetalLibrary( varargin )
            %MetalLibrary Constructor for a MetalLibrary object
            % Create a new MetalLibrary object given a MetalDevice object
            % on which to create it as well as a string of the source code
            % to use.
            %
            % With no arguments, creates an empty MetalLibrary class.
            %
            % Call the isValid method to determine if the object was
            % successuflly created.
            %
            %  obj = MetalLibrary( device, source )
            
            if nargin < 2
                return
            end
            
            device = varargin{ 1 };
            source = varargin{ 2 };
            obj.Initialize( device, source );
        end
        
        
        function Initialize(obj, device, source )
            %Initialize (Re-)Initialize a MetalLibrary object
            % Re-Initialize the MetalLibrary object given a MetalDevice object
            % on which to create it as well as a string of the source code
            % to use.
            %
            % Call the isValid method to determine if the object was
            % successuflly created.
            %
            %  obj.Initialize( device, source )
            
            Metal.FreeLibrary( obj.handle );
            obj.handle = uint64(0);
            obj.message = "";
            obj.handle = Metal.NewLibrary( device.handle, source );
            if obj.handle == uint64(0)
                obj.message = Metal.LastError;
            end
        end
        
        
        function device = get.device( obj )
            device_handle = Metal.LibraryDevice( obj.handle );
            device = MetalDevice( device_handle );
        end
           
        
        function result = get.isValid( obj )
            %isValid Returns true if the handle is valid
            result = obj.handle ~= uint64(0);
        end
        
        function delete( obj )
            Metal.FreeLibrary( obj.handle );
        end
    
    end
    
end