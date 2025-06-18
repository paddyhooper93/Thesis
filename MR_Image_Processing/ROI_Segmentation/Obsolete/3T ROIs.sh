#!/bin/bash

script_dir="/mnt/c/Users/rosly/Documents/Valerie_PH"
cd "$script_dir" || exit
echo "Running ./3T ROIs.sh"

prefix="3T_Rot5"
QSM_dir="./Analysis/NC"

output_dir="./ROIs"
tmp_dir="./ROIs/tmp"

if [ ! -d "$tmp_dir" ]; then
    echo "Directory $tmp_dir does not exist. Creating it now..."
    mkdir -p "$tmp_dir"
    echo "Directory $tmp_dir created."
fi

CSF_Mask="$QSM_dir/${prefix}_CSF_Mask.nii.gz"
CSF_Mask_Inv="$tmp_dir/${prefix}_CSF_Mask_Inv.nii.gz"
CSF_Mask_Inv_Erode="$tmp_dir/${prefix}_CSF_Mask_Inv_Erode.nii.gz"
fslmaths "$CSF_Mask" -binv "$CSF_Mask_Inv"
ImageMath 3 "$CSF_Mask_Inv_Erode" ME "$CSF_Mask_Inv" 3

QSM_Mask="$QSM_dir/${prefix}_Mask_Use.nii.gz"

tmp_Mask="$tmp_dir/${prefix}_tmp_Mask.nii.gz"
fslmaths $QSM_Mask -mul $CSF_Mask_Inv_Erode "$tmp_Mask"
tmp_Mask_Open="$tmp_dir/${prefix}_tmp_Mask_Open.nii.gz"
ImageMath 3 "$tmp_Mask_Open" MO "$tmp_Mask" 1

seg="$tmp_dir/${prefix}_seg.nii.gz"
cluster -i "$$tmp_Mask_Open" -t 0.5 -o "$seg" --connectivity=6 --minextent=100

ROIs="$output_dir/${prefix}_ROIs.nii.gz"
ImageMath 3 "$ROIs" ReplaceVoxelValue "$seg" 6.5 7.5 0

exit 0

# R2s_dir="./Data/Padded"
#R2s="$R2s_dir/${prefix}_R2s_Padded.nii.gz"
#R2s_uthr="$output_dir/${prefix}_R2s_uthres.nii.gz"
#fslmaths "$R2s" -uthr 60 "$R2s_uthr"
#R2s_MO="$output_dir/${prefix}_R2s_Open.nii.gz"
#ImageMath 3 "$R2s_MO" MO "$R2s_uthr" 1
#seg2="$tmp_dir/${prefix}_seg2.nii.gz"
#minextent_straws="220"
#cluster -i "$R2s_MO" -t 5 -o "$seg2" --connectivity=6 --minextent="$minextent_straws"

#ImageMath 3 3T_Rot5_R2_Open.nii.gz MO 3T_Rot5_R2s_mask.nii.gz 1
#minextent_straws="220"
#cluster -i 3T_Rot5_R2s_Open.nii.gz -t 0.5 -o 3T_Rot5_Seg2.nii.gz --connectivity=6 --minextent="$minextent_straws"
