# action-i-only-care-about-nix

Cleans the crap out of a GitHub Actions workflow so the most space possible is available for Nix.

## Purpose

GitHub Actions VMs come pre-installed with many tools, SDKs, and images that take up a significant amount of disk space (e.g., .NET, Android SDKs, large Docker images). If you are only building with Nix, this space is wasted.

This action reclaims that space and optimizes disk performance by setting up a merged BTRFS partition across the available free space.

## What it does

1.  **The Purge (`the-purge.sh`)**: Stops unnecessary services and forcefully deletes gigabytes of pre-installed tools, libraries, caches, and Docker images from the runner.
2.  **Mountpoint Fusion (`mountpoint-fusion.sh`)**: Creates loopback devices from the free space on `/` and `/mnt`. It formats them into a single fast (but unreliable) BTRFS RAID0 filesystem, mounts it to `/state` with aggressive performance flags (`compress=zstd`, `commit=300`), and creates a bind mount for `/nix`.

## Usage

Just add it as a step in your GitHub Actions workflow before setting up Nix:

```yaml
jobs:
  build:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4

      - name: Free up disk space for Nix
        uses: lucasew/action-i-only-care-about-nix@v1

      - name: Install Nix
        uses: DeterminateSystems/nix-installer-action@main

      - name: Build with Nix
        run: nix build .
```

### Advanced Usage (Bind Mounts)

The merged partition is mounted on `/state`. If you need to use this fast, large storage area for other directories, you can create additional bind mounts:

```bash
sudo mkdir -p /state/my-cache /my-cache
sudo mount -o bind /state/my-cache /my-cache
```

## ⚠️ Important Caveats & Side-Effects

*   **Destructive**: This action aggressively removes almost all pre-installed software on the runner. Do not use this if your workflow depends on pre-installed tools like `docker`, `rustc`, `go`, or Android SDKs unless you intend to fetch them via Nix.
*   **Unreliable Storage**: The BTRFS filesystem is created with `raid0` and aggressive performance flags (`nobarrier`, high commit time) across loopback devices. It is designed for **ephemeral build speed and maximum capacity, not reliability**. If the runner crashes, the filesystem may be corrupted. This is usually fine for ephemeral CI runners.
