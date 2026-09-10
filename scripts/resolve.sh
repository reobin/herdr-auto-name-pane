#!/bin/sh

# Resolve an animal label (or pass through a pane ID) to a pane ID.
# Usage: resolve.sh <label-or-pane-id>
# Prints the pane ID on stdout. Exits 1 when nothing matches.

set -eu

herdr_bin="${HERDR_BIN_PATH:-herdr}"
target="${1:-}"

if [ -z "$target" ]; then
  echo "resolve.sh: pass a pane label or pane ID" >&2
  exit 1
fi

command -v jq >/dev/null 2>&1 || {
  echo "resolve.sh: jq is required" >&2
  exit 1
}

snapshot="$("$herdr_bin" api snapshot 2>/dev/null)" || {
  echo "resolve.sh: could not read Herdr snapshot" >&2
  exit 1
}

match="$(
  printf '%s' "$snapshot" | jq -r --arg t "$target" '
    (.result.snapshot.panes[]? | select(.pane_id == $t) | .pane_id),
    (.result.snapshot.panes[]? | select((.label // "") == $t) | .pane_id)
  ' | head -n 1
)"

if [ -z "$match" ]; then
  echo "resolve.sh: no pane named '$target'" >&2
  exit 1
fi

printf '%s\n' "$match"
