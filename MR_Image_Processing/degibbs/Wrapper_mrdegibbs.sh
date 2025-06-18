#!/bin/bash
# Function to do Gibbs Ringing artifact removal on datasets
# Usage: Wrapper_mrdegibbs.sh prefix sub ref_sub input_dir mask_dir output_dir contrast

#refix="$1"
#sub="$2"
#ref_sub="$3"
#input_dir="$4"
#mask_dir="$5"
#output_dir="$6"
#contrast="$7"

input_img="$1"
mask="$2"
output_img="$3"

script_dir="/mnt/c/Users/rosly/Documents/Valerie_PH"
cd "$script_dir" || exit

masked_input="tmp_img.nii.gz"
cmd_fsl="fslmaths $input_img -mul $mask $masked_input"
echo "$cmd_fsl"
./check_command.sh "$cmd_fsl"

# mrdegibbs 3D
cmd_degibbs="/opt/mrtrix3/mrdegibbs3D/bin/deGibbs3D -info \
    -force \
    -nthreads 8 \
    $masked_input \
    $output_img"
echo "$cmd_degibbs"
./check_command.sh "$cmd_degibbs"

rm_cmd="rm -r $masked_input"
echo "$rm_cmd"
./check_command.sh "$rm_cmd"

#mask_use="${mask_dir}/${dataset}_mask.nii.gz"
# degibbs_img_X="${tmp_dir}/${dataset}_Magn_Degibbs.nii.gz"
# degibbs_img_Y="${tmp_dir}/${dataset}_Magn_Degibbs_Y.nii.gz"

# mrdegibbs on Y-axis
# mrdegibbs -datatype int16 \
#     -nthreads 8 \
#     -force \
#     -axes 1 \
#     "$degibbs_img_X" \
#     "$degibbs_img_Y"
# mrdegibbs on Z-axis
# mrdegibbs -datatype int16 \
#     -nthreads 8 \
#     -force \
#     -axes 2 \
#     "$degibbs_img_Y" \
#     "$degibbs_img_3D"
# Copy header information
#fslcpgeom "$mask_use" "$degibbs_img_3D" -d
# Re-scale image
#ImageMath 4 "$degibbs_img_3D" RescaleImage "$degibbs_img_3D" 0 4095 "$degibbs_img_3D" Cast
# Mask image
#fslmaths -dt int "$degibbs_img_3D" -mul "$mask_use" "$degibbs_img_3D" -odt int

# Clear temp
#rm -f "$tmp_dir"/*.nii.gz
# Remove temp
#rm -rf "$tmp_dir"
