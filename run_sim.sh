#!/bin/bash

# ungrib: Unpack input GRIB data
cd ..
mkdir -p DATA

if [ ! -d "DATA/matthew" ]; then
    if [ ! -f "DATA/matthew_1deg.tar.gz" ]; then
        wget https://www2.mmm.ucar.edu/wrf/TUTORIAL_DATA/matthew_1deg.tar.gz -P DATA/ || exit 1
    fi
    tar -xf DATA/matthew_1deg.tar.gz -C DATA/ || exit 1
fi

cd WPS
# ./util/g2print.exe ../DATA/matthew/fnl_20161006_00_00.grib2 >& g2print.log

ln -sf ungrib/Variable_Tables/Vtable.GFS Vtable
./link_grib.csh ../DATA/matthew/fnl

./ungrib.exe || exit 1
echo "USER_LOG: ungrib execution successfully"

# geogrid: Setup the Model domain

# ncl util/plotgrids.ncl
./geogrid.exe || exit 1
echo "USER_LOG: Geogrid execution successfully"

# Metgrid: Interpolate the input data onto our model domain

./metgrid.exe || exit 1
echo "USER_LOG: Metgrid execution successfully"

# Real and WRF: Run the model
cd ../WRF/test/em_real

ln -sf ../../../WPS/met_em.d01.2016-10* .

./real.exe || exit 1

./wrf.exe || exit 1
