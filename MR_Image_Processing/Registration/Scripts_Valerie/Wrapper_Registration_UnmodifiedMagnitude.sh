#!/bin/bash
# Define data prefixes
data_prefix=("7T")       # "3T" "7T" QUEUE: (3T_Rot3)
acquisitions=("Neutral") #  "Neutral" "Rot1" "Rot2" "Rot3" "Rot4" "Rot5" "Rot6"
contrast="mask"          # "iMag" "Magn_Demeaned" "Delta" "weights" "Mask_Use" "CSF_Mask" "BET_Mask" "ROIs" "Imag_Padded" "Real_Padded"
mode=("apply")           # "obtain" "apply"

script_dir="/mnt/c/Users/rosly/Documents/Valerie_PH"
cd "$script_dir" || exit

# Main loop (Field Strengths / Scanners)
for prefix in "${data_prefix[@]}"; do

    # Subject loop (Re-orientation within each scanner)
    for sub in "${acquisitions[@]}"; do
        dataset="${prefix}_${sub}"
        if [[ "$dataset" == "3T_Rot4" ]] || [[ "$dataset" == "7T_Rot6" ]]; then
            echo "Skipping dataset: ${dataset}"
            printf "\n"
            continue
        fi
        echo "Running $dataset ..."

        # Define orientation used as reference frame for B0 vector := [0 0 1]'
        ref_sub="Neutral"

        # Mode loop (Obtain then Apply)
        for m in "${mode[@]}"; do
            if [[ "$m" =~ ^"obtain" ]]; then

                Obtain_in_dir="./Data/Padded/N4-ITK"
                Obtain_out_dir="./Data/Padded/FLIRT"
                weights_dir="./Analysis/PDF_Opt"
                Obtain_cmd="./ObtainMatrix.sh $prefix $sub $ref_sub $Obtain_in_dir $Obtain_out_dir $weights_dir"
                ./check_command.sh "$Obtain_cmd"
            else
                Reference_dir="./Data/Padded/FLIRT"
                #Apply_in_dir="./Analysis/PDF_Opt"
                Apply_in_dir="./Data/Padded/SDC"
                Apply_out_dir="${Apply_in_dir}"
                #Apply_out_dir="./Data/Noise_Level"
                #Neutral_dir="./Analysis/Registered/Neutral"

                moving_img="${Apply_in_dir}/${dataset}_${contrast}.nii.gz"
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
                    if
                        [[ "$contrast" =~ ^"mask" ]] ||
                            [[ "$contrast" =~ ^"BET_Mask" ]] ||
                            [[ "$contrast" =~ ^"CSF_Mask" ]] ||
                            [[ "$contrast" =~ ^"ROIs" ]] ||
                            [[ "$contrast" =~ ^"Corners_Segmentation" ]]
                    then
                        interp="NearestNeighbor"
                    else
                        interp="BSpline" # "LanczosWindowedSinc" "BSpline"
                        #interp="Linear"
                    fi

                    echo "Interpolation: ${interp} ..."
                    echo "Input image type: ${type} ..."

                    # antsApplyTransform requires consistent header information.
                    fslcpgeom "$ref_img" "$moving_img" -d

                    ants_tfm="${tfm}.txt"
                    ants_cmd="antsApplyTransforms -i ${moving_img} -r ${ref_img} -o ${flirt_img} -n ${interp} -t ${ants_tfm} -e ${type} -v --float"
                    ./check_command.sh "$ants_cmd"

                else

                    ref_img="${Reference_dir}/${prefix}_${ref_sub}_TMedian.nii.gz"
                    flirt_tfm="${Reference_dir}/${prefix}_${ref_sub}_to_${sub}_FLIRT.mat"
                    flirt_img="${Apply_out_dir}/${prefix}_${ref_sub}_to_${sub}_${contrast}_FLIRT.nii.gz"
                    interp="sinc"
                    flirt_cmd="flirt -v -interp $interp -sincwindow blackman -in $moving_img -ref $ref_img -out $flirt_img -init $flirt_tfm -applyxfm -datatype double"
                    echo "$flirt_cmd"
                    ./check_command.sh "$flirt_cmd"
                fi
            fi
        done
    done
done

exit 0
