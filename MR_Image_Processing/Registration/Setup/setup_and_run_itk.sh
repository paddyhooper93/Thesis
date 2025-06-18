#!/bin/bash

# Step 1: Update and Install Dependencies
echo "Updating system and installing dependencies..."
sudo apt update && sudo apt upgrade -y
sudo apt install -y python3 python3-pip python3-venv

# Step 2: Create a Python Virtual Environment
echo "Setting up Python virtual environment..."
python3 -m venv itk_env
source itk_env/bin/activate

# Step 3: Install ITK
echo "Installing ITK Python package..."
pip install --upgrade pip
pip install itk numpy

# Step 4: Create the Complex Smoothing Script
echo "Writing the Python smoothing script..."
cat <<EOL >complex_smoothing.py
import itk
import numpy as np

# Example: Create synthetic complex-valued data
image_shape = (100, 100)  # Example dimensions
real_part = np.random.rand(*image_shape)  # Simulated real part
imaginary_part = np.random.rand(*image_shape)  # Simulated imaginary part

# Convert NumPy arrays to ITK images
real_image = itk.image_view_from_array(real_part.astype(np.float32))
imaginary_image = itk.image_view_from_array(imaginary_part.astype(np.float32))

# Define smoothing parameters (e.g., Gaussian smoothing)
smoothing_filter = itk.SmoothingRecursiveGaussianImageFilter.New()
smoothing_filter.SetSigma(1.0)  # Gaussian kernel standard deviation

# Smooth the real part
smoothing_filter.SetInput(real_image)
smoothed_real_image = smoothing_filter.Update()

# Smooth the imaginary part
smoothing_filter.SetInput(imaginary_image)
smoothed_imaginary_image = smoothing_filter.Update()

# Convert smoothed ITK images back to NumPy arrays
smoothed_real = itk.array_view_from_image(smoothed_real_image)
smoothed_imaginary = itk.array_view_from_image(smoothed_imaginary_image)

# Combine the real and imaginary parts into a complex image
smoothed_complex = smoothed_real + 1j * smoothed_imaginary

# Save or display results
print("Smoothed Complex Image Shape:", smoothed_complex.shape)
EOL

# Step 5: Run the Smoothing Script
echo "Running the smoothing script..."
python3 complex_smoothing.py

# Step 6: Deactivate the Virtual Environment
echo "Deactivating the virtual environment..."
deactivate

echo "All steps completed successfully!"
