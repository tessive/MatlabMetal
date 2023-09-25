classdef MetalConfig < handle %#codegen
    %MetalConfig A class for handling Metal GPU configuration
    %   Get and set hardware configuration for the Metal GPU. This 
    %   class is used by the Metal class.  
    %
    %   The MetalConfig class provides system-level information and
    %   selection of the processing system to be used by the running
    %   process.  The only user-selectable property is the gpuoptionindex,
    %   which is a one-based index into the gpuoptions array indicating
    %   which GPU option is to be used for processing. 
    %
    %   It is usually accessed through the Metal class which maintains an
    %   instance of the config class and uses it for all operations.
    %
    %   Example:  
    %      gpuconfig = Metal.Config;
    %      gpuconfig.gpuoptions
    %    
    %   ans =                                             
    %      'Metal  Device 0: AMD Radeon Pro Vega 20 with 3.98 GB  '
    %      'Metal  Device 1: Intel(R) UHD Graphics 630 with 1.5 GB'
    %     
    %   To select the second GPU (Device 0), set the gpuoptionindex
    %   property to 2 (the second row in the gpuoptions property)
    % 
    %   gpuconfig.gpuoptionindex = 2
    %   gpuconfig.selectedgpustring
    %
    %   ans =
    %       'Metal  Device 1: Intel(R) UHD Graphics 630 with 1.5 GB'
    %
    %   The other properties are read-only, and indicate which device (a
    %   one-based number).

    %   Copyright 2023 Tessive LLC  See LICENSE file for full license information.
    
    properties (Dependent)
        gpuoptionindex          %The option selected from the gpuoptions array
    end
    
    properties (Dependent, SetAccess = private)
        gpuoptions              %Array of GPU options as strings
        gpudevice               %The index of the GPU device to be used 
        selectedgpustring       %The string name of the selected GPU

    end
    
    properties (Access = private)
        internalgpuoptionindex = 0
        internalincludecpus = false
    end
    
    methods
        function obj = MetalConfig
            %MetalConfig Constructor for the MetalConfig class.
            % The constructor should not be called
            % directly. Call the Metal.Config static method
            % instead to retrieve the system reference.
            obj.resetdefault;
        end
        
        
        function value = get.gpuoptions(~)
            %GET.GPUOPTIONS Get method for the gpuoptions parameter
            
            persistent gpuoption_chararray
            
            if isempty( gpuoption_chararray )
                gpuoption_chararray = ' ';
                coder.varsize('gpuoption_chararray', [Inf, Inf]);
                
                devinfo = Metal.GetDeviceInfoArray;
                optimaldevices = MetalConfig.OptimalDevices;
                
                for i=1:numel(optimaldevices)
                    index = double( optimaldevices(i) );
                    headlessString = '';
                    if devinfo( index ).IsHeadless
                        headlessString = ' (Headless)';
                    end
                    infostring = ['Metal Device ', int2str(int32(index-1)), ': ' char(devinfo(index).name), ' with ', num2str(double(devinfo(index).recommendedMaxWorkingSetSize) / (1024*1024*1024), '%0.3g'), ' GB', headlessString];
                    if numel(gpuoption_chararray) == 1
                        gpuoption_chararray = infostring;
                    else
                        gpuoption_chararray = char(gpuoption_chararray, infostring);
                    end
                end
                
                if isempty(optimaldevices) 
                    gpuoption_chararray = '';
                end
                
            end
            
            value = gpuoption_chararray;
            
        end
        
        function value = get.gpudevice(obj)
            %GET.GPUDEVICE Get method for gpudevice

            optimaldevices = MetalConfig.OptimalDevices;
            if ~isempty(optimaldevices)
                value = optimaldevices(bound(obj.gpuoptionindex, 1, end));
            else
                value = 1;
            end
        end
        
        function set.gpuoptionindex(obj, value)
            %SET.GPUOPTIONINDEX Make sure the value is bounded
            optimaldevices = MetalConfig.OptimalDevices;
            obj.internalgpuoptionindex = bound(round(value), 1, numel(optimaldevices)+1);
        end
        
        function value = get.gpuoptionindex(obj)
            value = obj.internalgpuoptionindex;
        end
        
        function value = get.selectedgpustring(obj)
            %GET.SELECTEDGPUSTRING Returns the selected GPU string
            gpustrings = obj.gpuoptions;
            value = deblank(gpustrings(obj.gpuoptionindex, :));
        end
         
        
        function resetdefault(obj)
            %RESETDEFAULT Resets to the default GPU
            obj.gpuoptionindex = 1;           
        end
        
    end


    
    methods ( Static, Access = private )
        function devids = OptimalDevices( varargin )
            %OPTIMALDEVICES Get the optimal GPU Devices for a system
            %  Returns the deviceid of the optimal GPU (if any) for processing.  The
            %  devices are returned in order of their preference.  If no suitable GPU
            %  is found, the devid array is empty.
            %
            %  Example:
            %     devids = OpenCLConfig.OptimalDevices;
            persistent Intdevids

            if isempty( Intdevids )
                devinfo = Metal.GetDeviceInfoArray;
                IsHeadless = [devinfo.IsHeadless];
                IsLowPower = [devinfo.IsLowPower];
                PerformanceLevel = double(IsHeadless) + double(~IsLowPower);
                [~,Intdevids] = sort( PerformanceLevel, 'descend' );
            end

            devids = Intdevids;


        end
        
        
    end
    
    
end