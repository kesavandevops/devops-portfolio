#!/bin/bash
set -e

# Clean old build
rm -rf build lambda_package.zip
mkdir -p build

# Copy Python source
cp lambda/app.py build/

# (Optional) Install extra Python dependencies if added in requirements.txt
# pip install -r lambda/requirements.txt -t build/

# Create zip
cd build
zip -r ../lambda_package.zip .
cd ..

echo "✅ Lambda package created: lambda_package.zip"
