#!/bin/bash

# Run pylint on changed Python files
# This script executes pylint analysis on the modified Python files and outputs to GitHub summary
# Checks if score is 10.0 and saves status for final evaluation

# Read the changed files from the environment variable set by the action
CHANGED_PY_FILES="${CHANGED_FILES}"
STATUS_DIR="${RUNNER_TEMP:-/tmp}"
PYLINT_STATUS_FILE="$STATUS_DIR/pylint_status"
EXISTING_FILES=""

for file in $CHANGED_PY_FILES; do
  if [ -f "$file" ]; then
    EXISTING_FILES="${EXISTING_FILES}${file} "
  fi
done
EXISTING_FILES="${EXISTING_FILES%" "}"

if [ -z "$EXISTING_FILES" ]; then
  echo "No existing Python files to analyze"
  echo "1" > "$PYLINT_STATUS_FILE"
  exit 0
fi

# Run pylint on the changed files and capture output
echo "## Pylint Results" >> "$GITHUB_STEP_SUMMARY"
echo "Analyzed files: $EXISTING_FILES" >> "$GITHUB_STEP_SUMMARY"
echo '```' >> "$GITHUB_STEP_SUMMARY"

# Capture both stdout and stderr
set +e
PYLINT_OUTPUT=$(pylint $EXISTING_FILES 2>&1)
set -e

echo "$PYLINT_OUTPUT" >> "$GITHUB_STEP_SUMMARY"
echo '```' >> "$GITHUB_STEP_SUMMARY"

# Extract the score from pylint output
# Format: "Your code has been rated at X.XX/10" or "Your code has been rated at 10/10"
SCORE=$(echo "$PYLINT_OUTPUT" | sed -n 's/.*rated at \([0-9.]*\).*/\1/p' | head -1 || echo "")

SCORE="${SCORE//[[:space:]]/}"

echo "$SCORE"

# Check if score equals 10 or 10.0
if [ -z "$SCORE" ]; then
  # No score found means pylint did not produce a standard report.
  echo "0" > "$PYLINT_STATUS_FILE"
elif [ "$SCORE" = "10.0" ] || [ "$SCORE" = "10" ] || [ "$SCORE" = "10.00" ]; then
  echo "CORRECT"
  echo "1" > "$PYLINT_STATUS_FILE"
else
  echo "0" > "$PYLINT_STATUS_FILE"
fi
