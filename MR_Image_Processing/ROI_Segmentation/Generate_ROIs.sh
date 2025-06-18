#!/bin/bash

script_dir="/mnt/c/Users/rosly/Documents/Valerie_PH"
cd "$script_dir" || exit
echo "Running ./Generate_ROIs.sh"

datasets=("7T_Neutral") # "3T_Rot5" "7T_Rot1"
QSM_dir="./Analysis/FermiFilt"
CSF_dir="./Analysis/CSF_Mask"
BET_dir="./Data/Padded/FermiFilt_SDC"
R2s_dir="./Data/Padded/R2s"
output_dir="./ROIs"
tmp_dir="./ROIs/tmp"

if [ ! -d "$tmp_dir" ]; then
    echo "Directory $tmp_dir does not exist. Creating it now..."
    mkdir -p "$tmp_dir"
    echo "Directory $tmp_dir created."
fi

#if ls "$tmp_dir"/*.nii.gz 1>/dev/null 2>&1; then
#    echo "Clearing NIfTI files within temp directory: $tmp_dir"
#    rm -f "$tmp_dir"/*.nii.gz
#fi

for prefix in "${datasets[@]}"; do

    # Case: Parameters given in vox
    case "$prefix" in
    3T_Neutral)
        BET_erode_radius="10"
        CSF_erode_radius="3"
        CSF_open_radius="3"
        res="1"
        ;;
    7T_Neutral)
        BET_erode_radius="13"
        CSF_erode_radius="4"
        CSF_open_radius="4"
        res="0.75"
        ;;
    *)
        echo "$prefix does not match pattern"
        exit 1
        ;;
    esac

    # Parameters given in mm
    minextent_straws="200"
    minextent_ellipsoids="3000"

    # Step 0: Invert the CSF mask
    CSF_Mask="$CSF_dir/${prefix}_CSF_Mask.nii.gz"
    CSF_Mask_Inv="$tmp_dir/${prefix}_CSF_Mask_Inv.nii.gz"
    fslmaths "$CSF_Mask" -binv "$CSF_Mask_Inv"

    # Multiply by QSM_Mask and eroded BET Mask
    QSM_Mask="$QSM_dir/${prefix}_Mask_Use.nii.gz"
    BET_Mask="$BET_dir/${prefix}_mask.nii.gz"
    BET_Mask_Erode="$tmp_dir/${prefix}_BET_Mask_Erode.nii.gz"
    ImageMath 3 "$BET_Mask_Erode" ME "$BET_Mask" "$BET_erode_radius"
    CSF_Mask_Inv_Mul="$tmp_dir/${prefix}_CSF_Mask_Inv_Mul.nii.gz"
    fslmaths "$QSM_Mask" -mul "$CSF_Mask_Inv" "$CSF_Mask_Inv_Mul"
    fslmaths "$CSF_Mask_Inv_Mul" -mul "$BET_Mask_Erode" "$CSF_Mask_Inv_Mul"

    # Morphological erosion
    CSF_Mask_Inv_Mul_ME="$tmp_dir/${prefix}_CSF_Mask_Inv_ME.nii.gz"
    ImageMath 3 "$CSF_Mask_Inv_Mul_ME" ME "$CSF_Mask_Inv_Mul" "$CSF_erode_radius"

    # Morphological opening
    CSF_Mask_Inv_Mul_ME_MO="$tmp_dir/${prefix}_CSF_Mask_Inv_ME_Mul_MO.nii.gz"
    ImageMath 3 "$CSF_Mask_Inv_Mul_ME_MO" MO "$CSF_Mask_Inv_Mul_ME" "$CSF_open_radius"

    Segmentation_Input_1="$tmp_dir/${prefix}_Segmentation_Input_1.nii.gz"
    fslmaths "$CSF_Mask_Inv_Mul_ME_MO" -mul "$BET_Mask_Erode" "$Segmentation_Input_1"

    Segmentation_1="$tmp_dir/${prefix}_Segmentation_1.nii.gz"
    cluster -i "$Segmentation_Input_1" -t 0.5 -o "$Segmentation_1" --minextent=$minextent_ellipsoids --connectivity=6 --mm -r "$res"
    fslmaths "$Segmentation_1" -mas "$QSM_Mask" "$Segmentation_1"

    # Step 2: Segment the straws by thresholding (5% < R2s < 95% of robust range) then clustering R2s
    R2s="$R2s_dir/${prefix}_R2s_Padded.nii.gz"
    #R2s_lthresh="$tmp_dir/${prefix}_R2s_lthres.nii.gz"
    #R2s_lthresh_uthresh="$tmp_dir/${prefix}_R2s_lthres_uthres.nii.gz"
    #fslmaths "$R2s" -thrp 5 "$R2s_lthresh"
    #fslmaths "$R2s_lthresh" -uthrp 95 "$R2s_lthresh_uthresh"
    #fslmaths "$R2s_lthresh_uthresh" -mul "$QSM_Mask" "$R2s_lthresh_uthresh"
    # Modification to 7 T only: Change MO from 1 to 2
    #R2s_mask="$tmp_dir/${prefix}_R2s_mask.nii.gz"
    #R2s_mask_MO="$tmp_dir/${prefix}_R2s_mask_Open.nii.gz"
    #ImageMath 3 "$R2s_mask_MO" MO "$R2s_mask" 2
    #Segmentation_Input_2="$tmp_dir/${prefix}_Segmentation_Input_2.nii.gz"
    #fslmaths "$R2s_mask" -mul "$BET_Mask_Erode" "$Segmentation_Input_2"
    Segmentation_2="$tmp_dir/${prefix}_Segmentation_2.nii.gz"
    cluster -i "$R2s" -t 5 --fractional -o "$Segmentation_2" --minextent=$minextent_straws --connectivity=6 --mm -r "$res"
    fslmaths "$Segmentation_2" -mas "$QSM_Mask" "$Segmentation_2"

    # Step 3: Segment by clustering the QSM map at robust range
    QSM_map="$QSM_dir/${prefix}_QSM.nii.gz"
    #QSM_map_R2s="$tmp_dir/${prefix}_QSM_R2s-Masked.nii.gz"
    #fslmaths "$QSM_map" -mul "$R2s_mask" "$QSM_map_R2s"
    Segmentation_3="$tmp_dir/${prefix}_segmentation_3.nii.gz"
    cluster -i "$QSM_map" -t 5 --fractional -o "$Segmentation_3" --minextent=$minextent_straws --connectivity=6 --mm -r "$res"

    Segmentation_4="$tmp_dir/${prefix}_segmentation_4.nii.gz"
    cluster -i "$QSM_map" -t 5 --fractional -o "$Segmentation_4" --minextent=$minextent_ellipsoids --connectivity=6 --mm -r "$res"

    # Step 4: Combine segmentations into ROI file
    ROIs="$output_dir/${prefix}_ROIs.nii.gz"
    # label 1 in seg 3: set to 5
    #ImageMath 3 "$Segmentation_3" ReplaceVoxelValue "$Segmentation_3" 0.5 1.5 5

    case "$prefix" in
    3T_Neutral)
        #fslmaths "$Segmentation_2" -uthr 1.5 "$Segmentation_2"
        # label 1 in seg 2: set to 6
        ImageMath 3 "$Segmentation_3" ReplaceVoxelValue "$Segmentation_3" 0.5 1.5 5
        ImageMath 3 "$Segmentation_3" ReplaceVoxelValue "$Segmentation_3" 1.5 2.5 6
        fslmaths "$Segmentation_3" -add "$Segmentation_1" "$ROIs"
        #fslmaths "$ROIs" -add "$Segmentation_2" "$ROIs"
        ;;
    7T_Neutral)
        # label 2 in seg 0: set to 6
        #ImageMath 3 "$Segmentation_3" ReplaceVoxelValue "$Segmentation_3" 1.5 2.5 6
        #fslmaths "$Segmentation_3" -add "$Segmentation_1" "$ROIs"
        ;;
    *)
        echo "$prefix does not match pattern"
        exit 1
        ;;
    esac

    #echo "Clearing NIfTI files within temp directory: $tmp_dir"
    #rm -f "$tmp_dir"/*.nii.gz

done

# Remove temp
#echo "Removing temp directory: $tmp_dir"
#rm -rf $tmp_dir

exit 0
