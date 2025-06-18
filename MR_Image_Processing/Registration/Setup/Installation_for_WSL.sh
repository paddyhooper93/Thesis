
## DONE
FSLDIR=/usr/local/fsl
. ${FSLDIR}/etc/fslconf/fsl.sh
PATH=${FSLDIR}/bin:${PATH}
export FSLDIR PATH
echo $FSLDIR
flirt -version
sudo apt update
sudo apt install -y git
git --version
sudo apt install -y cmake
cmake --version
workingDir=${/opt/ants}
sudo mkdir /opt/ants
git clone https://github.com/ANTsX/ANTs.git
mkdir build install

## RUNNING
cd build
cmake \
    -DCMAKE_INSTALL_PREFIX=${workingDir}/install \
    -DBUILD_TESTING=OFF \
    -DRUN_LONG_TESTS=OFF \
    -DRUN_SHORT_TESTS=OFF \
    ../ANTs 2>&1 | tee cmake.log
make -j 4 2>&1 | tee build.log

## NEXT
cd ANTS-build
make install 2>&1 | tee install.log
export PATH=/opt/ants:$PATH
which antsRegistration

## AFTER
# Verify current glibc version
ldd --version

wget -O mirtk https://bintray.com/schuhschuh/AppImages/download_file?file_path=MIRTK%2Bview-latest-x86_64-glibc2.15.AppImage
chmod a+x mirtk
sudo mv mirtk /usr/bin


cmake /opt/MIRTK/MIRTK/
make -j 8

## DONE??
#dir=${/opt/c3d}
#sudo mkdir "${dir}"
#cp ~/Downloads/c3d_1.0.0 "${dir}" -r
#export PATH=/opt/c3d:$PATH
#c3d --help

# Download ITK to use c3d
#git clone git://itk.org/ITK.git
#mkdir ITK-build
#cd ITK-build
#ccmake ../ITK
