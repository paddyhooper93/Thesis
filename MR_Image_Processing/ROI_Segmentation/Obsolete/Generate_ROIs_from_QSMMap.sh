#!/bin/bash

script_dir="/mnt/c/Users/rosly/Documents/Valerie_PH"
cd "$script_dir" || exit
echo "Running ./Generate_ROIs_7T.sh"

prefix="7T_Neutral"
QSM_dir="./Analysis/Registered/Neutral/NLFit"
#BET_dir="./Data/Padded/FermiFilt_SDC"
#output_dir="./ROIs"
tmp_dir="./ROIs/tmp"

if [ ! -d "$tmp_dir" ]; then
    echo "Directory $tmp_dir does not exist. Creating it now..."
    mkdir -p "$tmp_dir"
    echo "Directory $tmp_dir created."
fi

case "$prefix" in
3T_Neutral)
    #BET_erode_radius="10"
    #CSF_erode_radius="3"
    #CSF_open_radius="3"
    #    minextent_straws="300"
    #    minextent_ellipsoids="3000"
    res="1"
    ;;
7T_Neutral)
    #BET_erode_radius="13"
    #CSF_erode_radius="4"
    #CSF_open_radius="4"
    #    minextent_straws="300"
    #    minextent_ellipsoids="10000"
    res="0.75"
    ;;
*)
    echo "$prefix does not match pattern"
    exit 1
    ;;
esac

img="${QSM_dir}/${prefix}_QSM_FLIRT.nii.gz"

seg="$tmp_dir/${prefix}_seg.nii.gz"
# (7) Mask at Step (6) is then used as input into FMRIB's cluster
# Change for 7 T: Min extent changed from 300 to 1700
cluster -i "$img" -t 5 --fractional -o "$seg" --connectivity=6 --minextent=300 --mm -r $res

#ROIs="$output_dir/${prefix}_ROIs.nii.gz"
#ImageMath 3 "$ROIs" ReplaceVoxelValue "$seg" 6.5 Inf 0

exit 0
