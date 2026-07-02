#!/usr/bin/env bash
# Refresh SAP Integration Suite docs clone if stale.
# Usage: refresh.sh [--force] [--max-age-hours N]
set -euo pipefail

REPO="/mnt/c/users/aeidl/git/emmi/btp-integration-suite"
MAX_AGE_HOURS=24
FORCE=0

while [[ $# -gt 0 ]]; do
  case "$1" in
    --force) FORCE=1; shift ;;
    --max-age-hours) MAX_AGE_HOURS="$2"; shift 2 ;;
    *) echo "unknown arg: $1" >&2; exit 2 ;;
  esac
done

cd "$REPO"

stamp="$REPO/.git/FETCH_HEAD"
if [[ $FORCE -eq 0 && -f "$stamp" ]]; then
  age_sec=$(( $(date +%s) - $(stat -c %Y "$stamp") ))
  max_sec=$(( MAX_AGE_HOURS * 3600 ))
  if (( age_sec < max_sec )); then
    echo "fresh ($((age_sec/3600))h old, threshold ${MAX_AGE_HOURS}h) — skip"
    exit 0
  fi
fi

echo "pulling..."
git pull --ff-only
echo "done: $(git rev-parse --short HEAD) ($(git log -1 --format=%cr))"
