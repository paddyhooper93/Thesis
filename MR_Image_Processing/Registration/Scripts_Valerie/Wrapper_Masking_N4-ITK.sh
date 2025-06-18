#!/bin/bash
# Define data prefixes
data_prefix=("7T")    # "7T"
acquisitions=("Rot5") # "Neutral" "Rot4" "Rot2" "Rot1" "Rot6"

input_dir="./Data/Padded/SDC"
N4_output_dir="./Data/Padded/N4-ITK"
mask_dir="./Data/Padded/SDC"

script_dir="/mnt/c/Users/rosly/Documents/Valerie_PH"
cd "$script_dir" || exit

# Main loop
for prefix in "${data_prefix[@]}"; do
    # Subject loop
    for sub in "${acquisitions[@]}"; do
        dataset="${prefix}_${sub}"
        echo "Running $dataset ..."

        #./BET-Masking.sh "$dataset" "$input_dir" "$mask_dir" 1 1
        ./Apply_N4.sh "$dataset" "$input_dir" "$N4_output_dir" "$mask_dir"
    done
done
