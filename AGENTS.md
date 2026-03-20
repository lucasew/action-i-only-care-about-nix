# Project Conventions for AI Agents

Welcome to `action-i-only-care-about-nix`. When making PRs or editing files in this repository, follow these rules and operational memory items.

## Operational Memory

* `.github/workflows/` -> Holds CI/CD scripts
* `action.yml` -> Entrypoint for the Github Action
* `the-purge.sh` -> Script responsible for removing large, unnecessary pre-installed packages on standard GitHub runners.
* `mountpoint-fusion.sh` -> Script responsible for taking leftover disk space across standard mounts and converting them to a fast `BTRFS` RAID0 partition mounted at `/state`.

## Core Guidelines

* **Repository purpose**: GitHub Action that clears GitHub Actions VM disk space and mounts a fast BTRFS RAID0 partition on '/state' for Nix using bash scripts.
* **Mise First**: Always install and use 'mise' for task execution, and strictly pin tool versions. Don't downgrade anything unless asked.
* **Error Reporting**: Error handling must funnel through a single centralized reporting function. Silent failures and empty catch blocks are strictly prohibited.
* **Staging Limits**: Stage files explicitly with 'git add <path>'. Never use 'git add .'. Never commit bootstrap/download/tooling artifacts (e.g., 'install-mise.sh').
* **Ignore Lists**: Always check '.jules/CONSISTENTLY_IGNORED.md' (if it exists) before planning tasks to avoid repeating rejected patterns.

## Agent-Specific Conventions

* **Docs (📝)**: PR titles must exactly match the format '📝 Docs: [Description]'.
* **Sentinel (🛡️)**: PR titles must exactly match '🛡️ Sentinel: [Severity] [Description]', and fixes must be appended to '.jules/sentinel.md' as a single-line learning pattern.
* **Mandatory PR Sections**: Every Pull Request must include exactly four mandatory sections: 'Assumptions', 'Alternatives Not Chosen', 'How To Pivot', and 'Next Knobs'.
