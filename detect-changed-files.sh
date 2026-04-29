#!/bin/bash

# Detect changed Python files
# This script identifies .py files that have been modified in the current push/PR

CHANGED_PY_FILES=""

# For push events, use GITHUB_EVENT_BEFORE and GITHUB_EVENT_AFTER environment variables
# Check if before is valid (not all zeros) to handle merge commits properly
if [ ! -z "$GITHUB_EVENT_BEFORE" ] && [ ! -z "$GITHUB_EVENT_AFTER" ] && [ "$GITHUB_EVENT_BEFORE" != "0000000000000000000000000000000000000000" ]; then
  CHANGED_PY_FILES=$(git diff $GITHUB_EVENT_BEFORE...$GITHUB_EVENT_AFTER --name-only -- '*.py' 2>/dev/null | xargs)
  # If diff succeeded, use the result; otherwise fall through to fallback
  if [ $? -eq 0 ] && [ ! -z "$CHANGED_PY_FILES" ]; then
    echo "Using GITHUB_EVENT_BEFORE/AFTER for diff"
  else
    CHANGED_PY_FILES=""
  fi
fi

# Fallback for merge commits or when event context is unavailable
if [ -z "$CHANGED_PY_FILES" ]; then
  if git rev-parse HEAD~1 >/dev/null 2>&1; then
    # For merge commits, use the merge-base to find changes
    MERGE_BASE=$(git merge-base HEAD~ HEAD 2>/dev/null || echo "HEAD~1")
    CHANGED_PY_FILES=$(git diff ${MERGE_BASE}...HEAD --name-only -- '*.py' 2>/dev/null | xargs)
  fi
fi

echo "changed_files=${CHANGED_PY_FILES}" >> $GITHUB_OUTPUT
if [ -z "$CHANGED_PY_FILES" ]; then
  echo "No Python files changed"
  exit 0
fi
echo "Changed Python files: $CHANGED_PY_FILES"
