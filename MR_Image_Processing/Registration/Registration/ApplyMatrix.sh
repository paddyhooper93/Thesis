#!/bin/bash
# Function to do FLIRT on datasets
# Usage: ApplyMatrix.sh prefix sub ref_sub reference_dir input_dir output_dir contrast performInverse convertITK performSyN

# Check if at least 7 arguments are provided
if [[ $# -lt 7 ]]; then
    echo "Error: At least 7 arguments are required."
    echo "Usage: $0 prefix sub ref_sub reference_dir input_dir output_dir contrast [performInverse] [convertITK] [performSyN]"
    exit 1
fi

prefix="$1"
sub="$2"
ref_sub="$3"
reference_dir="$4"
input_dir="$5"
output_dir="$6"
contrast="$7"
performInverse="${8:-0}"
convertITK="${9:-0}"
performSyN="${10:-0}"

script_dir="/mnt/c/Users/rosly/Documents/Valerie_PH"
cd "$script_dir" || exit
echo "Running ApplyMatrix.sh"

if [ ! -d "$output_dir" ]; then
    echo "Directory $output_dir does not exist. Creating it now..."
    mkdir -p "$output_dir"
    echo "Directory $output_dir created."
fi

# (i): Forward or inverse (backward) transform
flirt_tfm="${reference_dir}/${prefix}_${ref_sub}_to_${sub}_FLIRT.mat"
shopt -s nocasematch
if [[ "$performInverse" -eq 1 ]]; then
    moving_img="${input_dir}/${prefix}_${ref_sub}_${contrast}_FLIRT.nii.gz"
    ref_img="${reference_dir}/${prefix}_${sub}_TMedian.nii.gz"
    tfm="${reference_dir}/${prefix}_${ref_sub}_to_${sub}_INV.mat"
    inverse_cmd="convert_xfm -omat $tfm -inverse $flirt_tfm"
    echo "$inverse_cmd"
    ./check_command.sh "$inverse_cmd"
else
    ref_img="${reference_dir}/${prefix}_${ref_sub}_TMedian.nii.gz"
    moving_img="${input_dir}/${prefix}_${sub}_${contrast}.nii.gz"
    tfm="$flirt_tfm"
fi
shopt -u nocasematch
# (ii): Converting from ITK to FLIRT transform type (e.g., if using ITK-SNAP to generate initial transform)
if [[ "$convertITK" -eq 1 ]]; then
    itk_tfm="${reference_dir}/${prefix}_${ref_sub}_to_${sub}_ITK.mat"
    c3d_cmd="c3d_affine_tool -ref $ref_img -src $moving_img $itk_tfm -ras2fsl -o $flirt_tfm"
    echo "$c3d_cmd"
    ./check_command.sh "$c3d_cmd"
fi
# (iii) apply transform (no optimization): flirt command with -applyxfm and -init
flirt_img="${output_dir}/${prefix}_${ref_sub}_to_${sub}_${contrast}_FLIRT.nii.gz"
if [[ "$contrast" =~ ^"Imag" ]] || [[ "$contrast" =~ ^"Real" ]]; then
    interp="trilinear"
else
    interp="sinc"
fi
flirt_cmd="flirt -v -interp $interp -in $moving_img -ref $ref_img -out $flirt_img -applyxfm -init $tfm -datatype double" # -cost normcorr -dof 6
echo "$flirt_cmd"
./check_command.sh "$flirt_cmd"
# (iv) Convert transformed image (float data type) into binary (ones and zeros).
shopt -s nocasematch
if [[ "$contrast" == *"mask"* ]]; then
    binary_mask="${output_dir}/${prefix}_${ref_sub}_to_${sub}_${contrast}.nii.gz"
    binarize_cmd="ThresholdImage 3 $flirt_img $binary_mask 0.5 Inf 1 0"
    echo "$binarize_cmd"
    ./check_command.sh "$binarize_cmd"
    rm_cmd="rm -r -v $flirt_img"
    echo "$rm_cmd"
    ./check_command.sh "$rm_cmd"
fi
shopt -u nocasematch
# (v) Additional SyN registration
if [[ "$performSyN" -eq 1 ]]; then
    # (v.1) Convert FSL transformation matrix into ITK format
    itk_tfm="${reference_dir}/${prefix}_${ref_sub}_to_${sub}_ITK.mat"
    c3d_cmd="c3d_affine_tool -ref $ref_img -src $moving_img $flirt_tfm -fsl2ras -oitk $itk_tfm"
    echo "$c3d_cmd"
    ./check_command "$c3d_cmd"
    # (v.2) ANTS command
    ants_img="${output_dir}/${prefix}_${ref_sub}_to_${sub}_${contrast}_ANTS.nii.gz"
    ref_mask="${input_dir}/${prefix}_${ref_sub}_Mask_Use.nii.gz"
    ants_tfm="${output_dir}/${prefix}_${ref_sub}_to_${sub}_"
    ants_cmd="antsRegistration -d 3 -v 1 \
    -o [$ants_tfm,$ants_img] \
    -n LanczosWindowedSinc \
    -r $itk_tfm \
    -t SyN[0.1,3,0]\
    --metric CC[$ref_img,$moving_img,1,4]\
    -c [100x70x50x20]\
    -f 8x4x2x1\
    -s 3x2x1x0vox\
    -x $ref_mask"
    echo "$ants_cmd"
    ./check_command.sh "$ants_cmd"
fi
