#!/bin/bash
# Function to do complex smoothing on datasets
# Usage: Complex_smoothing.sh prefix sub

prefix="$1"
sub="$2"

script_dir="/mnt/c/Users/rosly/Documents/Valerie_PH"
cd "$script_dir" || exit

echo "Running Complex_smoothing.sh"
# Define directories
degibbs_dir="./Data/degibbs"
cplx_smth_dir="./Data/Cplx_smth"

if [ ! -d "$cplx_smth_dir" ]; then
    echo "Directory $cplx_smth_dir does not exist. Creating it now..."
    mkdir -p "$cplx_smth_dir"
    echo "Directory $cplx_smth_dir created."
fi

degibbs_img="${degibbs_dir}/${prefix}_${sub}_Cplx_DeGibbs.nii.gz"
cplx_smth_img="${cplx_smth_dir}/${prefix}_${sub}_Cplx_Smth.nii.gz"
magn_smth_img="${cplx_smth_dir}/${prefix}_${sub}_Magn_Smth.nii.gz"
phs_smth_img="${cplx_smth_dir}/${prefix}_${sub}_Phs_Smth.nii.gz"

# sigma = FWHM./(2*sqrt(2*log(2))) ;
# If FWHM = 1 mm, then sigma = 0.4247 mm
sigma="0.4247"
gauss3D_filter_cmd="fslmaths $degibbs_img -s $sigma $cplx_smth_img" # <sigma> : create a gauss kernel of sigma mm and perform mean filtering
./check_command.sh "$gauss3D_filter_cmd"

fslcmd_1="fslcomplex -realabs $cplx_smth_img $magn_smth_img"
./check_command.sh "$fslcmd_1"
fslcmd_2="fslcomplex -realphase $cplx_smth_img $phs_smth_img"
./check_command.sh "$fslcmd_2"
