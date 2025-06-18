#!/bin/bash

# Data prefixes
data_prefix=("7T")             # "3T" "7T"
acquisition=("Rot6")           # "Neutral" "Rot1" "Rot2" "Rot3" "Rot5" "Rot6"
image_contrast=("Magn_TE1to4") # "chi_CF" "chi_LSQR"

script_dir="/mnt/c/Users/rosly/Documents/Valerie_PH"
cd "$script_dir" || exit

#dir_in="./Data/Padded/SDC"
mask_dir="./Data/Padded/SDC"
dir_out_1="./Data/Padded/N4-ITK"
dir_out_2="./Data/Padded/N4_deGibbs"

for prefix in "${data_prefix[@]}"; do

    mask="${mask_dir}/${prefix}_Neutral_Mask_Use_FLIRT_crop.nii.gz"

    for acq in "${acquisition[@]}"; do

        for contrast in "${image_contrast[@]}"; do

            #if [[ "$contrast" =~ ^"Magn" ]]; then
            #    dir_use="./Data/Padded/N4-ITK"
            #else
            #    dir_use="./Data/Padded/SDC"
            #fi
            #input_img="${dir_in}/${dataset}_${contrast}.nii.gz"
            #output_img="${dir_out_1}/${dataset}_${contrast}.nii.gz"
            dataset="${prefix}_${acq}"
            #./Apply_N4.sh "${dataset}" ${dir_in} ${dir_out_1} ${mask_dir}
            input_img="${dir_out_1}/${prefix}_${acq}_${contrast}.nii.gz"
            mask="${mask_dir}/${dataset}_mask.nii.gz"
            output_img="${dir_out_2}/${prefix}_${acq}_${contrast}.nii.gz"
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
