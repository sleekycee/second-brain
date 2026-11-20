#!/usr/bin/env bash
# Second brain setup for Claude Code and Codex (macOS / Linux).
# Usage: ./setup.sh [brain-folder]     default: ~/Documents/secondbrain
# Safe to run twice: existing files are never overwritten.
set -euo pipefail

BRAIN_DIR="${1:-$HOME/Documents/secondbrain}"
CLAUDE_DIR="${CLAUDE_CONFIG_DIR:-$HOME/.claude}"
HERE="$(cd "$(dirname "$0")" && pwd)"

mkdir -p "$BRAIN_DIR" "$CLAUDE_DIR"
BRAIN_DIR="$(cd "$BRAIN_DIR" && pwd)"

# Path as written into the files: ~/... when the brain is under the home folder.
case "$BRAIN_DIR" in
  "$HOME"/*) SHOWN="~${BRAIN_DIR#"$HOME"}" ;;
  *) SHOWN="$BRAIN_DIR" ;;
esac
case "$SHOWN" in
  *[[:space:]]*) echo "Pick a brain folder with no spaces in its path: $SHOWN" >&2; exit 1 ;;
esac
ESCAPED="$(printf '%s' "$SHOWN" | sed 's/[&|\\]/\\&/g')"

# 1. Copy the template, filling in the brain path. Never overwrite.
(cd "$HERE/template" && find . -type f) | while IFS= read -r f; do
  dest="$BRAIN_DIR/${f#./}"
  mkdir -p "$(dirname "$dest")"
  if [ -e "$dest" ]; then
    echo "kept     ${f#./}"
  else
    sed "s|__BRAIN__|$ESCAPED|g" "$HERE/template/$f" > "$dest"
    echo "created  ${f#./}"
  fi
done

# 2. Load the brain in every Claude Code session.
GLOBAL="$CLAUDE_DIR/CLAUDE.md"
touch "$GLOBAL"
for f in CLAUDE.md index.md; do
  line="@$SHOWN/$f"
  grep -qxF "$line" "$GLOBAL" || printf '\n%s\n' "$line" >> "$GLOBAL"
done
echo "imports  $GLOBAL"

# 2b. Codex, if installed. AGENTS.md has no import syntax, so add a pointer instead.
CODEX_DIR="${CODEX_HOME:-$HOME/.codex}"
if [ -d "$CODEX_DIR" ]; then
  AGENTS="$CODEX_DIR/AGENTS.md"
  touch "$AGENTS"
  grep -qF "$BRAIN_DIR/CLAUDE.md" "$AGENTS" || printf '\n## Second brain\n\nMy second brain is at %s/. At the start of every session, read %s/CLAUDE.md and %s/index.md and follow them.\n' "$BRAIN_DIR" "$BRAIN_DIR" "$BRAIN_DIR" >> "$AGENTS"
  echo "codex    $AGENTS"
fi

# 3. Let any session read and write the brain without permission prompts.
SETTINGS="$CLAUDE_DIR/settings.json"
if python3 - "$SETTINGS" "$BRAIN_DIR" <<'PY'
import json, os, shutil, sys

path, brain = sys.argv[1], sys.argv[2]
settings = {}
if os.path.exists(path) and os.path.getsize(path):
    with open(path) as fh:
        settings = json.load(fh)  # invalid JSON raises here, file left untouched
    shutil.copy(path, path + ".bak")
dirs = settings.setdefault("permissions", {}).setdefault("additionalDirectories", [])
if brain not in dirs:
    dirs.append(brain)
    tmp = path + ".tmp"
    with open(tmp, "w") as fh:
        json.dump(settings, fh, indent=2)
        fh.write("\n")
    os.replace(tmp, path)
PY
then
  echo "allowed  $SETTINGS"
else
  echo "Could not update $SETTINGS automatically." >&2
  echo "Add \"$BRAIN_DIR\" to permissions.additionalDirectories in that file by hand." >&2
fi

cat <<EOF

Second brain ready at $SHOWN
Next: open a NEW agent session in any folder and say:
  run the setup interview
EOF
