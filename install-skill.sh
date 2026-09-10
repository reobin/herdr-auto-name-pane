#!/bin/sh

# Install SKILL.md for the harnesses on this machine. Idempotent.

set -eu

src="$(CDPATH= cd -- "$(dirname -- "$0")" 2>/dev/null && pwd)/SKILL.md"
name="auto-name-pane"

for dir in "$HOME/.agents/skills/$name" "$HOME/.claude/skills/$name"; do
  mkdir -p "$dir"
  cp "$src" "$dir/SKILL.md"
  chmod 644 "$dir/SKILL.md"
  echo "installed skill -> $dir/SKILL.md"
done
