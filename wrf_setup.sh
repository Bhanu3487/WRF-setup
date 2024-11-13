#!/bin/bash

# Log file setup
LOGFILE="/wrf/wrf_logs/logfile_ins.txt"
mkdir -p "$(dirname "$LOGFILE")"
exec > >(tee -a "$LOGFILE") 2>&1

install_missing_command() {
    cmd=$1
    if ! command -v "$cmd" &> /dev/null; then
        echo "USER LOG: $cmd is not available. Installing..."
        if ! apt update && apt install -y "$cmd"; then
            echo "USER LOG: Failed to install $cmd"
        fi
    fi
}

if ! command -v git &> /dev/null; then
    echo "USER LOG: Installing git..."
    apt-get install -y git || { echo "USER LOG: Installation failed."; exit 1; }
    echo "USER LOG: Git installation completed."
fi


# Compiling WRF
# A. System Environment Tests
# 1. check if gfortran compiler, gcc and cpp exist
echo "USER LOG: Location of gfortran, cpp, gcc:"
which gfortran
which cpp
which gcc

if ! command -v gfortran &> /dev/null; then
    echo "USER LOG: gfortran not found. Installing gfortran..."
    apt update
    apt install -y gfortran
fi
gfortran --version
gcc --version

# 2. create new directories
mkdir -p /wrf/Build_WRF
mkdir -p /wrf/TESTS

# 3. Tests to check fortran compiler and its compatibility with C compiler
if [ ! -f /wrf/TESTS/Fortran_C_tests.tar ]; then
    wget -P /wrf/TESTS https://www2.mmm.ucar.edu/wrf/OnLineTutorial/compile_tutorial/tar_files/Fortran_C_tests.tar
fi

cd /wrf/TESTS || { echo "USER LOG: Failed to change directory to /wrf/TESTS"; exit 1; }

if [ ! -d Fortran_C_tests ]; then
    tar -xf Fortran_C_tests.tar
fi

tests=(
    "Fixed Format Fortran Test:TEST_1_fortran_only_fixed.f:gfortran"
    "Free Format Fortran Test:TEST_2_fortran_only_free.f90:gfortran"
    "C Test:TEST_3_c_only.c:gcc"
)

for test in "${tests[@]}"; do
    IFS=":" read -r test_name file compiler <<< "$test"
    echo "USER LOG: Running $test_name"

    $compiler "$file"
    if [ $? -eq 0 ]; then
        ./a.out
    else
        echo "USER LOG: Compilation failed for $test_name."
    fi
done

echo "USER LOG: Running Test #4: Fortran Calling a C Function"
gcc -c -m64 TEST_4_fortran+c_c.c
if [ $? -eq 0 ]; then
    gfortran -c -m64 TEST_4_fortran+c_f.f90
    if [ $? -eq 0 ]; then
        gfortran -m64 TEST_4_fortran+c_f.o TEST_4_fortran+c_c.o
        if [ $? -eq 0 ]; then
            ./a.out
        else
            echo "USER LOG: Linking failed for Test #4."
        fi
    else
        echo "USER LOG: Compilation of Fortran file failed for Test #4."
    fi
else
    echo "USER LOG: Compilation of C file failed for Test #4."
fi

# 4. Tests to check scripting languages
tests=(
    "TEST_csh.csh:SUCCESS csh test:csh"
    "TEST_perl.pl:SUCCESS perl test:perl"
    "TEST_sh.sh:SUCCESS sh test:sh"
)

for test in "${tests[@]}"; do
    IFS=':' read -r test_file expected_output test_name <<< "$test"
    output=$(./"$test_file")
    if [[ "$output" == "$expected_output" ]]; then
        echo "USER LOG: SUCCESS: $test_name test"
    else
        echo "USER LOG: FAILURE: $test_name test. Expected: '$expected_output', but got: '$output'"
    fi
done

# 5 .Verify mandatory UNIX commands
MANDATORY_COMMANDS=(
    ar head sed awk hostname sleep cat ln sort
    cd ls tar cp make touch cut mkdir tr expr mv uname
    file nm wc grep printf which gzip rm m4 gfortran
)

