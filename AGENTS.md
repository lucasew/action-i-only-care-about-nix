# action-i-only-care-about-nix - Developer Conventions

## Operational Memory & Responsibilities
* `src/` -> Executable logic (scripts). Everything should live here, not in the root directory.
* `src/error_handler.sh` -> Centralized error reporting function `report_error`. All errors must pass through this handler. No empty catch blocks or silent failures.
* `action.yml` -> GitHub Action entrypoint.

## Refactoring Guidelines
* Files are organized by domain/responsibility.
* Functions and variables must use self-documenting names.
* Replace magic strings/numbers with constants.
* Scripts must define `set -eu` and trap `ERR` to funnel into `report_error`.
* Do NOT run tasks blindly. Use `mise run test` or `mise run ci` to verify changes.
