# WRF-setup

# Setting Up WRF (Weather Research and Forecasting Model)

This repository provides two simple methods to set up WRF and WPS using **gcc:9.4.0**. The setup options can be extended to later versions of gcc in the future.

## Methods Overview

1. **Using Docker (Recommended)**
2. **By Running a Script (Manual Setup)**

---

## Method 1: Using Docker (Recommended)

The options for compiling WRF and WPS are configured as recommended in the [WRF Compilation Tutorial](https://www2.mmm.ucar.edu/wrf/OnLineTutorial/compilation_tutorial.php).

### WRF and WPS Compilation Options
- **WRF**: 34 (dmpar) followed by 1 (default)
- **WRF Compilation Case**: `em_real`
- **WPS**: 1 (serial and grib2)

### Steps to Follow

1. **Pull the Image from Docker Registry**
   ```bash
   docker pull bhanu348/wrf_image:gcc9
   ```
   This command will download the wrf_image tagged with gcc9 from the Docker registry specified at [Docker Hub](https://hub.docker.com/repository/docker/bhanu348/wrf_image/general).

2. **Run the Container**
   ```bash
   docker run -it bhanu348/wrf_image:gcc9
   ```

3. **Verify WRF and WPS Installations**

   - **WRF Verification**
     ```bash
     cd wrf/WRF
     ls -ls main/*.exe
     ```
     You should see:
     - `wrf.exe` (model executable)
     - `real.exe` (real data initialization)
     - `ndown.exe` (one-way nesting)
     - `tc.exe` (for TC bogusing - serial only)

   - **WPS Verification**
     ```bash
     cd ../WPS
     ls -ls geogrid/src/geogrid.exe
     ls -ls metgrid/src/metgrid.exe
     ls -ls ungrib/src/ungrib.exe
     ```
     The above steps will confirm that the executable files are not zero-sized.

---

## Method 2: By Running a Script

This method provides more flexibility to choose suitable options for WRF and WPS installation.

### Steps to Follow

1. **Download the Script**
   - Download the `wrf_setup` script provided in this repository and move it to the directory where you want to install WRF and WPS.

2. **Install Nano (if necessary)**
   ```bash
   sudo apt-get update
   sudo apt-get install -y nano
   ```

3. **Review or Modify the Script**
   ```bash
   nano setup.sh
   ```

4. **Make the Script Executable**
   ```bash
   chmod +x setup.sh
   ```

5. **Run the Script**
   ```bash
   ./setup.sh
   ```

---


