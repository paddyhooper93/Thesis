#!/bin/bash
# Define data prefixes
data_prefix=("3T" "7T")             #"3T" "7T"
acquisitions=("Rot1" "Rot3" "Rot5") #"Rot1" "Rot3" "Rot5"

# Define directories
script_dir="/mnt/c/Users/rosly/Documents/Valerie_PH"
cd "$script_dir" || exit

input_dir="./Data/MatrixSizeCorrect"
tmp_dir="./Analysis/COSMOS_Prep/MI_2/tmp"
output_dir="./Analysis/COSMOS_Prep/MI_2/ANTS_Use"
matrix_dir="./Analysis/COSMOS_Prep/MI_2/Matrices"

dirs=("$matrix_dir" "$input_dir" "$output_dir" "$tmp_dir")

for dir in "${dirs[@]}"; do
    if [ ! -d "$dir" ]; then
        echo "Directory $dir does not exist. Creating it now..."
        mkdir -p "$dir"
        echo "Directory $dir created."
    fi
done

if ls "$tmp_dir"/*.nii.gz 1>/dev/null 2>&1; then
    echo "Clearing NIfTI files within temp directory: $tmp_dir"
    rm -f "$tmp_dir"/*.nii.gz
fi

# Function to check command success
check_error() {
    if [[ $? -ne 0 ]]; then
        echo "Error: $1"
        exit 1
    fi
}

# Loop through prefix
for prefix in "${data_prefix[@]}"; do

    # Loop through acquisitions (sub)
    for sub in "${acquisitions[@]}"; do

        # Set ref_prefix for each field strength
        case "$prefix" in
        3T)
            ref_prefix="Rot5"
            ;;
        7T)
            ref_prefix="Rot1"
            ;;
        *)
            echo "Prefix $prefix does not match any known patterns."
            exit 1
            ;;
        esac

        # Skip antsRegistration
        if [[ "$sub" =~ ^"${ref_prefix}" ]]; then
            echo "Skipping reference frame: ${prefix}_${sub}"
            printf "\n"
            continue
        fi

        # Proceed with your command if not skipped
        echo "Running $prefix with $sub"
        printf "\n"

        # Define inputs
        ref_input="${input_dir}/${prefix}_${ref_prefix}_Magn_Use.nii.gz"
        moving_input="${input_dir}/${prefix}_${sub}_Magn_Use.nii.gz"

        # (i): Obtain first echo magnitude images and copy header.
        ref_img="${tmp_dir}/${prefix}_${ref_prefix}_Magn_Ech1.nii.gz"
        moving_img="${tmp_dir}/${prefix}_${sub}_Magn_Ech1.nii.gz"
        fslroi "${ref_input}" "${ref_img}" 0 1
        fslroi "${moving_input}" "${moving_img}" 0 1
        check_error "fslroi failed ..."
        fslcpgeom "${ref_img}" "${moving_img}" -d
        check_error "fslcpgeom failed ..."

        # (ii) Initial translation
        # Define FLIRT outputs
        flirt_img="${output_dir}/${prefix}_${ref_prefix}_to_${sub}_FLIRT.nii.gz"
        flirt_tfm="${matrix_dir}/${prefix}_${ref_prefix}_to_${sub}_FLIRT.mat"
        flirt -v -interp spline -in "$moving_img" -ref "$ref_img" -out "$flirt_img" -omat "${flirt_tfm}"

        # (iii) Convert FSL transformation matrix into ITK format
        flirt_ITK_tfm="${matrix_dir}/${prefix}_${ref_prefix}_to_${sub}_FLIRT_ITK.mat"
        c3d_affine_tool.exe "$flirt_tfm" -ref "$ref_img" -src "$moving_img" -fsl2ras -oitk "$flirt_ITK_tfm"

        #antsRegistration -d 3 -r [ fixed.nii.gz , moving.nii.gz , 1] -t Rigid[0.1] \
        #-m MI[ fixed.nii.gz, moving.nii.gz, 1, 32] -c 0 -f 4 -s 2 \
        #-o [movingInit, movingInit_deformed.nii.gz]

        # Define antsRegistration outputs
        ants_img="${output_dir}/${prefix}_${ref_prefix}_to_${sub}_ANTS.nii.gz"
        ants_tfm="${matrix_dir}/${prefix}_${ref_prefix}_to_${sub}_"

        antsRegistration -d 3 -v \
            -o ["$ants_tfm", "$ants_img"] \
            -n BSpline \
            -r ["$flirt_ITK_tfm"] \
            -u 0 \
            -w [0.005, 0.995] \
            -t Rigid[0.1] \
            -m MI["${ref_img}","${moving_img}",1,32,Regular,0.25] \
            -c [1000x500x250x100, 1e-6,10] \
            -f 8x4x2x1 \
            -s 3x2x1x0vox
        check_error "antsRegistration failed ..."

        # (v) For later use, move the reference image to output directory.
        ref_output="${output_dir}/${prefix}_${ref_prefix}.nii.gz"
        mv "$ref_img" "$ref_output"
        echo "Moved $ref_img to $ref_output"

        # (vi) Clear temp
        echo "Clearing NIfTI files within temp directory: $tmp_dir"
        rm -f "$tmp_dir"/*.nii.gz

        # CC_Metric:
        # -m CC["${ref_img}","${moving_img}",1,4] \
        # -c [100x70x50x20,1e-6,10] \
        # --float = 16-bit rather than double (64-bit)

        # MI metric:
        # -m MI["${ref_img}","${moving_img}",1,32,Regular,0.25]
        # -c [1000x500x250x100, 1e-6, 10] \
        # -u = histogram matching flag
        # -z = Collapse output transforms.

    done
done

# (vii) Remove temp
echo "Removing temp directory: $tmp_dir"
rm -rf $tmp_dir
exit 0
