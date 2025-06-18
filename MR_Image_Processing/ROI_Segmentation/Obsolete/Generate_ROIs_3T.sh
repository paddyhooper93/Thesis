#!/bin/bash

script_dir="/mnt/c/Users/rosly/Documents/Valerie_PH"
cd "$script_dir" || exit
echo "Running ./Generate_ROIs_3T.sh"

prefix="3T_Neutral"
QSM_dir="./Analysis/Registered/Brain_ROI_Mask"
BET_dir="./Data/Padded/SDC"
CSF_dir="./Analysis/Registered/CSF_Mask"
output_dir="./ROIs"
tmp_dir="./ROIs/tmp"

if [ ! -d "$tmp_dir" ]; then
    echo "Directory $tmp_dir does not exist. Creating it now..."
    mkdir -p "$tmp_dir"
    echo "Directory $tmp_dir created."
fi

CSF_Mask="$CSF_dir/${prefix}_CSF_Mask.nii.gz"
CSF_Mask_Inv="$tmp_dir/${prefix}_CSF_Mask_Inv.nii.gz"
CSF_Mask_Inv_Erode="$tmp_dir/${prefix}_CSF_Mask_Inv_Erode.nii.gz"
fslmaths "$CSF_Mask" -binv "$CSF_Mask_Inv"
ImageMath 3 "$CSF_Mask_Inv_Erode" ME "$CSF_Mask_Inv" 2

QSM_Mask="$QSM_dir/${prefix}_Mask_Use_FLIRT.nii.gz"

CSF_Mask_Inv_Erode_Mul="$tmp_dir/${prefix}_CSF_Mask_Inv_Erode_Mul.nii.gz"
fslmaths $QSM_Mask -mul $CSF_Mask_Inv_Erode "$CSF_Mask_Inv_Erode_Mul"
CSF_Mask_Inv_Erode_Mul_Open="$tmp_dir/${prefix}_CSF_Mask_Inv_Erode_Mul_Open.nii.gz"
ImageMath 3 "$CSF_Mask_Inv_Erode_Mul_Open" MO "$CSF_Mask_Inv_Erode_Mul" 2

BET_Mask="$BET_dir/${prefix}_mask.nii.gz"
BET_Mask_Erode="$tmp_dir/${prefix}_BET_Mask_Erode.nii.gz"
ImageMath 3 "$BET_Mask_Erode" ME "$BET_Mask" 11
CSF_Mask_Inv_Erode_Mul_Open_BET_Erode="$tmp_dir/${prefix}_CSF_Mask_Inv_Erode_Mul_Open_BET_Erode.nii.gz"
fslmaths "$BET_Mask_Erode" -mul "$CSF_Mask_Inv_Erode_Mul_Open" "$CSF_Mask_Inv_Erode_Mul_Open_BET_Erode"

#seg="$tmp_dir/${prefix}_seg.nii.gz"
ROIs="$output_dir/${prefix}_ROIs.nii.gz"

cluster -i "$CSF_Mask_Inv_Erode_Mul_Open_BET_Erode" -t 0.5 -o "$ROIs" --connectivity=6 --minextent=1000

R2s_dir="./Data/Padded/R2s"
R2s="$R2s_dir/${prefix}_R2s_Padded.nii.gz"
Segmentation_2="$tmp_dir/${prefix}_Segmentation_2.nii.gz"
minextent_straws="200" res="1" # Parameters given in mm
cluster -i "$R2s" -t 5 --fractional -o "$Segmentation_2" --minextent=$minextent_straws --connectivity=6 --mm -r "$res"
fslmaths "$Segmentation_2" -mas "$QSM_Mask" "$Segmentation_2"

#ImageMath 3 "$ROIs" ReplaceVoxelValue "$seg" 6.5 Inf 0

exit 0
