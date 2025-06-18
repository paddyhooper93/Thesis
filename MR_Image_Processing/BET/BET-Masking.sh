#!/bin/bash
# Useage" ./BETMasking dataset input_dir output_dir tmp_dir TEi TEf

dataset=$1
input_dir=$2
output_dir=$3
TEi=$4
TEf=$5

tmp_dir="$output_dir/temp"

if [ ! -d "$tmp_dir" ]; then
    echo "Directory $tmp_dir does not exist. Creating it now..."
    mkdir -p "$tmp_dir"
    echo "Directory $tmp_dir created."
fi

if ls "$tmp_dir"/*.nii.gz 1>/dev/null 2>&1; then
    echo "Clearing NIfTI files within temp directory: $tmp_dir"
    rm -f "$tmp_dir"/*.nii.gz
fi

# Define input and output image names

input_img="${input_dir}/${dataset}_Magn_Padded.nii.gz"
TMedian_img="${tmp_dir}/${dataset}_TMedian"
mask="${TMedian_img}_mask"
mask_cp="${output_dir}/${dataset}_mask.nii.gz"

# TE selection
start=$((TEi - 1))
size=$((TEf - TEi + 1))
fslroi "$input_img" "$TMedian_img" "$start" "$size"
# Tmedian image
fslmaths "$TMedian_img" -Tmedian "$TMedian_img"
# Threshold Tmedian image
fslmaths "${TMedian_img}" -thrP 10 "${TMedian_img}"
# Mask Tmedian image
bet "${TMedian_img}" "${TMedian_img}" -f 0.5 -g 0 -m -n -R # -c 141 125 145 (specify c if brain is not centered correctly).
# Hole filling
fslmaths "${mask}" -fillh "${mask}"
# Copy to output dir
cp "${mask}.nii.gz" "${mask_cp}"
