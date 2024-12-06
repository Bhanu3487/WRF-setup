#!/bin/bash

# Add the library paths to .bashrc
export LD_LIBRARY_PATH=/wrf/Build_WRF/LIBRARIES/grib2/lib:/wrf/Build_WRF/LIBRARIES/grib2/bin:/wrf/Build_WRF/LIBRARIES/netcdf/lib:/wrf/Build_WRF/LIBRARIES/mpich/lib:$LD_LIBRARY_PATH
export C_INCLUDE_PATH=/wrf/Build_WRF/LIBRARIES/grib2/include:/wrf/Build_WRF/LIBRARIES/netcdf/include:/wrf/Build_WRF/LIBRARIES/mpich/include:$C_INCLUDE_PATH
export PATH=/wrf/Build_WRF/LIBRARIES/grib2/bin:/wrf/Build_WRF/LIBRARIES/mpich/bin:/wrf/Build_WRF/LIBRARIES/netcdf/bin:$PATH

# Apply the changes
source ~/.bashrc

echo "Environment variables added and .bashrc sourced."

