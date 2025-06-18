#!/bin/bash
# Function to do FLIRT on datasets
# Usage: Wrapper_ApplyMatrix.sh prefix sub input_dir output_dir

prefix="$1"
sub="$2"
ref_sub="$3"
reference_dir="$4"
input_dir="$5"
output_dir="$6"

script_dir="/mnt/c/Users/rosly/Documents/Valerie_PH"
cd "$script_dir" || exit
echo "Running Wrapper_ApplyMatrix.sh"

matrix_dir="$reference_dir/Matrices"

if [ ! -d "$output_dir" ]; then
    echo "Directory $output_dir does not exist. Creating it now..."
    mkdir -p "$output_dir"
    echo "Directory $output_dir created."
fi

# (i): ANTS registration
ref_img="${reference_dir}/${prefix}_${ref_sub}_TMedian.nii.gz"
moving_img="${input_dir}/${prefix}_${sub}_Delta.nii.gz"
ITK_img="${output_dir}/${prefix}_${ref_sub}_to_${sub}_Delta_ITK.nii.gz"
ITK_tfm="${matrix_dir}/${prefix}_${ref_sub}_to_${sub}_FLIRT_ITK.mat"
ants_cmd="antsApplyTransforms -d 3 -e scalar -i $moving_img -r $ref_img -o $ITK_img -n Bspline -t $ITK_tfm -v"
./check_command.sh "$ants_cmd"

# Copy transform to output directory
ITK_tfm_cp="${output_dir}/${prefix}_${ref_sub}_to_${sub}_FLIRT_ITK.mat"
cp "$ITK_tfm" "$ITK_tfm_cp"
echo "Copied $ITK_tfm to $ITK_tfm_cp"

# Copy reference Delta to output directory
ref_delta="${reference_dir}/${prefix}_${ref_sub}_Delta.nii.gz"
ref_delta_cp="${output_dir}/${prefix}_${ref_sub}_Delta.nii.gz"
cp "$ref_delta" "$ref_delta_cp"
echo "Copied $ref_delta to $ref_delta_cp"
