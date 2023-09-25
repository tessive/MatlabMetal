classdef MetalBuffer < handle %codegen
    
    properties (SetAccess = private)
        handle = uint64(0)
        message = ""
        data_class = 'single'
    end
    
    properties (Dependent, SetAccess = private)
        numbytes  %The number of allocated bytes in the buffer
        isValid   %True if the handle is valid
        dimensions %The dimensions of the internal array
    end
    
    properties (Dependent)
        device    %The device on which the buffer exists (can be retrieved or set)
    end
    
    properties (Access = private)
        internal_dimensions = [0 0 0]
    end
    
    
    methods
    
        function obj = MetalBuffer( varargin )
            %MetalBuffer Constructor for a MetalBuffer object
            % Create a new MetalBuffer object given a MetalDevice object.
            %
            % If the second parameter is a three-dimensional array of
            % either single floats or uint16 values, will place that data
            % into the buffer on the specified device.
            %
            % If the second parameter is a MetalBuffer class, will create a
            % copy of the buffer data on the specified device.
            %
            % If the second parameter is a vector of doubles up to three
            % elements long, and the third  an uninitialized buffer of that
            % size will be created.  If the third parameter is specified,
            % it can be one of 'single' or 'uint16' (default is 'single' if
            % unspecified).
            %
            % Call the isValid method to determine if the object was
            % successuflly initialized.
            %
            % obj = MetalBuffer() 
            % obj = MetalBuffer( device, single_array )
            % obj = MetalBuffer( device, uint16_array )
            % obj = MetalBuffer( device, double_dimensions, [char_class] )
            % obj = MetalBuffer( device, <MetalBufferObject> )
            
            obj.Initialize( varargin{:} );
     
        end
       
        
        function Initialize( obj, varargin )
            %Initialize Re-initialize the MetalBuffer object
            % Re-initialize the MetalBuffer object given a MetalDevice object.
            %
            % If the second parameter is a three-dimensional array of
            % either single floats or uint16 values, will place that data
            % into the buffer on the specified device.
            %
            % If the second parameter is a MetalBuffer class, will create a
            % copy of the buffer data on the specified device.
            %
            % If the second parameter is a vector of doubles up to three
            % elements long, and the third  an uninitialized buffer of that
            % size will be created.  If the third parameter is specified,
            % it can be one of 'single' or 'uint16' (default is 'single' if
            % unspecified).
            %
            % Call the isValid method to determine if the object was
            % successuflly initialized.
            %
            % obj.Initialize()
            % obj.Initialize( device, single_array )
            % obj.Initialize( device, uint16_array )
            % obj.Initialize( device, double_dimensions, [char_class] )
            % obj.Initialize( device, <MetalBufferObject> )
            
            obj.deallocate;
            if nargin < 3
                return;
            end
            

            creationdevice = varargin{1};
            input = varargin{2};
            
            new_class = 'single';
            if nargin > 3
                new_class = varargin{3};
            end
            
            
            switch class(input)
                case 'MetalBuffer'
                    obj.handle = Metal.NewBuffer( creationdevice.handle, input.numbytes );
                    if obj.handle == uint64(0)
                        obj.message = Metal.LastError;
                        return
                    end
                    
                    [ data, result ] = Metal.CopyDataFromBuffer( input.handle );
                    if result == uint32(0)
                        obj.handle = uint64(0);
                        obj.message = Metal.LastError;
                        return
                    end
                    
                    result = Metal.CopyDataToBuffer( obj.handle, data );
                    if result == uint32(0)
                        obj.handle = uint64(0);
                        obj.message = Metal.LastError;
                        return
                    end
                    
                    obj.data_class = input.data_class;
                    obj.dimensions = input.dimensions;
                    
                case 'double'  %A vector of dimensions was specified
                    obj.dimensions = input;
                    obj.data_class = new_class;
                    switch new_class
                        case 'single'
                            obj.handle = Metal.NewBuffer( creationdevice.handle, prod(obj.dimensions) * 4 );
                            if obj.handle == uint64(0)
                                obj.message = Metal.LastError;
                                return
                            end
                        case 'uint16'
                            obj.handle = Metal.NewBuffer( creationdevice.handle, prod(obj.dimensions) * 2 );
                            if obj.handle == uint64(0)
                                obj.message = Metal.LastError;
                                return
                            end
                        otherwise
                            obj.message = "Unknown class type specified: " + string( new_class );
                            obj.handle = uint64(0);
                            return
                    end
                    
                case 'single'  %A single array of data was provided
                    obj.handle = Metal.NewBuffer( creationdevice.handle, numel(input) * 4 );
                    if obj.handle == uint64(0)
                        obj.message = Metal.LastError;
                        return
                    end
                    
                    result = Metal.CopySingleDataToBuffer( obj.handle, input );
                    if result == uint32(0)
                        obj.handle = uint64(0);
                        obj.message = Metal.LastError;
                        return
                    end
                    
                    obj.dimensions = size( input );
                    obj.data_class = 'single';
                    
                case 'uint16'  %A uint16 array of data was provided.
                    obj.handle = Metal.NewBuffer( creationdevice.handle, numel(input) * 2 );
                    if obj.handle == uint64(0)
                        obj.message = Metal.LastError;
                        return
                    end
                    
                    result = Metal.CopyUInt16DataToBuffer( obj.handle, input );
                    if result == uint32(0)
                        obj.handle = uint64(0);
                        obj.message = Metal.LastError;
                        return
                    end
                    
                    obj.dimensions = size( input );
                    obj.data_class = 'uint16';
                otherwise
                    obj.message = "Unknown data type for input.";
                    return
            end
            if obj.handle == uint64(0)
                obj.message = Metal.LastError;
            end 
            
        end
        
        
        function value = get.dimensions( obj )
            value = obj.internal_dimensions;
        end
        
        
        function set.dimensions( obj, value )
            obj.internal_dimensions = [ 1 1 1 ];
            obj.internal_dimensions( 1 : min( end, numel( value ) ) ) = value( 1 : min( 3, end ) );
            if any( obj.internal_dimensions == 0 )
                obj.internal_dimensions = [ 0 0 0 ];
            end
        end
        
        
        function outdata = uint16( obj )
            switch obj.data_class
                case 'uint16'
                    [ outdata, result ] = Metal.CopyUInt16DataFromBuffer( obj.handle, obj.dimensions );
                    if result == uint32(0)
                        obj.message = Metal.LastError;
                    end
                    
                case 'single'
                    [ outdata_single, result ] = Metal.CopySingleDataFromBuffer( obj.handle, obj.dimensions );
                    outdata = uint16( outdata_single );
                    if result == uint32(0)
                        obj.message = Metal.LastError;
                    end
                    
                otherwise
                    obj.message = "Unknown internal type";
                    outdata = zeros( obj.dimensions, 'uint16');
            end
            
        end

        
        
        function [ outdata ] = single( obj )            
            switch obj.data_class
                case 'uint16'
                    [ outdata_uint16, result ] = Metal.CopyUInt16DataFromBuffer( obj.handle, obj.dimensions );
                    outdata = single( outdata_uint16 );
                    if result == uint32(0)
                        obj.message = Metal.LastError;
                    end
                    
                case 'single'
                    [ outdata, result ] = Metal.CopySingleDataFromBuffer( obj.handle, obj.dimensions );
                    if result == uint32(0)
                        obj.message = Metal.LastError;
                    end
                    
                otherwise
                    obj.message = "Unknown internal type";
                    outdata = zeros( obj.dimensions, 'single');
            end
        end
        
        
        
        function device = get.device( obj )
            device = MetalDevice( Metal.BufferDevice( obj.handle ) );
        end
        
        
        
        function set.device( obj, device )
            currentDevice = MetalDevice( Metal.BufferDevice( obj.handle ) );
            
            if ~currentDevice.isequal( device )
                newhandle = Metal.NewBuffer( device.handle, obj.numbytes );
                if newhandle == uint64(0)
                    obj.deallocate;
                    obj.message = Metal.LastError;
                    return
                end
                
                [ data, result ] = Metal.CopyDataFromBuffer( obj.handle );
                if result == uint32(0)
                    obj.deallocate;
                    obj.message = Metal.LastError;
                    return
                end
                
                result = Metal.CopyDataToBuffer( newhandle, data );
                if result == uint32(0)
                    obj.deallocate;
                    obj.message = Metal.LastError;
                    return
                end
                
                obj.handle = newhandle;
            end
            
        end
        
        
        
        function value = get.numbytes( obj )
            value = Metal.BufferSize( obj.handle );
        end
        
        
        
        function result = get.isValid( obj )
            %isValid Returns true if the handle is valid
            result = obj.handle ~= uint64(0);
        end

        
        function deallocate( obj )
            Metal.FreeBuffer( obj.handle );
            obj.handle = uint64(0);
            obj.data_class = 'single';
            obj.message = "";
            obj.internal_dimensions = [0 0 0];
        end
        
        
        function delete( obj )
            obj.deallocate;
        end
    
    end
    
end