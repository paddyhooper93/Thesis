#!/bin/bash

script_dir="/mnt/c/Users/rosly/Documents/Valerie_PH"
cd "$script_dir" || exit
echo "Running ./Generate_ROIs_7T.sh"

prefix="7T_Neutral"
QSM_dir="./Analysis/FermiFilt"
BET_dir="./Data/Padded/FermiFilt_SDC"
output_dir="./ROIs"
tmp_dir="./ROIs/tmp"

if [ ! -d "$tmp_dir" ]; then
    echo "Directory $tmp_dir does not exist. Creating it now..."
    mkdir -p "$tmp_dir"
    echo "Directory $tmp_dir created."
fi

case "$prefix" in
3T_Neutral)
    BET_erode_radius="10"
    CSF_erode_radius="3"
    CSF_open_radius="3"
    #    minextent_straws="300"
    #    minextent_ellipsoids="3000"
    res="1"
    ;;
7T_Neutral)
    BET_erode_radius="13"
    CSF_erode_radius="4"
    CSF_open_radius="4"
    #    minextent_straws="300"
    #    minextent_ellipsoids="10000"
    res="0.75"
    ;;
*)
    echo "$prefix does not match pattern"
    exit 1
    ;;
esac

CSF_Mask="$QSM_dir/${prefix}_CSF_Mask.nii.gz"
CSF_Mask_Inv="$tmp_dir/${prefix}_CSF_Mask_Inv.nii.gz"
# (1) CSF Mask inversion
fslmaths "$CSF_Mask" -binv "$CSF_Mask_Inv"

# (2) Mask from Step (1) is then multiplied by the QSM Mask
QSM_Mask="$QSM_dir/${prefix}_Mask_Use.nii.gz"
CSF_Mask_Inv_Mul="$tmp_dir/${prefix}_CSF_Mask_Inv_Mul.nii.gz"
fslmaths $QSM_Mask -mul $CSF_Mask_Inv "$CSF_Mask_Inv_Mul"

# (3) Mask from Step (1) is then eroded
# Change for 7 T: Mask erosion changed from 2 to 4
CSF_Mask_Inv_Mul_Erode="$tmp_dir/${prefix}_CSF_Mask_Inv_Mul_Erode.nii.gz"
ImageMath 3 "$CSF_Mask_Inv_Mul_Erode" ME "$CSF_Mask_Inv_Mul" 4

CSF_Mask_Inv_Mul_Erode_Open="$tmp_dir/${prefix}_CSF_Mask_Inv_Mul_Erode_Open.nii.gz"
# (4) Mask in Step (3) was then opened
# Change for 7 T: Mask opening changed from 1 to 2
ImageMath 3 "$CSF_Mask_Inv_Mul_Erode_Open" MO "$CSF_Mask_Inv_Mul_Erode" 2

BET_Mask="$BET_dir/${prefix}_mask.nii.gz"
BET_Mask_Erode="$tmp_dir/${prefix}_BET_Mask_Erode.nii.gz"
# (5) BET mask is eroded
# Change for 7 T: Mask erosion changed from 10 to 15
ImageMath 3 "$BET_Mask_Erode" ME "$BET_Mask" 15
CSF_Mask_Inv_Mul_Erode_Open_BET_Erode="$tmp_dir/${prefix}_CSF_Mask_Inv_Mul_Erode_Open_BET_Erode.nii.gz"
# (6) Mask from Step (4) is multiplied by Mask from Step (5)
fslmaths "$BET_Mask_Erode" -mul "$CSF_Mask_Inv_Mul_Erode_Open" "$CSF_Mask_Inv_Mul_Erode_Open_BET_Erode"

seg="$tmp_dir/${prefix}_seg.nii.gz"
# (7) Mask at Step (6) is then used as input into FMRIB's cluster
# Change for 7 T: Min extent changed from 300 to 1700
cluster -i "$CSF_Mask_Inv_Mul_Erode_Open_BET_Erode" -t 0.5 -o "$seg" --connectivity=6 --minextent=1700

ROIs="$output_dir/${prefix}_ROIs.nii.gz"
ImageMath 3 "$ROIs" ReplaceVoxelValue "$seg" 6.5 Inf 0

exit 0
