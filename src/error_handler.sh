#!/usr/bin/env bash

set -eu

function report_error() {
  local error_msg="$1"
  local script_name="${2:-$(basename "$0")}"
  local line_number="${3:-$?}"

  # Centralized error reporting
  echo "::error file=${script_name},line=${line_number}::${error_msg}" >&2
}

# Export so it can be used in subshells if needed
export -f report_error
