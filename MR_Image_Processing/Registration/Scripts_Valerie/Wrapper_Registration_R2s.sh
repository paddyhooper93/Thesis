#!/bin/bash
# Define data prefixes
data_prefix=("3T")                                                 # "3T" "7T"
acquisitions=("Neutral" "Rot1" "Rot2" "Rot3" "Rot4" "Rot5" "Rot6") #  "Neutral" "Rot1" "Rot2" "Rot3" "Rot4" "Rot5" "Rot6"
image_contrast=("R2s")                                             # "R2s"
mode=("apply")                                                     # "obtain" "apply"

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

                if [[ "$sub" == "$ref_sub" ]]; then
                    ref_img="${Obtain_in_dir}/${prefix}_${ref_sub}_iMag.nii.gz"
                    #degibbs_img="${Obtain_in_dir}/${prefix}_${sub}_iMag_Degibbs.nii.gz"

                    #/opt/mrtrix3/mrdegibbs3D/bin/deGibbs3D -info \
                    #    -force \
                    #    -nthreads 8 \
                    #    "$ref_img" \
                    #    "$degibbs_img"
                    continue
                fi

                Obtain_out_dir="./Data/Padded/FLIRT"
                weights_dir="./Analysis/PDF_Opt"
                Obtain_cmd="./ObtainMatrix.sh $prefix $sub $ref_sub $Obtain_in_dir $Obtain_out_dir $weights_dir"
                ./check_command.sh "$Obtain_cmd"
            else

                for contrast in "${image_contrast[@]}"; do

                    Reference_dir="./Data/Padded/FLIRT"
                    Apply_in_dir="./Data/Padded/R2s"
                    Apply_out_dir="./Analysis/Registered/R2s"

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
                    elif [[ "$dataset" =~ ^"7T_Neutral" ]]; then
                        # Correction required for 7T_Neutral due to resampling from 0.68 to 0.75 mm iso
                        echo "Correcting registration for 7T_Neutral due to earlier resampling (i.e., 0.68 to 0.75) ..."
                        printf "\n"
                        ref_img="${Reference_dir}/7T_Neutral_TMedian.nii.gz"
                        tfm="${Reference_dir}/7T_Neutral_FermiFilt_to_N4_Correct"
                        type="0" # scalar (for case dims = 3)
                        interp="LanczosWindowedSinc"
                        # antsApplyTransform requires consistent header information.
                        fslcpgeom "$ref_img" "$moving_img" -d
                        ants_tfm="${tfm}.txt"
                        ants_cmd="antsApplyTransforms -i ${moving_img} -r ${ref_img} -o ${flirt_img} -n ${interp} -t ${ants_tfm} -e ${type} -v --float"
                        ./check_command.sh "$ants_cmd"

                    else
                        apply_cmd="./ApplyMatrix.sh $prefix $sub $ref_sub $Reference_dir $Apply_in_dir $Apply_out_dir $contrast"
                        ./check_command.sh "$apply_cmd"
                    fi

                done

            fi
        done
    done
done

exit 0
