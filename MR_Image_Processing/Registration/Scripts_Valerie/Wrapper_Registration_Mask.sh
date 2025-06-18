#!/bin/bash
# Define data prefixes
data_prefix=("3T")    # "3T" "7T" QUEUE: (3T_Rot2)
acquisitions=("Rot4") #  "Neutral" "Rot1" "Rot2" "Rot3" "Rot4" "Rot5" "Rot6"
contrast="CSF_Mask"   # "Mask_Use" "CSF_Mask" "Bet_Mask_Erode" qualityMask
performInverse="1"

script_dir="/mnt/c/Users/rosly/Documents/Valerie_PH"
cd "$script_dir" || exit

# Main loop (Field Strengths / Scanners)
for prefix in "${data_prefix[@]}"; do

    # Subject loop (Re-orientation within each scanner)
    for sub in "${acquisitions[@]}"; do
        dataset="${prefix}_${sub}"
        if [[ "$dataset" == "3T_Rot4" ]]; then
            echo "Skipping dataset: ${dataset}"
            printf "\n"
            continue
        fi
        echo "Running $dataset ..."

        # Define orientation used as reference frame for B0 vector := [0 0 1]'
        ref_sub="Neutral"

        Reference_dir="./Data/Padded/FLIRT"
        #Apply_in_dir="./Analysis/MEDI_Opt"
        #Apply_in_dir="./Analysis/SNRwAVG_PDF"
        #Apply_in_dir="./Analysis/Registered/Brain_ROI_Mask"
        Apply_in_dir="./Analysis/Registered/CSF_Mask"
        Apply_out_dir="./Analysis/Registered/CSF_Mask"
        #Apply_out_dir="./Analysis/Registered/Brain_ROI_Mask"
        #Apply_in_dir="./Data/Padded"
        #Apply_out_dir="./Data/Noise_Level"
        # Neutral_dir="./Analysis/Registered/Neutral"

        if [ ! -d "$Apply_out_dir" ]; then
            echo "Directory $Apply_out_dir does not exist. Creating it now..."
            mkdir -p "$Apply_out_dir"
            echo "Directory $Apply_out_dir created."
        fi

        moving_img="${Apply_in_dir}/${dataset}_${contrast}.nii.gz"
        #moving_img="$degibbs_img"
        flirt_img="${Apply_out_dir}/${dataset}_${contrast}_FLIRT.nii.gz"

        if [[ "$dataset" =~ ^"3T_Neutral" ]]; then
            cp_cmd="cp -r $moving_img $flirt_img"
            ./check_command.sh "$cp_cmd"
            echo "$cp_cmd"
        elif [[ "$dataset" =~ ^"7T_Neutral" ]]; then
            # Correction required for 7T_Neutral due to resampling from 0.68 to 0.75 mm iso
            echo "Correcting registration for 7T_Neutral due to earlier resampling (i.e., 0.68 to 0.75) ..."
            printf "\n"
            ref_img="${Reference_dir}/7T_Neutral_TMedian.nii.gz"
            tfm="${Reference_dir}/7T_Neutral_FermiFilt_to_N4_Correct" #
            # complex linear interp prior to arctangent of real&imag into a phase image.
            if [[ "$contrast" =~ ^"Imag_Padded" ]] || [[ "$contrast" =~ ^"Real_Padded" ]]; then
                type="3" # time-series (for case dims = 4)
                interp="Linear"
            else
                type="0" # scalar (for case dims = 3)
            fi
            # Nearest neighbour interp for binary mask or integer ROIs
            # BSpline for everything else.
            ants_tfm="${tfm}.txt"

            #if [[ "$performInverse" -eq 1 ]]; then
            #    tfm="${Reference_dir}/7T_Neutral_FermiFilt_to_N4_Correct_INV.mat"
            #    inv_fn="Linear[$tfm, 1]"
            #    ants_cmd="antsApplyTransforms -i ${moving_img} -r ${ref_img} -o ${inv_fn} -n ${interp} -t ${ants_tfm} -e ${type} -v --float"
            #else
            #    tfm="$ants_tfm"
            #fi
            shopt -s nocasematch
            if
                [[ "$contrast" == *"mask"* ]]
            then
                interp="NearestNeighbor"
            else
                interp="LanczosWindowedSinc" # "LanczosWindowedSinc" "BSpline"
            fi
            shopt -u nocasematch
            echo "Interpolation: ${interp} ..."
            echo "Input image type: ${type} ..."

            # antsApplyTransform requires consistent header information.
            fslcpgeom "$ref_img" "$moving_img" -d

            ants_cmd="antsApplyTransforms -i ${moving_img} -r ${ref_img} -o ${flirt_img} -n ${interp} -t ${ants_tfm,$performInverse} -e ${type} -v --float"
            ./check_command.sh "$ants_cmd"

        else
            apply_cmd="./ApplyMatrix.sh $prefix $sub $ref_sub $Reference_dir $Apply_in_dir $Apply_out_dir $contrast $performInverse"
            ./check_command.sh "$apply_cmd"
        fi
    done
done

exit 0
