#!/bin/bash

# Directory where files are being managed
cd ../DATA/Man_Static_hres || { echo "Failed to change to directory 'Man_Static_hres'. Exiting."; exit 1; }

# Function to download and extract a file
download_and_extract() {
    local url=$1
    local filename=$(basename "$url") # Extract the file name from the URL

    # Check if the file already exists
    if [[ -f "${filename%.tar.bz2}" ]]; then
        echo "File ${filename%.tar.bz2} already exists. Skipping extraction."
        return 0
    fi

    # Check if the compressed file exists
    if [[ ! -f "$filename" ]]; then
        echo "Downloading $filename..."
        wget "$url" || { echo "Failed to download $filename. Exiting."; exit 1; }
    fi

    # Extract the file
    echo "Extracting $filename..."
    tar -xjf "$filename" || { echo "Failed to extract $filename. Exiting."; exit 1; }
    echo "$filename extracted successfully."
}

# URLs for the files
files=(
    "https://www2.mmm.ucar.edu/wrf/src/wps_files/albedo_modis.tar.bz2"
    "https://www2.mmm.ucar.edu/wrf/src/wps_files/greenfrac_fpar_modis.tar.bz2"
    "https://www2.mmm.ucar.edu/wrf/src/wps_files/lai_modis_10m.tar.bz2"
    "https://www2.mmm.ucar.edu/wrf/src/wps_files/lai_modis_30s.tar.bz2"
    "https://www2.mmm.ucar.edu/wrf/src/wps_files/maxsnowalb_modis.tar.bz2"
    "https://www2.mmm.ucar.edu/wrf/src/wps_files/modis_landuse_20class_30s_with_lakes.tar.bz2"
    "https://www2.mmm.ucar.edu/wrf/src/wps_files/orogwd_2deg.tar.bz2"
    "https://www2.mmm.ucar.edu/wrf/src/wps_files/orogwd_1deg.tar.bz2"
    "https://www2.mmm.ucar.edu/wrf/src/wps_files/orogwd_30m.tar.bz2"
    "https://www2.mmm.ucar.edu/wrf/src/wps_files/orogwd_20m.tar.bz2"
    "https://www2.mmm.ucar.edu/wrf/src/wps_files/orogwd_10m.tar.bz2"
    "https://www2.mmm.ucar.edu/wrf/src/wps_files/soiltemp_1deg.tar.bz2"
    "https://www2.mmm.ucar.edu/wrf/src/wps_files/soiltype_bot_30s.tar.bz2"
    "https://www2.mmm.ucar.edu/wrf/src/wps_files/soiltype_top_30s.tar.bz2"
    "https://www2.mmm.ucar.edu/wrf/src/wps_files/topo_gmted2010_30s.tar.bz2"
    "https://www2.mmm.ucar.edu/wrf/src/wps_files/varsso.tar.bz2"
    "https://www2.mmm.ucar.edu/wrf/src/wps_files/varsso_10m.tar.bz2"
    "https://www2.mmm.ucar.edu/wrf/src/wps_files/varsso_5m.tar.bz2"
    "https://www2.mmm.ucar.edu/wrf/src/wps_files/varsso_2m.tar.bz2"
)

# Loop through the files and process them
for file_url in "${files[@]}"; do
    download_and_extract "$file_url"
done

echo "All Static Data files processed successfully."
