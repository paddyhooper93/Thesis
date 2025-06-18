#!/bin/bash
# Define data prefixes
data_prefix=("3T" "7T")                                         # "3T" "7T"
rotations=("Neutral" "Rot1" "Rot2" "Rot3" "Rot4" "Rot5" "Rot6") # "Neutral" "Rot1" "Rot2" "Rot3" "Rot4" "Rot5" "Rot6"
# Define directory
NC_dir="./Data/NC/"
MCPC_dir="./Data/MCPC/"

dirs=("$NC_dir" "$MCPC_dir")
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
        input_magn="${NC_dir}${prefix}_${r}_Magn"      # Magn = 4D Magnitude image
        input_phs="${MCPC_dir}${prefix}_${r}_Phs_MCPC" # Phs = 4D Phase image
        output_magn="${output_magn}_fslcpgeom"

        if [[ -f "$input_magn.nii.gz" ]]; then
            # copy the header information without altering the dimensions
            fslcpgeom "${input_phs}".nii.gz "$input_magn" -d

            # flip about the x-axis (LR)
            # fslswapdim "${input_magn}".nii.gz -x y z "${output_magn}"
        else
            echo "Input image $input_magn does not exist. Skipping."
        fi

    done
done
