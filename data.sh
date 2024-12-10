#!/bin/bash

# Directory where files are being managed
# cd Man_Static_hres || { echo "Failed to change to directory 'Man_Static_hres'. Exiting."; exit 1; }
cd ../DATA/
mkdir -p Man_Static_hres && cd Man_Static_hres || { echo "Failed to create or change to directory 'Man_Static_hres'. Exiting."; exit 1; }

# Function to download and verify file size
download_and_verify() {
    local url=$1
    local filename=$(basename "$url")

    # Check if the file already exists
    if [[ -f "$filename" ]]; then
        echo "File $filename exists. Verifying size..."
        local remote_size=$(curl -sI "$url" | awk '/Content-Length/ {print $2}' | tr -d '\r')
        local local_size=$(stat -c%s "$filename")

        if [[ "$local_size" -eq "$remote_size" ]]; then
            echo "File $filename is complete."
        else
            echo "File $filename is incomplete or corrupted. Re-downloading..."
            rm -f "$filename"
            wget "$url" || { echo "Failed to download $filename. Exiting."; exit 1; }
        fi
    else
        # Download the file if it doesn't exist
        echo "Downloading $filename..."
        wget "$url" || { echo "Failed to download $filename. Exiting."; exit 1; }
    fi
}

# Function to extract a file
extract_file() {
    local filename=$1

    # Check if the extracted directory already exists
    if [[ -d "${filename%.tar.bz2}" ]]; then
        echo "Directory ${filename%.tar.bz2} already exists. Skipping extraction."
        return 0
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
    download_and_verify "$file_url"
    extract_file "$(basename "$file_url")"
done

echo "All Static Data files processed successfully."
