#!/bin/sh

# Install the agent skill for the harnesses on this machine. Idempotent.

set -eu

root="$(CDPATH= cd -- "$(dirname -- "$0")" 2>/dev/null && pwd)"
name="herdr-callsigns"
legacy="auto-name-pane herdr-auto-name-pane"

for base in "$HOME/.agents/skills" "$HOME/.claude/skills"; do
  dir="$base/$name"
  mkdir -p "$dir"
  cp "$root/SKILL.md" "$dir/SKILL.md"
  chmod 644 "$dir/SKILL.md"
  echo "installed skill -> $dir"

  for old in $legacy; do
    if [ -d "$base/$old" ]; then
      rm -rf "$base/$old"
      echo "removed stale skill -> $base/$old"
    fi
  done
done
