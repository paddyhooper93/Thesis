#!/bin/bash
# Define data prefixes
data_prefix=("3T" "7T") #  "TE1to7" "TE1to3" "3T" "7T"
tp=("9mth")             # "BL" "BL_Rep" "9mth" "24mth" "24mth_Rep"
contrast=("iFreq")      # "Tik_10_Crop" "InfCyl_Crop" "internal_mask_Crop" "CSF_Mask"

# Define directories
matr_dir="./Registration/Matrices/"
ref_dir="./Registration/Ref/"
input_dir="./Analysis/internal_field_mask/"
#input_dir="./Analysis/Tik/"
#output_dir="./Analysis/Tik/rgst_SNRwAVG_MEDI0/"
output_dir="./Analysis/field_to_chi/"

dirs=("$matr_dir" "$ref_dir" "$input_dir" "$output_dir")

for dir in "${dirs[@]}"; do
    if [ -d "$dir" ]; then
        echo "Directory $dir already exists."
    else
        echo "Directory $dir does not exist. Creating it now..."
        mkdir -p "$dir"
        echo "Directory $dir created."
    fi
done

# Loop through prefix
for prefix in "${data_prefix[@]}"; do

    # Set fsname and QSM params for prefix
    case "$prefix" in
    TE1to7 | 3T)
        fsname="3T"
        ;;
    TE1to3 | 7T)
        fsname="7T"
        ;;
    *)
        echo "Prefix $prefix does not match any known patterns."
        exit 1
        ;;
    esac

    # Loop through timepoints (TP)
    for t in "${tp[@]}"; do
        # Skip if the data_prefix is "TE1to3" AND tp is "BL" or "BL_Rep"
        if { [[ "$prefix" =~ ^"TE1to" ]] && [[ "$t" =~ ^"BL" ]]; }; then # || [[ "$prefix" =~ ^"TE1to07" ]]
            echo "Skipping $prefix with $t"
            printf "\n"
            continue
        fi

        # Proceed with your command if not skipped
        echo "Running $prefix with $t"
        printf "\n"

        # Loop through QSM Parameters
        for c in "${contrast[@]}"; do

            # Define reference, input, and output image names
            ref_img="${ref_dir}${fsname}_${t%_Rep}_NLLS_Quad.nii.gz"
            moving_img="${input_dir}${prefix}_${t}_${c}.nii.gz"
            output_img="${output_dir}${prefix}_${t}_${c}_Quad.nii.gz"

            # Build transformation based on timepoint
            itk_tfm=""
            if [[ "$t" =~ "BL" ]]; then
                itk_tfm="${matr_dir}${fsname}_BLtoQuad.txt"
            elif [[ "$t" =~ "9mth" ]]; then
                if [[ "$fsname" =~ "3T" ]]; then
                    itk_tfm="${matr_dir}${fsname}_BLtoQuad.txt ${matr_dir}${fsname}_9mthtoBL.txt"
                else
                    itk_tfm="${matr_dir}${fsname}_9mthtoQuad.txt" #
                fi
            elif [[ "$t" =~ "24mth" ]]; then
                itk_tfm=" ${matr_dir}${fsname}_BLtoQuad.txt ${matr_dir}${fsname}_9mthtoBL.txt ${matr_dir}${fsname}_24mthto9mth.txt"
            fi
            #
            # (ii): Converting from ITK to FLIRT transform type (e.g., if using ITK-SNAP to generate initial transform)
            #c3d_affine_tool -ref ../Ref/7T_9mth_NLLS_Quad.nii.gz -src ../Ref/7T_9mth_Tik_10_Crop.nii.gz -itk 7T_9mthtoBL.txt -fsl2ras -o 7T_9mthtoBL.mat
            #c3d_affine_tool -ref ../Ref/7T_9mth_NLLS_Quad.nii.gz -src ../Ref/7T_9mth_Tik_10_Crop.nii.gz -itk 7T_BLtoQuad.txt -fsl2ras -o 7T_BLtoQuad.mat
            #convert_xfm -omat 7T_9mthtoQuad.mat -concat 7T_BLtoQuad.mat 7T_9mthtoBL.mat
            #convertITK="1"
            #init_tfm_2="${matr_dir}${fsname}_9mthtoQuad.mat"
            #if [[ "$convertITK" -eq 1 ]]; then
            #    init_tfm="$itk_tfm"
            #    c3d_cmd="c3d_affine_tool -ref $ref_img -src $moving_img $init_tfm -ras2fsl -o $init_tfm_2"
            #    echo "$c3d_cmd"
            #    ./check_command.sh "$c3d_cmd"
            #fi
            # Build the flirt command
            #flirt_tfm="${matr_dir}${fsname}_9mthtoQuad_FLIRT.mat"
            #flirt -v -dof 6 \
            #    -cost normcorr -interp spline \
            #    -in "$moving_img" -ref "$ref_img" \
            #    -init "$init_tfm_2" \
            #    -out "$output_img" -omat "$flirt_tfm"
            #./check_command.sh "$flirt_cmd"
            # Build the ANTS command
            shopt -s nocasematch
            if [[ "$c" == *"mask"* ]]; then
                interpMethod="NearestNeighbor"
            else
                interpMethod="BSpline"
            fi
            shopt -u nocasematch
            command1="antsApplyTransforms -d 3 -e scalar -r $ref_img -i $moving_img -o $output_img -n $interpMethod -t $itk_tfm -v 1"
            # command2="fslcpgeom $ref_img $output_img -d"

            # Print and run
            eval "$command1"
            #eval "$command2"
            # echo "$command2"
            printf "\n"
        done
    done
done
exit 0
# End of script
