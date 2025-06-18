#!/bin/bash
# Define data prefixes
data_prefix=("3T")
tp=("24mth" "24mth_Rep")

# Define directories
matr_dir="./Matrices/"
ref_dir="./Ref/"
input_dir="../Data/NC/tmp/"
output_dir="../Data/Quad-AfterCplx/tmp/"

# Validate each directory
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

    # Set fsname and params for prefix
    if [[ "$prefix" == "3T" || "$prefix" == "TE1to7" ]]; then
        fsname="3T"
        params=("Imag" "Real")
    elif [[ "$prefix" == "7T" || "$prefix" == "TE1to3" ]]; then
        fsname="7T"
        params=("ImagSDC" "RealSDC")
    else
        echo "Prefix $prefix does not match any known patterns."
        exit 1
    fi

    # Loop through timepoints (TP)
    for t in "${tp[@]}"; do
        # Skip if the data_prefix is "TE1to7" or "TE1to3" AND tp is "BL" or "BL_Rep"
        if { [[ "$prefix" =~ ^"TE1to7"|^"TE1to3" ]] && [[ "$t" =~ ^"BL" ]]; }; then
            echo "Skipping $prefix with $t"
            printf "\n"
            continue
        fi

        # Proceed with your command if not skipped
        echo "Running $prefix with $t"
        printf "\n"

        # Loop through QSM Parameters
        for qsm in "${params[@]}"; do

            # Define reference, input, and output image names
            ref_img="${ref_dir}${fsname}_${t%_Rep}_NLLS_Quad.nii.gz"
            input_img="${input_dir}${prefix}_${t}_${qsm}.nii.gz"
            output_img="${output_dir}${prefix}_${t}_${qsm}_Quad.nii.gz"

            # Build transformation based on timepoint
            transform_file=""
            if [[ "$t" =~ "BL" ]]; then
                transform_file="${matr_dir}${fsname}_BLtoQuad.txt"
            elif [[ "$t" =~ "9mth" || "$t" =~ "24mthto9mth" ]]; then
                transform_file=" ${matr_dir}${fsname}_BLtoQuad.txt ${matr_dir}${fsname}_9mthtoBL.txt" # Put first transform last and last transform first
            elif [[ "$t" =~ "24mth" ]]; then
                transform_file=" ${matr_dir}${fsname}_BLtoQuad.txt ${matr_dir}${fsname}_9mthtoBL.txt ${matr_dir}${fsname}_24mthto9mth.txt"
            fi

            # Build the antsApplyTransforms command
            # command1="fslcpgeom $ref_img $input_img -d"
            command2="antsApplyTransforms -d 3 -e time-series -r $ref_img -i $input_img -o $output_img -n Linear -t $transform_file -v 1"

            # Print and run
            # eval "$command1"
            # echo "$command1"
            eval "$command2"
            printf "\n"
        done
    done
done
exit 0
# End of script
