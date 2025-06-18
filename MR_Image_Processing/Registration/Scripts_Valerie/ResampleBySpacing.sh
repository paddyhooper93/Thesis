#!/bin/bash

# Ensure the script stops on errors
set -e

# Initialize folders
INPUT_FOLDER="./Data/SDC/"
REFERENCE_FOLDER="./Data/NC/"
OUTPUT_FOLDER="./Data/Resample-By-Spacing/"

# Create folders if they don't exist
mkdir -p $INPUT_FOLDER
mkdir -p $OUTPUT_FOLDER

# Input files
prefix="7T_Neutral"
PHASE_IMAGE="$INPUT_FOLDER${prefix}_Phs_SDC.nii.gz"
MAGNITUDE_IMAGE="$INPUT_FOLDER${prefix}_Magn_SDC.nii.gz"
REFERENCE_IMAGE="${REFERENCE_FOLDER}7T_Rot1_Magn.nii.gz"

# Intermediate and Output files
PHASE_IMAGE_ZEROPADDED="$OUTPUT_FOLDER${prefix}_Phs_SDC_zeropadded.nii.gz"
MAGNITUDE_IMAGE_ZEROPADDED="$OUTPUT_FOLDER${prefix}_Magn_SDC_zeropadded.nii.gz"
COS_PHASE="$OUTPUT_FOLDER${prefix}_cos_phase.nii.gz"
SIN_PHASE="$OUTPUT_FOLDER${prefix}_sin_phase.nii.gz"
REAL_IMAGE="$OUTPUT_FOLDER${prefix}_real_part.nii.gz"
IMAG_IMAGE="$OUTPUT_FOLDER${prefix}_imag_part.nii.gz"
REAL_RESAMPLED="$OUTPUT_FOLDER${prefix}_real_resampled.nii.gz"
IMAG_RESAMPLED="$OUTPUT_FOLDER${prefix}_imag_resampled.nii.gz"
SUM_SQR="$OUTPUT_FOLDER${prefix}_sum_squared.nii.gz"
PHASE_RESAMPLED="$OUTPUT_FOLDER${prefix}_Phs_resampled.nii.gz"
MAGNITUDE_RESAMPLED="$OUTPUT_FOLDER${prefix}_Magn_resampled.nii.gz"

# Target resolution
# INITIAL_RES="0.68 0.68 0.68"
# TARGET_RES="0.75 0.75 0.75"

# Step 1: Check if input files exist, correct header information, and zero padding.
if [[ ! -f $PHASE_IMAGE || ! -f $MAGNITUDE_IMAGE ]]; then
    echo "Error: Input files not found. Please check your paths."
    exit 1
fi

# Correct pixDim in header for input images.
# fslchpixdim $MAGNITUDE_IMAGE "$INITIAL_RES"
# fslcpgeom $MAGNITUDE_IMAGE $PHASE_IMAGE

# Correct pixDim in header for reference image.
# fslchpixdim $REFERENCE_MAGN "$TARGET_RES"

# Zero pad input images along the z-dimension
Z_PAD_SIZE=32
fslmaths $PHASE_IMAGE -add 0 -pad0 0 0 $Z_PAD_SIZE $PHASE_IMAGE_ZEROPADDED
fslmaths $MAGNITUDE_IMAGE -add 0 -pad0 0 0 $Z_PAD_SIZE $MAGNITUDE_IMAGE_ZEROPADDED

# Step 2: Convert from image space to complex space
# Euler's equation (polar form): Cplx = Magnitude * ( cos(Phase) + i * sin(Phase) )
# Therefore: Real = Magnitude * cos(Phase); Imaginary = Magnitude * sin(Phase)
fslmaths $PHASE_IMAGE -cos $COS_PHASE
fslmaths $PHASE_IMAGE -sin $SIN_PHASE
fslmaths $MAGNITUDE_IMAGE -mul $COS_PHASE $REAL_IMAGE
fslmaths $MAGNITUDE_IMAGE -mul $SIN_PHASE $IMAG_IMAGE

# Step 3: Resample Phase and Magnitude Images using ANTs
antsApplyTransforms -d 3 \
    -i $REAL_IMAGE \
    -r $REFERENCE_IMAGE \
    -o $REAL_RESAMPLED \
    -e time-series \
    -n Linear \
    --verbose

antsApplyTransforms -d 3 \
    -i $IMAG_IMAGE \
    -r $REFERENCE_IMAGE \
    -o $IMAG_RESAMPLED \
    -e time-series \
    -n Linear \
    --verbose

# Step 4: Convert resampled images from complex space to real space
# Equation: Magnitude = sqrt(Real^2 + Imag^2), Phase = atan2(Imag, Real)
fslmaths $REAL_RESAMPLED -sqr -add $IMAG_RESAMPLED -sqr $SUM_SQR
fslmaths $REAL_RESAMPLED -sqrt $SUM_SQR $MAGNITUDE_RESAMPLED
fslmaths $IMAG_RESAMPLED -atan2 $REAL_RESAMPLED $PHASE_RESAMPLED

# Print completion message
echo "Resampling completed. Outputs saved as:"
echo "  - $MAGNITUDE_RESAMPLED (resampled magnitude)"
echo "  - $PHASE_RESAMPLED (resampled phase)"
