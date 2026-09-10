#!/bin/sh

# Install the agent skill for the harnesses on this machine. Idempotent.

set -eu

root="$(CDPATH= cd -- "$(dirname -- "$0")" 2>/dev/null && pwd)"
name="herdr-auto-name-pane"
legacy="auto-name-pane"

for base in "$HOME/.agents/skills" "$HOME/.claude/skills"; do
  dir="$base/$name"
  mkdir -p "$dir"
  cp "$root/SKILL.md" "$dir/SKILL.md"
  chmod 644 "$dir/SKILL.md"
  rm -f "$dir/resolve.sh"
  echo "installed skill -> $dir"

  if [ -d "$base/$legacy" ]; then
    rm -rf "$base/$legacy"
    echo "removed stale skill -> $base/$legacy"
  fi
done
