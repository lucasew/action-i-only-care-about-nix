#!/usr/bin/env bash

set -euo pipefail

function report_error {
  local error_msg="$1"
  # Provide context with stack trace if possible
  echo "::error::[action-i-only-care-about-nix] $error_msg" >&2
}

# Trap common errors globally if sourced
trap 'report_error "An unexpected error occurred in script: $0 at line $LINENO"' ERR