for cmd in "${MANDATORY_COMMANDS[@]}"; do
    install_missing_command "$cmd"
done


# B.Building Libraries
#mkdir -p /wrf/Build_WRF
cd /wrf/Build_WRF || { echo "Failed to change directory to /wrf/Build_WRF"; exit 1; }
mkdir -p LIBRARIES

LIBRARIES_DIR="/wrf/Build_WRF/LIBRARIES"
cd "$LIBRARIES_DIR" || { echo "Failed to change directory to $LIBRARIES_DIR"; exit 1; }

declare -A LIBRARIES=(
    ["netcdf-c-4.7.2.tar.gz"]="https://www2.mmm.ucar.edu/wrf/OnLineTutorial/compile_tutorial/tar_files/netcdf-c-4.7.2.tar.gz"
    ["netcdf-fortran-4.5.2.tar.gz"]="https://www2.mmm.ucar.edu/wrf/OnLineTutorial/compile_tutorial/tar_files/netcdf-fortran-4.5.2.tar.gz"
    ["mpich-3.0.4.tar.gz"]="https://www2.mmm.ucar.edu/wrf/OnLineTutorial/compile_tutorial/tar_files/mpich-3.0.4.tar.gz"
    ["jasper-1.900.1.tar.gz"]="https://www2.mmm.ucar.edu/wrf/OnLineTutorial/compile_tutorial/tar_files/jasper-1.900.1.tar.gz"
    ["libpng-1.2.50.tar.gz"]="https://www2.mmm.ucar.edu/wrf/OnLineTutorial/compile_tutorial/tar_files/libpng-1.2.50.tar.gz"
    ["zlib-1.2.11.tar.gz"]="https://www2.mmm.ucar.edu/wrf/OnLineTutorial/compile_tutorial/tar_files/zlib-1.2.11.tar.gz"
)

# Loop through the libraries
for LIBRARY in "${!LIBRARIES[@]}"; do
    if [ ! -f "$LIBRARY" ]; then
        echo "USER LOG: Downloading $LIBRARY..."
        wget "${LIBRARIES[$LIBRARY]}"
    fi
done

# set paths
export DIR="/wrf/Build_WRF/LIBRARIES"
export CC="gcc"
export CXX="g++"
export FC="gfortran"
export FCFLAGS="-m64"
export F77="gfortran"
export FFLAGS="-m64"
export JASPERLIB="$DIR/grib2/lib"
export JASPERINC="$DIR/grib2/include"
export LDFLAGS="-L$DIR/netcdf/lib"
export CPPFLAGS="-I$DIR/netcdf/include"

# 1. Netcdf, 2. MPICH, 3. zlib, 4. libpgn, 5.Jasper
libraries=(
    "NetCDF:netcdf-c-4.7.2.tar.gz:netcdf-c-4.7.2:$DIR/netcdf:include/netcdf.h"
    "NetCDF-Fortran:netcdf-fortran-4.5.2.tar.gz:netcdf-fortran-4.5.2:$DIR/netcdf:include/netcdf.inc"
    "MPICH:mpich-3.0.4.tar.gz:mpich-3.0.4:$DIR/mpich:bin/mpichversion"
    "Zlib:zlib-1.2.11.tar.gz:zlib-1.2.11:$DIR/grib2:lib/libz.a"
    "libpng:libpng-1.2.50.tar.gz:libpng-1.2.50:$DIR/grib2:lib/libpng.a"
    "Jasper:jasper-1.900.1.tar.gz:jasper-1.900.1:$DIR/grib2:lib/libjasper.a"
)

