#!/usr/bin/env bash
#
# mountpoint-fusion.sh
# Combines remaining free space on the root (/) and /mnt partitions
# into a single fast BTRFS RAID0 partition mounted at /state.
# Designed to be fast and ephemeral (data safety is not a priority).

set -eu

# A simple wrapper to echo and execute commands for logging
function run {
  echo "run:" "$@"
  "$@"
}

root_free_space=$(df -m / | tail -n 1 | awk '{print $4}')
mnt_free_space=$(df -m /mnt | tail -n 1 | awk '{print $4}')
echo "free space of /: ${root_free_space}MB"
echo "free space of /mnt: ${mnt_free_space}MB"

# Reserve 1GB of overhead for each partition and create large image files.
# Loop devices are used to map these files as block devices for BTRFS.
loops=()
if run sudo fallocate -l $((root_free_space - 1024))M /disk.img; then
  run sudo losetup /dev/loop69 /disk.img
  loops+=(/dev/loop69)
fi

if run sudo fallocate -l $((mnt_free_space - 1024))M /mnt/disk.img; then
  run sudo losetup /dev/loop420 /mnt/disk.img
  loops+=(/dev/loop420)
fi


# fvck reliability, gotta go fast
# Uses RAID0 over the loopback devices to maximize throughput and space.
run sudo mkfs.btrfs -L actions -d raid0 -m raid0 "${loops[@]}"
run sudo btrfs device scan

run sudo btrfs filesystem show

run sudo file "${loops[@]}"

run sudo mkdir -p /state
# Mount with aggressive caching/performance flags (nobarrier, high commit interval) since data loss on panic is acceptable for CI.
run sudo mount LABEL=actions /state -o defaults,noautodefrag,nobarrier,commit=300,compress=zstd

# Bind-mount specific high-use directories into the fast BTRFS /state partition.
for dir in /nix; do
  echo "Bind mounting $dir"
  run sudo mkdir -p {/state,}$dir
  run sudo mount -o bind "/state$dir" "$dir"
done
