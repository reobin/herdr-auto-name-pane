#!/bin/sh

# Name the single pane from a `pane.created` event. Never overwrites a label.
# Falls back to naming every unlabeled pane when the event carries no ID.

set -eu

cd "${HERDR_PLUGIN_ROOT:-.}"
. scripts/common.sh

command -v jq >/dev/null 2>&1 || {
  echo "auto-name-pane: jq not found, skipping naming" >&2
  exit 0
}

pane="$(
  printf '%s' "${HERDR_PLUGIN_EVENT_JSON:-{}}" | jq -r '
    .pane.pane_id // .data.pane.pane_id // .pane_id // empty
  ' 2>/dev/null || true
)"

if [ -z "$pane" ]; then
  exec sh scripts/name-unnamed.sh
fi

name_pane "$pane" || true