for lib in "${libraries[@]}"; do
    IFS=":" read -r name archive dir install_path check_file <<< "$lib"

    if [ -f "$install_path/$check_file" ]; then
        echo "USER LOG: $name is already installed."
        continue
    fi

    if [ -f "$archive" ]; then
        echo "USER LOG: Extracting $archive..."
        tar xzvf "$archive" || tar xvf "${archive%.gz}"
        if [ $? -ne 0 ]; then
            echo "USER LOG: Failed to extract $archive"
            exit 1
        fi
    else
        echo "USER LOG: $archive not found!"
        exit 1
    fi

    cd "$dir" || { echo "USER LOG: Failed to change directory to $dir"; exit 1; }

    # Configure, compile, and install based on the library name
    if [ "$name" == "NetCDF" ]; then
        ./configure --prefix="$install_path" --disable-dap --disable-netcdf-4 --disable-shared
        if [ $? -ne 0 ]; then echo "USER LOG: Configuration failed for $name"; exit 1; fi
        make
        if [ $? -ne 0 ]; then echo "USER LOG: Compilation failed for $name"; exit 1; fi
        make install
        if [ $? -ne 0 ]; then echo "USER LOG: Installation failed for $name"; exit 1; fi
        export PATH="$install_path/bin:$PATH"
        export NETCDF="$install_path"

    elif [ "$name" == "NetCDF-Fortran" ]; then
        export LIBS="-lnetcdf -lz"
        ./configure --prefix="$install_path" --disable-dap --disable-netcdf-4 --disable-shared
        if [ $? -ne 0 ]; then echo "USER LOG: Configuration failed for $name"; exit 1; fi
        make
        if [ $? -ne 0 ]; then echo "USER LOG: Compilation failed for $name"; exit 1; fi
        make install
        if [ $? -ne 0 ]; then echo "USER LOG: Installation failed for $name"; exit 1; fi
        export PATH="$install_path/bin:$PATH"
        export NETCDF="$install_path"

    elif [ "$name" == "MPICH" ]; then
        ./configure --prefix="$install_path"
        if [ $? -ne 0 ]; then echo "USER LOG: Configuration failed for $name"; exit 1; fi
        make
        if [ $? -ne 0 ]; then echo "USER LOG: Compilation failed for $name"; exit 1; fi
        make install
        if [ $? -ne 0 ]; then echo "USER LOG: Installation failed for $name"; exit 1; fi
        export PATH="$install_path/bin:$PATH"

    else
        ./configure --prefix="$install_path"
        if [ $? -ne 0 ]; then echo "USER LOG: Configuration failed for $name"; exit 1; fi
        make
        if [ $? -ne 0 ]; then echo "USER LOG: Compilation failed for $name"; exit 1; fi
        make install
        if [ $? -ne 0 ]; then echo "USER LOG: Installation failed for $name"; exit 1; fi
    fi

    cd .. || exit 1
done



# C. Library Compatibility Tests
NETCDF="${NETCDF:-/wrf/Build_WRF/LIBRARIES/netcdf}"

if [ ! -f /wrf/TESTS/Fortran_C_NETCDF_MPI_tests.tar ]; then
    wget -P /wrf/TESTS https://www2.mmm.ucar.edu/wrf/OnLineTutorial/compile_tutorial/tar_files/Fortran_C_NETCDF_MPI_tests.tar
fi

cd /wrf/TESTS || { echo "USER LOG: Failed to change directory to /wrf/TESTS"; exit 1; }

if [ ! -d Fortran_C_NETCDF_MPI_tests ]; then
    tar -xf Fortran_C_NETCDF_MPI_tests.tar
fi

# 1: Fortran + C + NetCDF
cp "${NETCDF}/include/netcdf.inc" .
echo "USER LOG: Running Test #1: Fortran + C + NetCDF"
gfortran -c 01_fortran+c+netcdf_f.f || { echo "USER LOG: Compilation failed for Fortran code"; exit 1; }
gcc -c 01_fortran+c+netcdf_c.c || { echo "USER LOG: Compilation failed for C code"; exit 1; }
gfortran 01_fortran+c+netcdf_f.o 01_fortran+c+netcdf_c.o -L"${NETCDF}/lib" -lnetcdff -lnetcdf || { echo "USER LOG: Linking failed"; exit 1; }
./a.out || { echo "USER LOG: Test execution failed"; exit 1; }

