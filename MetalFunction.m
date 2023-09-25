classdef MetalFunction < handle %codegen
    
    properties (SetAccess = private)
        handle = uint64(0)  %Internal library handle
        message = ""        %Error message if invalid
    end
        
    properties (Dependent, SetAccess = private)
        isValid   %True if the handle is valid
    end
    
    
    methods
    
        function obj = MetalFunction( library, function_name )
            %MetalLibrary Constructor for a MetalLibrary object
            % Create a new MetalFunction object given a MetalLibrary object
            % in which it resides as well as the function name as a string
            % object.
            %
            % Call the isValid method to determine if the object was
            % successuflly created.
            %
            %  obj = MetalFunction( library, function_name )
            
            obj.handle = Metal.NewFunction( library.handle, function_name );
            if obj.handle == uint64(0)
                obj.message = Metal.LastError;
            end
            
        end
        
        function result = get.isValid( obj )
            %isValid Returns true if the handle is valid
            result = obj.handle ~= uint64(0);
        end
        
        function delete( obj )
            Metal.FreeFunction( obj.handle );
        end
    
    end
    
end