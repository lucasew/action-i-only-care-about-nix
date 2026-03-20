# action-i-only-care-about-nix

Cleans the pre-installed software out of a GitHub Actions workflow environment so the most disk space possible is available for Nix builds.

## How it works
1. **The Purge (`the-purge.sh`)**: Aggressively uninstalls pre-installed tools (Docker, Snap, large SDKs in `/usr/local` and `/opt`) running in the background for speed.
2. **Mountpoint Fusion (`mountpoint-fusion.sh`)**: Takes the remaining space on the root `/` and `/mnt` partitions, loopback-mounts them into image files, and creates a high-performance BTRFS RAID0 filesystem mounted at `/state`.

## Usage

Just add it as a step in your workflow:

```yaml
steps:
  - uses: lucasew/action-i-only-care-about-nix@vX
```

By default, `/nix` is already bind-mounted into `/state/nix`.

### Additional Directories

The merged high-speed partition is mounted on `/state`. If you want to use it for more things beyond Nix, you can create bind mounts from `/state` to the directories you need:

```bash
sudo mkdir -p /state/my-cache /my-cache
sudo mount -o bind /state/my-cache /my-cache
```
