#!/bin/bash
# Function to do Gibbs Ringing artifact removal on datasets
# Usage: Wrapper_mrdegibbs3D.sh dataset input_dir output_dir mask_dir

dataset="$1"
input_dir="$2"
output_dir="$3"
contrast="$4"

script_dir="/mnt/c/Users/rosly/Documents/Valerie_PH"
cd "$script_dir" || exit

if [ ! -d "$output_dir" ]; then
    mkdir -p "$output_dir"
fi

input_img="${input_dir}/${dataset}_${contrast}.nii.gz"
#mask_input="${input_dir}/${dataset}_Mask_Use.nii.gz"
mask_fillh="${output_dir}/${dataset}_Mask_Fillh.nii.gz"
degibbs_img="${output_dir}/${dataset}_${contrast}_Degibbs3D.nii.gz"

# Fill in holes for mask
#fslmaths "$mask_input" -fillh "$mask_fillh"

# mrdegibbs command
/home/uqphoop1/mrtrix3/mrdegibbs3D/bin/deGibbs3D \
    -force \
    -nthreads 8 \
    "$input_img" \
    "$degibbs_img"

# Copy header information
fslcpgeom "$mask_fillh" "$degibbs_img" -d
# Re-scale image
#ImageMath 4 "$degibbs_img" RescaleImage "$degibbs_img" 0 4095 "$degibbs_img" Cast
# Mask image
#fslmaths -dt int "$degibbs_img" -mul "$mask_fillh" "$degibbs_img" -odt int
