#!/usr/bin/env bash
set -euo pipefail

ROOT=$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)
cd "$ROOT"

source "$ROOT/version.env"

check=0
if [[ "${1:-}" == "--check" ]]; then
  check=1
fi

python3 - "$MARKETING_VERSION" "$BUILD_NUMBER" "$check" <<'PY'
import plistlib
import sys
from pathlib import Path

version, build, check = sys.argv[1], sys.argv[2], sys.argv[3] == "1"
paths = [Path("Info.plist"), Path("Info.debug.plist")]
dirty = []

for path in paths:
    data = plistlib.loads(path.read_bytes())
    before = (
        data.get("CFBundleShortVersionString"),
        data.get("CFBundleVersion"),
    )
    after = (version, build)
    if before != after:
        dirty.append((path, before, after))
        if not check:
            data["CFBundleShortVersionString"] = version
            data["CFBundleVersion"] = build
            path.write_bytes(plistlib.dumps(data, sort_keys=False))

if dirty and check:
    for path, before, after in dirty:
        print(
            f"{path} has {before[0]} ({before[1]}), expected {after[0]} ({after[1]})",
            file=sys.stderr,
        )
    print("Run Scripts/sync-version-plists.sh and commit the result.", file=sys.stderr)
    raise SystemExit(1)
PY
