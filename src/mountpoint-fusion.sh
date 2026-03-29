#!/usr/bin/env bash

set -euo pipefail

# Source the centralized error handler
source "$(dirname "$0")/error_handler.sh"
setup_error_trap

function run {
  echo "run:" "$@" >&2
  "$@"
}

create_loop_devices() {
  local -n ref_loops=$1
  local root_free_space
  local mnt_free_space

  root_free_space=$(df -m / | tail -n 1 | awk '{print $4}')
  mnt_free_space=$(df -m /mnt | tail -n 1 | awk '{print $4}')

  echo "free space of /: ${root_free_space}MB"
  echo "free space of /mnt: ${mnt_free_space}MB"

  if run sudo fallocate -l $((root_free_space - 1024))M /disk.img; then
    # Dynamically allocate loop device to prevent collisions
    local loop_root
    loop_root=$(run sudo losetup -f --show /disk.img)
    ref_loops+=("$loop_root")
  fi

  if run sudo fallocate -l $((mnt_free_space - 1024))M /mnt/disk.img; then
    # Dynamically allocate loop device to prevent collisions
    local loop_mnt
    loop_mnt=$(run sudo losetup -f --show /mnt/disk.img)
    ref_loops+=("$loop_mnt")
  fi
}

setup_btrfs() {
  local -n ref_loops=$1

  # fvck reliability, gotta go fast
  run sudo mkfs.btrfs -L actions -d raid0 -m raid0 "${ref_loops[@]}"
  run sudo btrfs device scan

  run sudo btrfs filesystem show

  run sudo file "${ref_loops[@]}"

  run sudo mkdir -p /state
  run sudo mount LABEL=actions /state -o defaults,noautodefrag,nobarrier,commit=300,compress=zstd

  for dir in /nix; do
    echo "Bind mounting $dir"
    run sudo mkdir -p {/state,}$dir
    run sudo mount -o bind "/state$dir" "$dir"
  done
}

main() {
  local loops=()
  create_loop_devices loops
  setup_btrfs loops
}

main
