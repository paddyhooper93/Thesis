#!/bin/bash
# Usage: ./Apply_N4.sh dataset input_dir output_dir mask_dir

dataset="$1"
input_dir="$2"
output_dir="$3"
mask_dir="$4"

script_dir="/mnt/c/Users/rosly/Documents/Valerie_PH"
cd "$script_dir" || exit

tmp_dir="${output_dir}/tmp"

if [ ! -d "$tmp_dir" ]; then
    echo "Directory $tmp_dir does not exist. Creating it now..."
    mkdir -p "$tmp_dir"
    echo "Directory $tmp_dir created."
fi

if ls "$tmp_dir"/*.nii.gz 1>/dev/null 2>&1; then
    echo "Clearing NIfTI files within temp directory: $tmp_dir"
    rm -f "$tmp_dir"/*.nii.gz
fi

# Define filenames
input_img="${input_dir}/${dataset}_Magn.nii.gz"
input_img_rs="${tmp_dir}/${dataset}_Magn_rs.nii.gz"
#TMedian_img="${tmp_dir}/${dataset}_Magn_TMedian.nii.gz"
E1_img="${tmp_dir}/${dataset}_Magn_E1.nii.gz"
mask_use="${mask_dir}/${dataset}_mask.nii.gz"
N4_E1="${tmp_dir}/${dataset}_Magn_N4_E1.nii.gz"
bias_field="${tmp_dir}/${dataset}_Bias_Field_E1.nii.gz"
N4_img="${output_dir}/${dataset}_Magn.nii.gz"

# Copy image header information: direction, origin, spacing but not dimensions.
#base_dir="./Data/NC"
# case "$dataset" in
# 7T)
#     hdr_template="${base_dir}/7T_Rot5_Magn.nii.gz"
#     ;;
# 3T)
#     hdr_template="${base_dir}/3T_Rot1_Magn.nii.gz"
#     ;;
# esac
# fslcpgeom "$hdr_template" "$mask_use" -d
# fslcpgeom "$hdr_template" "$input_img" -d

# Tmedian image
#time_cmd="fslmaths ${input_img} -Tmedian ${TMedian_img}"
#echo "$time_cmd"
#./check_command.sh "$time_cmd"

# Rescale image
rs_cmd="ImageMath 4 $input_img_rs RescaleImage $input_img 10 100"
echo "$rs_cmd"
./check_command.sh "$rs_cmd"

# TE1 image
te1_cmd="fslroi $input_img_rs $E1_img 0 1"
echo "$te1_cmd"
./check_command.sh "$te1_cmd"

# Apply N4 command (see https://github.com/ANTsX/ANTs/wiki/N4BiasFieldCorrection)
N4_cmd="N4BiasFieldCorrection -d 3 -v 1 \
    -s 4 \
    -b [ 100 ] \
    -c [ 100x100x100x100, 0.0 ] \
    -i $E1_img \
    -x $mask_use \
    -o [${N4_E1}, ${bias_field}]"
echo "$N4_cmd"
./check_command.sh "$N4_cmd"

# Split 4D time-series into 3D volume
fslsplit "$input_img" "$tmp_dir"/vol_ -t

for i in "$tmp_dir"/vol_*; do
    volume_base=$tmp_dir/$(basename "$i" .nii.gz)
    # Divide each volume by the bias-field to get the corrected image.
    fslmaths "$volume_base" -div "$bias_field" "$volume_base"_N4
done
# Combine each volume to 4D time-series
fslmerge -t "$N4_img" "$tmp_dir"/*_N4.nii.gz
# Copy header
fslcpgeom "$mask_use" "$N4_img" -d
# Mask image
fslmaths -dt int "$N4_img" -mas "$mask_use" "$N4_img" -odt int
# Re-scale image
ImageMath 4 "$N4_img" RescaleImage "$N4_img" 0 4095
# Clear temp
echo "Clearing NIfTI files within temp directory: $tmp_dir"
rm -f "$tmp_dir"/*.nii.gz
# Remove temp
echo "Removing temp directory: $tmp_dir"
rm -rf $tmp_dir

exit 0
