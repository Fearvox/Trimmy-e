#!/usr/bin/env bash
set -euo pipefail
if [[ "$#" -gt 0 ]]; then
  echo "Scripts/release.sh no longer accepts version/build args; edit version.env and CHANGELOG.md, sync Info.plists, then rerun." >&2
  exit 2
fi

SCRIPT_DIR=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)
"$SCRIPT_DIR/sync-version-plists.sh" --check
exec "$SCRIPT_DIR/mac-release" release
