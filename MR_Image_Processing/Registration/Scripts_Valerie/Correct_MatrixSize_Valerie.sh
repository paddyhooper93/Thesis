#!/bin/bash
# Define data prefixes
data_prefix=("3T" "7T")
acquisitions=("Rot1" "Rot3" "Rot5")

# Define directories
script_dir="/mnt/c/Users/rosly/Documents/Valerie_PH"
cd "$script_dir" || exit

magn_dir="./Data/susan"
phs_dir="./Data/MCPC"
mask_dir="./Data/Mask_Use"
output_dir="./Data/MatrixSizeCorrect"

dirs=("$magn_dir" "$mask_dir" "$phs_dir" "$output_dir")

for dir in "${dirs[@]}"; do
    if [ ! -d "$dir" ]; then
        echo "Directory $dir does not exist. Creating it now..."
        mkdir -p "$dir"
        echo "Directory $dir created."
    fi
done

for prefix in "${data_prefix[@]}"; do
    for sub in "${acquisitions[@]}"; do
        dataset="${prefix}"_"${sub}"
        magn="${magn_dir}/${dataset}_Magn_Susan.nii.gz"
        phs="${phs_dir}/${dataset}_Phs_MCPC.nii.gz"
        mask="${mask_dir}/${dataset}_Mask_Use.nii.gz"
        magn_out="${output_dir}/${dataset}_Magn_Use.nii.gz"
        phs_out="${output_dir}/${dataset}_Phs_Use.nii.gz"
        mask_out="${output_dir}/${dataset}_Mask_Use.nii.gz"
        ./pad_or_crop.sh "$magn" "$dataset" "$magn_out" 4
        ./pad_or_crop.sh "$phs" "$dataset" "$phs_out" 4
        ./pad_or_crop.sh "$mask" "$dataset" "$mask_out" 3
    done
done

exit 0
