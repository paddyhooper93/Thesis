#!/bin/bash

# Data prefixes
data_prefix=("3T" "7T")      # "3T" "7T"
num_orient=("3" "4" "5" "6") #  "3" "4" "5" "6"
image_contrast=("chi_CF")    # "chi_CF" "chi_LSQR"

script_dir="/mnt/c/Users/rosly/Documents/Valerie_PH"
cd "$script_dir" || exit

dir_in="./Analysis/Registered/COSMOS_SNRwAVG_PDF"
mask_dir="./Analysis/Registered/Brain_ROI_Mask"
dir_out="./Analysis/Registered/COSMOS_SNRwAVG_PDF/deGibbs"

for prefix in "${data_prefix[@]}"; do

    mask="${mask_dir}/${prefix}_Neutral_BET_Mask_Erode_FLIRT.nii.gz"

    for orient in "${num_orient[@]}"; do

        for contrast in "${image_contrast[@]}"; do

            #if [[ "$contrast" =~ ^"Magn" ]]; then
            #    dir_use="./Data/Padded/N4-ITK"
            #else
            #    dir_use="./Data/Padded/SDC"
            #fi
            #input_img="${dir_use}/${dataset}_${contrast}_Padded.nii.gz"
            #output_img="${dir_out}/${dataset}_${contrast}_Padded.nii.gz"
            input_img="${dir_in}/${prefix}_${contrast}_${orient}_Orient.nii.gz"
            output_img="${dir_out}/${prefix}_${contrast}_${orient}_Orient.nii.gz"
            ./Wrapper_mrdegibbs.sh "$input_img" "$mask" "$output_img"

            #./Wrapper_CreateBETMasks.sh "$dataset" "$BET_input_dir" "$BET_output_dir" "$tmp_dir" "$TEi" "$TEf"
            #./Wrapper_NonLocalMeans.sh "$dataset" "$dir_1" "$dir_2"
            #./Wrapper_mrdegibbs.sh "$prefix" "$sub" "$ref_sub" "$input_dir" "$mask_dir" "$output_dir" "$contrast"
            #./Wrapper_SUSAN.sh "$dataset" "$susan_input_dir" "$susan_output_dir" "$BET_output_dir"
            #./Wrapper_mrdegibbs.sh "$dataset" "$degibbs_input_dir" "$degibbs_output_dir" "$BET_output_dir" &&
            #./Wrapper_N4.sh "$dataset" "$N4_input_dir" "$N4_output_dir" "$BET_output_dir"
            # Clear temp
            #echo "Clearing NIfTI files within temp directory: $tmp_dir"
            #rm -f "$tmp_dir"/*.nii.gz
        done
    done
done

# Remove temp
#echo "Removing temp directory: $tmp_dir"
#rm -rf $tmp_dir

exit 0
