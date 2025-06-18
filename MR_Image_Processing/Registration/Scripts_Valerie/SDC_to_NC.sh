#!/bin/bash
# Define data prefixes
data_prefix=("3T" "7T") # "3T" "7T"
rotations=("Neutral")   # "Neutral" "Rot1" "Rot2" "Rot3" "Rot4" "Rot5" "Rot6"
# Define directory
main_dir="./Data/NC/"
r2s_dir="./Data/R2s/"
mask_dir="./Data/Mask_Use/"

dirs=("$main_dir" "$r2s_dir" "$mask_dir")
for dir in "${dirs[@]}"; do
    if [ -d "$dir" ]; then
        echo "Directory $dir already exists."
    else
        echo "Directory $dir does not exist. Creating it now..."
        mkdir -p "$dir"
        echo "Directory $dir created."
    fi
done

# Loop through prefix
for prefix in "${data_prefix[@]}"; do
    # Loop through rotations (r)
    for r in "${rotations[@]}"; do
        # Skip if the data_prefix is "7T" AND rotations is "Rot6"
        if [[ "$prefix" == "7T" && "$r" == "Rot6" ]]; then
            echo "Skipping $prefix with $r"
            continue
        fi

        # Proceed with your command if not skipped
        echo "Running $prefix with $r"
        # Define input and output image names
        input_magn="${main_dir}${prefix}_${r}_Magn"     # Magn = 4D Magnitude image
        input_mask="${mask_dir}${prefix}_${r}_Mask_Use" # Mask_Use = 3D Binary mask
        input_r2s="${r2s_dir}${prefix}_${r}_R2s"        # R2s = 3D R2s map
        output_mask="${input_mask}_FlipLR"
        output_r2s="${input_r2s}_FlipLR"

        if [[ -f "$input_magn.nii.gz" ]]; then
            # copy the header information without altering the dimensions
            fslcpgeom "${input_magn}".nii.gz "$input_mask" -d
            fslcpgeom "${input_magn}".nii.gz "$input_r2s" -d

            # flip about the x-axis (LR)
            fslswapdim "${input_mask}".nii.gz -x y z "${output_mask}"
            fslswapdim "${input_r2s}".nii.gz -x y z "${output_r2s}"
        else
            echo "Input image $input_magn does not exist. Skipping."
        fi

    done
done
