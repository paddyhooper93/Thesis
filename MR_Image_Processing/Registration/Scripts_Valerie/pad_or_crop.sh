#!/bin/bash

# Function to pad or crop an image based on the dataset
# Usage: pad_or_crop.sh input_image dataset output_image dim

input_image="$1"
dataset="$2"
output_image="$3"
dim="$4"

# Initialize padding sizes for x, y, and z directions
pad_x=0
pad_y=0
pad_z=0

if [[ $dataset == *"7T"* ]]; then
    if [[ $dataset == *"Rot4"* || $dataset == *"Rot5"* ]]; then
        # Pad 32 voxels in Z (both sides)
        pad_z=32
    fi
elif [[ $dataset == *"3T"* ]]; then
    # Step 1: Crop or pad in X
    if [[ $dataset == *"Rot1"* || $dataset == *"Rot2"* ]]; then
        # Crop 30 voxels in X (both sides, equivalent to -15 padding)
        pad_x=-15
    else
        # Pad 15 voxels in X (both sides)
        pad_x=15
    fi

    # Step 2: Pad in Z
    if [[ $dataset == *"Neutral"* ]]; then
        # Pad 36 voxels in Z (both sides)
        pad_z=36
    elif [[ $dataset == *"Rot4"* ]]; then
        # Pad 24 voxels in Z (both sides)
        pad_z=24
    else
        # Pad 16 voxels in Z (both sides)
        pad_z=16
    fi
fi

# Combine padding into a single padding size string
padding_size="${pad_x}x${pad_y}x${pad_z}"

# Apply the PadImage operation using ImageMath
ImageMath "$dim" "$output_image" PadImage "$input_image" "$padding_size"
