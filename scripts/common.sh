#!/bin/sh

# Shared helpers for auto-name-pane. Sourced, not executed.
# Runs with the plugin root as cwd; HERDR_BIN_PATH points at the server binary.

set -eu

herdr_bin="${HERDR_BIN_PATH:-herdr}"
_plugin_root="${HERDR_PLUGIN_ROOT:-}"
if [ -z "$_plugin_root" ]; then
  _script_dir="$(CDPATH= cd -- "$(dirname -- "$0")" 2>/dev/null && pwd)" || _script_dir="."
  case "$_script_dir" in */scripts) _plugin_root="$(dirname -- "$_script_dir")" ;; *) _plugin_root="$_script_dir" ;; esac
fi
words_file="$_plugin_root/assets/words.txt"

used_names() {
  {
    "$herdr_bin" pane list 2>/dev/null | jq -r '.result.panes[]? | .label // empty'
    "$herdr_bin" agent list 2>/dev/null | jq -r '.result.agents[]? | .name // empty'
  } 2>/dev/null | tr '\n' ' '
}

unlabeled_panes() {
  "$herdr_bin" api snapshot 2>/dev/null |
    jq -r '.result.snapshot.panes[]? | select((.label // "") == "") | .pane_id'
}

pane_label() {
  "$herdr_bin" pane get "$1" 2>/dev/null | jq -r '.result.pane.label // empty'
}

pick_name() {
  used=" $1 "
  tmp="$(mktemp)" || return 1
  tr -d '\r' <"$words_file" | grep -v '^[[:space:]]*$' | awk '{print $1}' | grep -v '^$' >"$tmp" || true
  count="$(wc -l <"$tmp" | tr -d ' ')"
  case "$count" in '' | *[!0-9]* | 0) rm -f "$tmp"; return 1 ;; esac
  seed="$(od -An -N2 -tu2 /dev/urandom 2>/dev/null | tr -d ' ' || echo $$)"
  case "$seed" in '' | *[!0-9]*) seed=$$ ;; esac
  start=$((seed % count))
  i=0
  while [ "$i" -lt "$count" ]; do
    idx=$(((start + i) % count + 1))
    candidate="$(sed -n "${idx}p" "$tmp")"
    i=$((i + 1))
    [ -n "$candidate" ] || continue
    case "$used" in *" $candidate "*) continue ;; esac
    printf '%s' "$candidate"
    rm -f "$tmp"
    return 0
  done
  suffix=2
  while [ "$suffix" -le 99 ]; do
    while IFS= read -r w || [ -n "$w" ]; do
      [ -n "$w" ] || continue
      candidate="$w-$suffix"
      case "$used" in *" $candidate "*) continue ;; esac
      printf '%s' "$candidate"
      rm -f "$tmp"
      return 0
    done <"$tmp"
    suffix=$((suffix + 1))
  done
  rm -f "$tmp"
  return 1
}

name_pane() {
  pane="$1"
  attempts=0
  while [ "$attempts" -lt 3 ]; do
    [ -n "$(pane_label "$pane")" ] && return 0
    candidate="$(pick_name "$(used_names)")" || return 1
    [ -n "$candidate" ] || return 1
    if "$herdr_bin" pane rename "$pane" "$candidate" >/dev/null 2>&1; then
      return 0
    fi
    attempts=$((attempts + 1))
  done
  echo "auto-name-pane: failed to name pane $pane after $attempts attempts" >&2
  return 1
}
