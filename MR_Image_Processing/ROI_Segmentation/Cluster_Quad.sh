#!/bin/bash
# Define data prefixes
fs=("3T" "7T")

# Define directories
input_dir="./Analysis/internal_field_mask/"
output_dir="$input_dir"

# Loop through fs
for i in "${fs[@]}"; do
    # Loop through quad
    for q in {1..4}; do
        mask="${input_dir}${i}_9mth_mask_Quad_${q}.nii.gz"
        seg="${output_dir}${i}_9mth_seg_Quad_${q}.nii.gz"
        cmd="cluster --in=${mask} --thresh=0.5 --oindex=${seg} --minextent=1000"
        echo "$cmd"
        ./check_command_PH.sh "$cmd"
    done
done
exit 0
