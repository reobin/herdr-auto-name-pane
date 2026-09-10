#!/bin/sh

# Resolve a pane label (or pass through a pane ID) to a pane ID.
# Usage: resolve.sh <label-or-pane-id>
# Prints the pane ID on stdout. Exits 1 when nothing matches, 2 when the
# label is ambiguous across workspaces.

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

matches="$(
  printf '%s' "$snapshot" | jq -r --arg t "$target" '
    [.result.snapshot.panes[]?
     | select(.pane_id == $t or (.label // "") == $t)
     | "\(.pane_id)\t\(.workspace_id // "?")"]
    | unique | .[]'
)" || {
  echo "resolve.sh: could not parse Herdr snapshot" >&2
  exit 1
}

count="$(printf '%s' "$matches" | grep -c . || true)"

case "$count" in
  0)
    echo "resolve.sh: no pane named '$target'" >&2
    exit 1
    ;;
  1)
    printf '%s\n' "$matches" | cut -f1
    ;;
  *)
    echo "resolve.sh: '$target' matches $count panes:" >&2
    printf '%s\n' "$matches" | while IFS="$(printf '\t')" read -r id ws; do
      echo "  $id (workspace $ws)" >&2
    done
    exit 2
    ;;
esac
