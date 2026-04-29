#!/bin/bash

# Check quality status from previous tools
# This script reads status files created by pylint and mypy checks
# Fails if either check failed

STATUS_DIR="${RUNNER_TEMP:-/tmp}"
PYLINT_STATUS_FILE="$STATUS_DIR/pylint_status"
MYPY_STATUS_FILE="$STATUS_DIR/mypy_status"

OVERALL_STATUS=0

# Check pylint status
if [ -f "$PYLINT_STATUS_FILE" ]; then
  PYLINT_STATUS=$(cat "$PYLINT_STATUS_FILE")
  if [ "$PYLINT_STATUS" = "1" ]; then
    echo "✓ Pylint: Passed (score = 10.0)"
  else
    echo "✗ Pylint: Failed (score ≠ 10.0)"
    OVERALL_STATUS=1
  fi
else
  echo "⚠ Pylint: Status file not found"
  OVERALL_STATUS=1
fi

# Check mypy status
if [ -f "$MYPY_STATUS_FILE" ]; then
  MYPY_STATUS=$(cat "$MYPY_STATUS_FILE")
  if [ "$MYPY_STATUS" = "1" ]; then
    echo "✓ Mypy: Passed (no issues)"
  else
    echo "✗ Mypy: Failed (issues detected)"
    OVERALL_STATUS=1
  fi
else
  echo "⚠ Mypy: Status file not found"
  OVERALL_STATUS=1
fi

# Exit with failure if any check failed
if [ $OVERALL_STATUS -ne 0 ]; then
  echo ""
  echo "❌ Quality checks failed. Please review the results above."
  exit 1
fi

echo ""
echo "✅ All quality checks passed!"
exit 0
