#!/usr/bin/env bash

set -eu

# Source the centralized error handler
source "$(dirname "$0")/error_handler.sh"

trap 'report_error "An unexpected error occurred in mountpoint-fusion.sh" "mountpoint-fusion.sh" "$LINENO"' ERR

# Constants
readonly RESERVED_SPACE_MB=1024
readonly BTRFS_LABEL="actions"
readonly MOUNT_DIR="/state"
readonly BTRFS_MOUNT_OPTIONS="defaults,noautodefrag,nobarrier,commit=300,compress=zstd"

function run {
  echo "run:" "$@"
  "$@" || { report_error "Failed to run command: $*"; return 1; }
}

root_free_space=$(df -m / | tail -n 1 | awk '{print $4}')
mnt_free_space=$(df -m /mnt | tail -n 1 | awk '{print $4}')
echo "free space of /: ${root_free_space}MB"
echo "free space of /mnt: ${mnt_free_space}MB"

loops=()

root_target_size=$((root_free_space - RESERVED_SPACE_MB))
if [ "$root_target_size" -gt 0 ] && run sudo fallocate -l "${root_target_size}M" /disk.img; then
  loop_dev=$(sudo losetup -f --show /disk.img) || report_error "Failed to setup loop device for /disk.img"
  if [ -n "$loop_dev" ]; then
    loops+=("$loop_dev")
  fi
fi

mnt_target_size=$((mnt_free_space - RESERVED_SPACE_MB))
if [ "$mnt_target_size" -gt 0 ] && run sudo fallocate -l "${mnt_target_size}M" /mnt/disk.img; then
  loop_dev=$(sudo losetup -f --show /mnt/disk.img) || report_error "Failed to setup loop device for /mnt/disk.img"
  if [ -n "$loop_dev" ]; then
    loops+=("$loop_dev")
  fi
fi

if [ ${#loops[@]} -eq 0 ]; then
  report_error "No loop devices were successfully created. Aborting BTRFS setup."
  exit 1
fi

# Create BTRFS filesystem
run sudo mkfs.btrfs -L "${BTRFS_LABEL}" -d raid0 -m raid0 "${loops[@]}"
run sudo btrfs device scan

run sudo btrfs filesystem show

run sudo file "${loops[@]}"

run sudo mkdir -p "${MOUNT_DIR}"
run sudo mount LABEL="${BTRFS_LABEL}" "${MOUNT_DIR}" -o "${BTRFS_MOUNT_OPTIONS}"

for dir in /nix; do
  echo "Bind mounting $dir"
  run sudo mkdir -p "${MOUNT_DIR}$dir" "$dir"
  run sudo mount -o bind "${MOUNT_DIR}$dir" "$dir"
done
