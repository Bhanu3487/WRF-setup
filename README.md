# WRF-setup

# Setting Up WRF (Weather Research and Forecasting Model)

This repository provides two simple methods to set up WRF and WPS.
1. **Using Docker (Recommended)**
2. **By Running a Script (Manual Setup)**
   
The options for compiling WRF and WPS are configured as recommended in the [WRF Compilation Tutorial](https://www2.mmm.ucar.edu/wrf/OnLineTutorial/compilation_tutorial.php).

### WRF and WPS Compilation Options
- **WRF**: 34 (dmpar) followed by 1 (default)
- **WRF Compilation Case**: `em_real`
- **WPS**: 1 (serial and grib2)
  
A sample simulation script is also provided, along with tests. The sample simulation is from [ARW Online Tutorial](https://www2.mmm.ucar.edu/wrf/OnLineTutorial/CASES/SingleDomain/index.php), except the end date is changed from  2016-10-08_00 to  2016-10-06_06 (namelist is set accordingly). Currenly, both methods are compatible with **gcc:9.4.0**, the setup options can be extended to later versions of gcc in the future. 

---
## Method 1: Using Docker 
### Steps to Follow

1. **Pull the Image from Docker Registry**
   ```bash
   docker pull bhanu348/wrf_image:gcc9
   ```
   This command will download the wrf_image tagged with gcc9 from the Docker registry specified at [Docker Hub](https://hub.docker.com/repository/docker/bhanu348/wrf_image/general).

2. **Run the Container**
   ```bash
   docker run -it bhanu348/wrf_image:gcc9 /bin/bash
   ```
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

## Verify WRF and WPS installations
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
## Run Simulation

1. **Using Docker**  
   If using Docker, the `scripts` folder is already present. Proceed to step 3.

2. **Without Docker**  
   If not using Docker, download the `scripts` folder to the same directory level as `WRF` and `WPS`.

3. **Navigate to the `scripts` directory**  
   ```bash
   cd scripts
   ./run_sim.sh
This script alone takes around 1 hour.

The script will execute the necessary WRF and WPS programs in the following order: ungrib, geogrid, metgrid, real (inside wrf.sh), and wrf. It will also ensure the correct environment variables are set and that the required terrestrial data is downloaded (~28 GB). 
---

