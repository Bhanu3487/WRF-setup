#!/bin/bash

# Define file paths directly
file1="/wrf/Output_files/wrfout_d01_2016-10-06_00:00:00" #expected
file2="/wrf/WRF/test/em_real/wrfout_d01_2016-10-06_00:00:00" #simularion output

# Use ncdump to compare the two NetCDF files
ncdump -c "$file1" > file1.txt
ncdump -c "$file2" > file2.txt

# Compare the two output files
if diff -q file1.txt file2.txt > /dev/null; then
  echo "The NetCDF files are identical."
else
  echo "The NetCDF files are different."
fi


