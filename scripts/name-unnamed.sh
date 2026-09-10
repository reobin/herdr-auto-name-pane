#!/bin/sh

# Name every unlabeled pane. Used by the startup hook and as event fallback.

set -eu

cd "${HERDR_PLUGIN_ROOT:-.}"
. scripts/common.sh

command -v jq >/dev/null 2>&1 || {
  echo "auto-name-pane: jq not found, skipping naming" >&2
  exit 0
}

unlabeled_panes | while IFS= read -r pane; do
  [ -n "$pane" ] || continue
  name_pane "$pane" || true
done
