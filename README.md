# MATLABMetal
Apple Metal GPU processing toolbox for MATLAB on macOS.

Matlab runs extremely well on the new Apple Silicon Macs, but if you want the best possible performance from these new processors, the real number-crunching power is on their onboard GPU cores. This toolbox allows easy and direct access to the macOS Metal API right from the MATLAB command window. It works on Intel and Apple Silicon Macs, and allows you to choose which GPU to use (if there are multiple). It wraps up the Apple Objective C API into prebuilt MEX files, and then further wraps the Metal API class structure into native MATLAB classes to handle all the lifecycle details. 

Writing code for Metal is really pretty straightforward. On the GPU, functions are written in a C++ style language, and then data is handed in to the GPU, processed, and returned. On Apple Silicon devices, that round trip is lightning-fast since the GPU and CPU memory is shared. 

This library wraps up single prcision floats and 16 bit integers. All it requires is normal MATLAB (on a Intel or Apple Sillicon Mac), and the MEX files for Intel and Apple Silicon are pre-built. These are built using MATLAB Coder, which isn't required to use this toolbox, but if you have MATLAB Coder you can modify and rebuild the MEX files. 

I've provided some examples of how to use the library, which also give a quick primer on how to write for Metal. 

# Setup and Testing the Installation
Setup is straightforward: simply make sure the directory is on your MATLAB path.

Once you have the path set, run the test classes to make sure everything is operational. To do this, run:

    runtests('testMetal')
    runtests('testMetalClasses')

Both test suites should run with no errors. If they do, you're good to go.

# Examples
Open `MatlabMetalDemoScript.m` in the MATLAB editor to see how to use the toolbox. This is a cell-mode script, so you can click on each section and click "Run Section" in the editor to execute each step. It will walk you through how to set up data buffers and processing functions. 

# Extra Information for MATLAB Coder Use

## Building the MEX
As mentioned above, the precompiled MEX files are provided in this repository, so there's usually no need to rebuild. But if you want to add functionality to the MEX files and you have a license for MATLAB Coder, you can easily rebuild the MEX files by running `buildMexFile.m`. This will build the MEX file for your architecture. Following that function set will show the underlying Objective C code, which is built in Xcode. 

## Building the Library for Coder
This library has been designed to work with MATLAB Coder to deploy fully-compiled applications on macOS. All the classes and function calls are fully Coder complient, and the support library (`libMatlabMetal.a`) can be built using `APIBuilder.BuildLibrary( Metal )`, which will build the library file with all the API calls, and anything built with Coder can link to this library file. 

# Contributing
If you have features or extensions you'd like to see, or have made improvements to this library, please submit issues or pull requests. I'd love to make this toolbox more useful. 

[![View MATLABMetal on File Exchange](https://www.mathworks.com/matlabcentral/images/matlab-file-exchange.svg)](https://www.mathworks.com/matlabcentral/fileexchange/135912-matlabmetal)

Enjoy!
