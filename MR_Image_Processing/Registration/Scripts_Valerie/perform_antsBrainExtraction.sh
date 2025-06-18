#!/bin/bash

# Function to perform template-based brain extraction
# Usage: perform_antsBrainExtraction.sh moving_img ref_img ref_mask output_img

moving_img="$1"
ref_img="$2"
ref_mask="$3"
moving_extracted="$4"

#moving_extracted="${input_dir}/${prefix}_${sub}_Magn_TemplateExtracted.nii.gz"

antsBrainExtraction.sh -d 3 \
    -a "${moving_img}" \
    -e "${ref_img}" \
    -m "${ref_mask}" \
    -o "${moving_extracted}"
