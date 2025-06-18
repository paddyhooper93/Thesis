#!/bin/bash

dataset="$1"
input_dir="$2"
output_dir="$3"

script_dir="/mnt/c/Users/rosly/Documents/Valerie_PH"
cd "$script_dir" || exit

echo "Running Wrapper_NonLocalMeans.sh"

dirs=("$input_dir" "$output_dir")

for dir in "${dirs[@]}"; do
    if [ ! -d "$dir" ]; then
        echo "Directory $dir does not exist. Creating it now..."
        mkdir -p "$dir"
        echo "Directory $dir created."
    fi
done

mask_use="${output_dir}/${dataset}_Mask_NLM.nii.gz"
#mask_use="${input_dir}/${dataset}_mask.nii.gz"

input_magn="${input_dir}/${dataset}_Magn_Padded.nii.gz"
output_magn="${output_dir}/${dataset}_Magn_NLM.nii.gz"

input_phs="${input_dir}/${dataset}_Phs_Padded.nii.gz"
output_phs="${output_dir}/${dataset}_Phs_NLM.nii.gz"

# (i) Generate mask
ImageMath 4 "$mask_use" GetLargestComponent "$input_magn"

# (ii) Apply denoising
cmd1="DenoiseImage -d 4 -v 1 \
    -i $input_magn \
    -n Gaussian \
    -x $mask_use \
    -s 1 \
    -p 1 \
    -r 2 \
    -o $output_magn"
echo "$cmd1"
./check_command.sh "$cmd1"
cmd2="DenoiseImage -d 4 -v 1 \
    -i $input_phs \
    -n Gaussian \
    -x $mask_use \
    -s 1 \
    -p 1 \
    -r 2 \
    -o $output_phs"
echo "$cmd2"
./check_command.sh "$cmd2"

cmd3="rm $mask_use -r"
echo "$cmd3"
./check_command.sh "$cmd3"

exit 0
