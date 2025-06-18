#!/bin/bash
# Function to do SUSAN denoising on datasets
# Usage: ./Wrapper_SUSAN.sh dataset input_dir output_dir mask_dir

dataset="$1"
input_dir="$2"
output_dir="$3"
mask_dir="$4"

script_dir="/mnt/c/Users/rosly/Documents/Valerie_PH"
cd "$script_dir" || exit

if [ ! -d "$output_dir" ]; then
    echo "Directory $output_dir does not exist. Creating it now..."
    mkdir -p "$output_dir"
    echo "Directory $output_dir created."
fi

input_img="${input_dir}/${dataset}_Magn.nii.gz"
susan_img="${output_dir}/${dataset}_Magn_Susan.nii.gz"
mask_use="${mask_dir}/${dataset}_mask.nii.gz"

# SUSAN command (see https://web.mit.edu/fsl_v5.0.10/fsl/doc/wiki/SUSAN.html)
max_intensity=$(fslstats "$input_img" -r | awk '{print $2}')
bthresh=$(echo "scale=10; $max_intensity * 0.1" | bc) # Set brightness threshold to 10 % of max intensity
sigma="3"                                             # spatial size of smoothing, in mm, or "0" for fast, flat response (3x3x3 voxels)
dims="3"                                              # full 3D mode (suitable for thin slices)
use_median="1"                                        # Use median when no neighbourhood is found
secondary_imgs="0"                                    # Use secondary images to find USAN

susan \
    "$input_img" \
    "$bthresh" \
    "$dims" \
    "$sigma" \
    "$use_median" \
    "$secondary_imgs" \
    "$susan_img"

# Copy header information
fslcpgeom "$mask_use" "$susan_img" -d
# Re-scale image
ImageMath 4 "$susan_img" RescaleImage "$susan_img" 0 4095 "$susan_img" Cast
# Mask image
fslmaths -dt int "$susan_img" -mul "$mask_use" "$susan_img" -odt int
