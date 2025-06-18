#!/bin/bash
# Define data prefixes
data_prefix=("3T" "7T")                        # "3T" "7T" QUEUE: (3T_Rot2)
acquisitions=("Rot1" "Rot2")                   #  "Neutral" "Rot1" "Rot2" "Rot3" "Rot4" "Rot5" "Rot6"
image_contrast=("SNR_frequency_Echoes_5_to_7") # "QSM" "Magn_Demeaned" "Delta" "weights" "Mask_Use" "CSF_Mask" "BET_Mask" "ROIs" "Imag_Padded" "Real_Padded"
mode=("apply")                                 # "obtain" "apply"
performInverse="0"
script_dir="/mnt/c/Users/rosly/Documents/Valerie_PH"
cd "$script_dir" || exit

# Main loop (Field Strengths / Scanners)
for prefix in "${data_prefix[@]}"; do

    # Subject loop (Re-orientation within each scanner)
    for sub in "${acquisitions[@]}"; do
        dataset="${prefix}_${sub}"
        if [[ "$dataset" == "3T_Rot4" ]] || [[ "$dataset" == "7T_Neutral" ]]; then
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

                Obtain_in_dir="./Data/Padded/N4_deGibbs"
                Obtain_out_dir="./Data/Padded/FLIRT"
                weights_dir="./Analysis/SNRwAVG_PDF"
                Obtain_cmd="./ObtainMatrix.sh $prefix $sub $ref_sub $Obtain_in_dir $Obtain_out_dir $weights_dir"
                ./check_command.sh "$Obtain_cmd"
            else

                for contrast in "${image_contrast[@]}"; do

                    Reference_dir="./Data/Padded/FLIRT"
                    #Apply_in_dir="./Analysis/PDF_Opt"
                    #Apply_out_dir="./Analysis/Registered/PDF_deGibbs"
                    #Apply_in_dir="./Analysis/MEDI_pc-range"
                    #Apply_out_dir="./Analysis/Registered/MEDI_pc-range"
                    #Apply_in_dir="./Data/Padded"
                    #Apply_out_dir="./Data/Noise_Level"
                    #Apply_in_dir="./Analysis/SNRwAVG_PDF"
                    #Apply_out_dir="./Analysis/Registered/Visual"
                    #Apply_in_dir="./Analysis/Registered/COSMOS_SNRwAVG_PDF/deGibbs"
                    #Apply_out_dir="./Analysis/Morozov"
                    #Apply_in_dir="./field_to_chi"
                    #Apply_out_dir="./field_to_chi/Registered"
                    Apply_in_dir="./SNR_Phase"
                    Apply_out_dir="./SNR_Phase/Registered"

                    if [ ! -d "$Apply_out_dir" ]; then
                        echo "Directory $Apply_out_dir does not exist. Creating it now..."
                        mkdir -p "$Apply_out_dir"
                        echo "Directory $Apply_out_dir created."
                    fi

                    moving_img="${Apply_in_dir}/${dataset}_${contrast}.nii.gz"
                    flirt_img="${Apply_out_dir}/${dataset}_${contrast}_FLIRT.nii.gz"

                    if [[ "$dataset" =~ ^"3T_Neutral" ]]; then
                        cp_cmd="cp -r $moving_img $flirt_img"
                        ./check_command.sh "$cp_cmd"
                        echo "$cp_cmd"
                    else
                        apply_cmd="./ApplyMatrix.sh $prefix $sub $ref_sub $Reference_dir $Apply_in_dir $Apply_out_dir $contrast $performInverse"
                        ./check_command.sh "$apply_cmd"
                    fi

                done

            fi
        done
    done
done

exit 0
