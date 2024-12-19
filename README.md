# WRF-Setup

## Setting Up WRF (Weather Research and Forecasting Model)

This repository provides two simple methods to set up WRF and WPS:
1. **Using Docker (Recommended)**
2. **By Running a Script (Manual Setup)**

It also helps in running and testing a sample simulation.

The options for compiling WRF and WPS are configured as recommended in the [WRF Compilation Tutorial](https://www2.mmm.ucar.edu/wrf/OnLineTutorial/compilation_tutorial.php). The sample simulation follows the [Online Tutorial](https://www2.mmm.ucar.edu/wrf/OnLineTutorial/CASES/SingleDomain/index.php), with the end date modified from `2016-10-08_00` to `2016-10-06_03` (namelist adjusted accordingly). Currently, both methods are compatible with **gcc:9.4.0**, and the setup options can be extended to later versions of GCC in the future.

### WRF and WPS Compilation Options
- **WRF**: 34 (dmpar) followed by 1 (default)
- **WRF Compilation Case**: `em_real`
- **WPS**: 1 (serial and grib2)

---
## Method 1: Using Docker
### Steps to Follow
1. **Set Up Rootless Docker**
   Follow the "Set Up Rootless Docker" section in this [Docker Cheatsheet](https://patel-zeel.github.io/blog/posts/docker_cheatsheet.html).

2. **Pull the Image from Docker Registry**
   ```bash
   docker pull bhanu348/wrf_sim:dmpar
   ```
   This command downloads the Docker image tagged with `dmpar` from the [Docker Hub](https://hub.docker.com/repository/docker/bhanu348/wrf_image/general).

3. **Run the Container**
   ```bash
   docker run -it bhanu348/wrf_sim:dmpar /bin/bash
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

## Verifying WRF and WPS Installations

### WRF Verification
```bash
cd wrf/WRF
ls -ls main/*.exe
```
You should see the following executables:
- `wrf.exe` (model executable)
- `real.exe` (real data initialization)
- `ndown.exe` (one-way nesting)
- `tc.exe` (for TC bogusing - serial only)

### WPS Verification
```bash
cd ../WPS
ls -ls geogrid/src/geogrid.exe
ls -ls metgrid/src/metgrid.exe
ls -ls ungrib/src/ungrib.exe
```
Ensure that the executable files are not zero-sized.

---

## Running a Simulation

In the Docker image, all the required files are organized into proper directories. If installing WRF and WPS using the `wrf_setup.sh` script, download all necessary files into the following directories:

```
WRF/
├── Build_WRF/
│   └── LIBRARIES/
├── TESTS/
│   └── system_environment_and_variables_test/
├── DATA/
│   └── Man_Static_hres/  # Contains static data referred in namelist.wps
├── WRF/
│   └── test/
│       └── em_real/
│           ├── main.exe
│           ├── real.exe
│           └── namelist.input
├── WPS/
│   ├── ungrib.exe
│   ├── geogrid.exe
│   ├── metgrid.exe
│   └── namelist.wps
└── SCRIPTS/
    ├── data.sh
    ├── env_var.sh
    ├── run_sim.sh
    └── test_sim.sh
```

### Steps to Run a Simulation

1. **Set Up Environment Variables**
   Run `env_var.sh` to set the necessary paths and source them to `.bashrc`.
   ```bash
   cd scripts
   ./env_var.sh
   ```

2. **Download Terrestrial Data**
   Run `data.sh` to download the required terrestrial data files (~28 GB, ~3 hours to download).
   ```bash
   ./data.sh
   ```
   This step is required only once in your environment.

3. **Run the Simulation**
   Run the simulation using `run_sim.sh`. This script takes around 40 minutes.
   ```bash
   ./run_sim.sh
   ```

4. **Verify the Simulation**
   Check for the generated output file `wrfout_d01_2016-10-06_00:00:00` and verify it.
   ```bash
   ./test_sim.sh
   ```

This script executes the necessary WRF and WPS programs in the following order: `ungrib`, `geogrid`, `metgrid`, `real`, and `wrf`. It also ensures the correct environment variables are set and that the required terrestrial data is downloaded.

---

## Acknowledgments
I sincerely thank Prof. Nipun Batra for his invaluable guidance, Zeel Patel for his dedicated support, and Jigisha for her crucial help with installations, all instrumental to this project's success.

