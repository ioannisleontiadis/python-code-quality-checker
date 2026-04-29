#!/bin/bash

# Install dependencies script
# This script sets up Python, pip, and extracts/installs dependencies from modified files

set -e

# Upgrade pip and install required tools
python -m pip install --upgrade pip
pip install pylint mypy pipreqs

# Read the changed files from the environment variable set by the action
CHANGED_PY_FILES="${CHANGED_FILES}"

if [ -z "$CHANGED_PY_FILES" ]; then
  echo "No Python files to process"
  exit 0
fi

# Create a temporary directory for modified files
mkdir -p /tmp/modified_files

# Copy modified Python files to temp directory, preserving structure
for file in $CHANGED_PY_FILES; do
  if [ -f "$file" ]; then
    mkdir -p "/tmp/modified_files/$(dirname "$file")"
    cp "$file" "/tmp/modified_files/$file"
  fi
done

# Extract requirements from modified files using pipreqs
# pipreqs saves to requirements.txt in the target directory by default
pipreqs /tmp/modified_files > /dev/null 2>&1 || true

# Install extracted requirements if the file exists
if [ -f /tmp/modified_files/requirements.txt ]; then
  echo "Installing extracted dependencies:"
  cat /tmp/modified_files/requirements.txt
  pip install -r /tmp/modified_files/requirements.txt
else
  echo "No dependencies found in modified files"
fi
