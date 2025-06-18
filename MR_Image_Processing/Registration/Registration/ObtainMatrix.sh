#!/bin/bash
# Function to do FLIRT on datasets
# Usage: ObtainMatrix.sh prefix sub input_dir output_dir

prefix="$1"
sub="$2"
ref_sub="$3"
input_dir="$4"
output_dir="$5"
#weights_dir="$6"

cd "$input_dir" || exit
script_dir="/mnt/c/Users/rosly/Documents/Valerie_PH"
cd "$script_dir" || exit
echo "Running ObtainMatrix.sh"

# (i): Obtain a time median image for registration
# ref_input="${input_dir}/${prefix}_${ref_sub}_Magn_N4_Padded.nii.gz"
# moving_input="${input_dir}/${prefix}_${sub}_Magn_N4_Padded.nii.gz"
# ref_img="${output_dir}/${prefix}_${ref_sub}_TMedian.nii.gz"
# moving_img="${output_dir}/${prefix}_${sub}_TMedian.nii.gz"
#ref_weight="${weights_dir}/${prefix}_${ref_sub}_weights.nii.gz"
#moving_weight="${weights_dir}/${prefix}_${sub}_weights.nii.gz"

# TE selection
# TEi="1"
# TEf="4"
# start=$((TEi - 1))
# size=$((TEf - TEi + 1))
# fslroi "$ref_input" "$ref_img" "$start" "$size"
# fslroi "$moving_input" "$moving_img" "$start" "$size"
# Tmedian image
# fslmaths "$ref_img" -Tmedian "$ref_img"
# fslmaths "$moving_img" -Tmedian "$moving_img"

# (i) Use "iMag" (the sum-of-squares magnitude image using TEs indexed 1 to 4, after applying N4 correction)
# TEs indexed 1 to 4 (5 to 7 discarded)

ref_img="${input_dir}/${prefix}_${ref_sub}_Magn_Demeaned.nii.gz"
moving_img="${input_dir}/${prefix}_${sub}_Magn_Demeaned.nii.gz"
#degibbs_img="${input_dir}/${prefix}_${sub}_iMag_Degibbs.nii.gz"

#/opt/mrtrix3/mrdegibbs3D/bin/deGibbs3D -info \
#    -force \
#    -nthreads 8 \
#    "$moving_img" \
#    "$degibbs_img"

# (ii): FLIRT registration
flirt_img="${output_dir}/${prefix}_${ref_sub}_to_${sub}_Magn_Demeaned_FLIRT.nii.gz"
flirt_tfm="${output_dir}/${prefix}_${ref_sub}_to_${sub}_FLIRT.mat"

if [[ "$prefix" =~ ^"3T" ]] && [[ "$sub" =~ ^"Rot2" ]]; then
    #itk_tfm="${output_dir}/${prefix}_${ref_sub}_to_${sub}_ITK.mat"
    init_tfm="${output_dir}/${prefix}_${ref_sub}_to_${sub}_Init.mat"
    #c3d_affine_tool -ref "$ref_img" -src "$moving_img" "$itk_tfm" -ras2fsl -o "$init_tfm"
else
    init_tfm="${output_dir}/eye_matr.mat"
fi
flirt_cmd="flirt -v -dof 6 \
-cost normcorr -interp spline \
-in $moving_img -ref $ref_img \
-init $init_tfm \
-out $flirt_img -omat $flirt_tfm"
./check_command.sh "$flirt_cmd"
#-refweight $ref_weight -inweight $moving_weight"

# Convert FSL transformation matrix into ITK format (required for ANTS)
itk_tfm="${output_dir}/${prefix}_${ref_sub}_to_${sub}_ITK.mat"
c3d_affine_tool -ref "$ref_img" -src "$moving_img" "$flirt_tfm" -fsl2ras -oitk "$itk_tfm" -info >"${output_dir}/${prefix}_${ref_sub}_to_${sub}_info.txt"
