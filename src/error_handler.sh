#!/usr/bin/env bash

# Centralized error reporting function
report_error() {
  local exit_code=$1
  local message=$2

  if [ -n "$message" ]; then
    echo "::error::Error: $message" >&2
  else
    echo "::error::An unexpected error occurred (exit code: $exit_code)" >&2
  fi

  # Fail the GitHub Action step by exiting with the original error code
  exit "$exit_code"
}

# Sets up a global error trap
setup_error_trap() {
  trap 'report_error $? "Command failed at line $LINENO"' ERR
}