# 2: Fortran + C + NetCDF + MPI
cp "${NETCDF}/include/netcdf.inc" .
export PATH="/wrf/Build_WRF/LIBRARIES/mpich/bin:$PATH"
echo "USER LOG: Running Test #2: Fortran + C + NetCDF + MPI"

mpif90 -c 02_fortran+c+netcdf+mpi_f.f || { echo "USER LOG: Compilation failed for Fortran MPI code"; exit 1; }
mpicc -c 02_fortran+c+netcdf+mpi_c.c || { echo "USER LOG: Compilation failed for C MPI code"; exit 1; }
mpif90 02_fortran+c+netcdf+mpi_f.o 02_fortran+c+netcdf+mpi_c.o -L"${NETCDF}/lib" -lnetcdff -lnetcdf || { echo "USER LOG: Linking failed"; exit 1; }
mpirun ./a.out || { echo "USER LOG: Test execution failed"; exit 1; }
cd ..


# D. Building WRF
WRF_REPO_URL="https://github.com/wrf-model/WRF.git"
WPS_REPO_URL="https://github.com/wrf-model/WPS.git"
WRF_DIR="/wrf/WRF"
WPS_DIR="/wrf/WPS"
export NETCDF="$DIR/netcdf"

if [ -f "$WRF_DIR/main/wrf.exe" ] && [ -f "$WRF_DIR/main/real.exe" ] && [ -f "$WRF_DIR/main/ndown.exe" ] && [ -f "$WRF_DIR/main/tc.exe" ]; then
    echo "USER LOG: WRF is already compiled."
else
    if [ ! -d "$WRF_DIR" ]; then
        echo "USER LOG: Cloning WRF repository..."
        git clone --recurse-submodules "$WRF_REPO_URL" "$WRF_DIR" || { echo "USER LOG: Failed to clone the WRF repository."; exit 1; }
        echo "USER LOG: Successfully cloned the WRF repository."
    fi

    cd "$WRF_DIR" || { echo "USER LOG: Failed to change directory to $WRF_DIR"; exit 1; }

    echo "USER LOG: Running the configuration script for WRF..."
    if ! ./configure; then
        echo "USER LOG: Configuration failed. Re-cloning repository..."
        rm -rf "$WRF_DIR"
        git clone --recurse-submodules "$WRF_REPO_URL" "$WRF_DIR" || { echo "USER LOG: Failed to clone the WRF repository."; exit 1; }
        cd "$WRF_DIR" || { echo "USER LOG: Failed to change directory to $WRF_DIR"; exit 1; }
        ./configure || { echo "USER LOG: Configuration failed again."; exit 1; }
    fi

    # Set case name for WRF compilation
    case_name="em_real"

    # Compile WRF with the case name
    echo "USER LOG: Compiling WRF with case name $case_name..."
    ./compile "$case_name" || { echo "USER LOG: Compilation failed."; exit 1; }

    echo "USER LOG: WRF compilation completed successfully."
fi

# E. Building WPS
if [ ! -f "$WPS_DIR/geogrid/src/geogrid.exe" ]; then
    if [ ! -d "$WPS_DIR" ]; then
        echo "USER LOG: Cloning the WPS repository..."
        git clone "$WPS_REPO_URL" "$WPS_DIR" || { echo "USER LOG: Failed to clone the WPS repository."; exit 1; }
        echo "USER LOG: Successfully cloned the WPS repository."
    else
        echo "USER LOG: The WPS directory already exists, skipping clone."
    fi

    cd "$WPS_DIR" || { echo "USER LOG: Failed to change directory to $WPS_DIR"; exit 1; }
    ./clean || { echo "USER LOG: Cleaning WPS directory failed."; exit 1; }
    export JASPERLIB="$DIR/grib2/lib"
    export JASPERINC="$DIR/grib2/include"
    ./configure || { echo "USER LOG: WPS configuration failed."; exit 1; }
    ./compile || { echo "USER LOG: WPS compilation failed."; exit 1; }
else
    echo "USER LOG: WPS is already compiled."
fi


echo "USER LOG: SCRIPT END"


