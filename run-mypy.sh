#!/bin/bash

# Run mypy on changed Python files
# This script executes mypy type checking on the modified Python files and outputs to GitHub summary
# Checks for any issues and saves status for final evaluation

# Read the changed files from the environment variable set by the action
CHANGED_PY_FILES="${CHANGED_FILES}"
STATUS_DIR="${RUNNER_TEMP:-/tmp}"
MYPY_STATUS_FILE="$STATUS_DIR/mypy_status"
EXISTING_FILES=""

for file in $CHANGED_PY_FILES; do
  if [ -f "$file" ]; then
    EXISTING_FILES="${EXISTING_FILES}${file} "
  fi
done
EXISTING_FILES="${EXISTING_FILES%" "}"

if [ -z "$EXISTING_FILES" ]; then
  echo "No existing Python files to analyze"
  echo "1" > "$MYPY_STATUS_FILE"
  exit 0
fi

# Run mypy on the changed files and capture output
echo "## Mypy Results" >> "$GITHUB_STEP_SUMMARY"
echo "Analyzed files: $EXISTING_FILES" >> "$GITHUB_STEP_SUMMARY"
echo '```' >> "$GITHUB_STEP_SUMMARY"

# Capture both stdout and stderr
set +e
MYPY_OUTPUT=$(mypy $EXISTING_FILES 2>&1)
MYPY_EXIT_CODE=$?
set -e

echo "$MYPY_OUTPUT" >> "$GITHUB_STEP_SUMMARY"
echo '```' >> "$GITHUB_STEP_SUMMARY"

# Check if mypy found any issues
# Exit code 0 means no issues, non-zero means issues found
# Note: mypy will output "Success: no issues found..." even with exit 0, so check exit code only
if [ $MYPY_EXIT_CODE -eq 0 ]; then
  # No issues
  echo "1" > "$MYPY_STATUS_FILE"
else
  # Issues found
  echo "0" > "$MYPY_STATUS_FILE"
fi
