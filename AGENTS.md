# Agent Conventions & Guidelines

Welcome, autonomous agent! When working in this repository (`action-i-only-care-about-nix`), strictly adhere to the following rules, conventions, and operational mappings.

## 🧭 Operational Memory (Where things live)

*   `.` (Root) -> Contains the GitHub action definition (`action.yml`) and core shell scripts.
*   `action.yml` -> Entrypoint for the GitHub Action. Defines the steps to run.
*   `the-purge.sh` -> Responsibility: Forcefully delete gigabytes of pre-installed tools, caches, and SDKs to free up disk space.
*   `mountpoint-fusion.sh` -> Responsibility: Create and mount a fast BTRFS RAID0 filesystem across loopback devices built from the freed space.
*   `README.md` -> User documentation, explaining caveats and advanced usage.

## 📜 Core Conventions

1.  **Strict Shell Scripting**:
    *   All shell scripts must start with `#!/usr/bin/env bash` and `set -eu`.
    *   Any error must halt the script immediately (no silent failures).
    *   Logs must be prominent for debugging. Use explicit `echo` statements or custom logging functions like `function run { echo "run:" "$@"; "$@"; }`.
2.  **No Extraneous Tooling**: Do not add dependencies or runtime requirements to the scripts unless absolutely necessary. This action is designed to *remove* things, not add them.
3.  **BTRFS & Mounts**: When modifying `mountpoint-fusion.sh`, be extremely careful with mount flags. The goal is maximum speed (`nobarrier`, `noautodefrag`, `commit=300`, `compress=zstd`) across the available free space. Do not introduce flags that sacrifice speed for reliability, as this is for ephemeral runners.
4.  **Error Handling Centralization**: If an unexpected error occurs during script execution that is recoverable, it should be clearly logged to standard error (`stderr`) before exiting, so GitHub Actions captures the failure correctly. Do not swallow errors.

## 📝 Documentation Guidelines
*   Keep `README.md` up-to-date with any new paths deleted in `the-purge.sh` or changes to mount behavior in `mountpoint-fusion.sh`.
*   Ensure that any new script added is briefly explained in the README.

## ⚙️ Testing / Verification
*   This repository does not currently use an automated test suite. Rely on manual logic verification, bash linting (`shellcheck` if available), and careful inspection of `df -h` and `btrfs filesystem show` logic.
*   Always ensure that changes to `action.yml` maintain valid YAML syntax and logical ordering.

## 🚫 What Not To Do
*   Do not attempt to restore tools removed in `the-purge.sh` (like Rust, Go, or .NET) under the assumption they are "missing." They are removed on purpose.
*   Do not downgrade actions in GitHub workflows (e.g., `actions/checkout`).
