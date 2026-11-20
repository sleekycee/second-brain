#!/usr/bin/env bash
# Second brain setup for Claude Code and Codex (macOS / Linux).
# Usage: ./setup.sh [--with-hook] [brain-folder]     default: ~/Documents/secondbrain
#   --with-hook   also install the optional Claude Code nudge hook (needs python3)
# Safe to run twice: existing files are never overwritten.
set -euo pipefail

WITH_HOOK=0
BRAIN_ARG=""
for arg in "$@"; do
  case "$arg" in
    --with-hook) WITH_HOOK=1 ;;
    -*) echo "Unknown option: $arg" >&2; exit 1 ;;
    *) BRAIN_ARG="$arg" ;;
  esac
done
BRAIN_DIR="${BRAIN_ARG:-$HOME/Documents/secondbrain}"
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
    sed -e "s|__BRAIN__|$ESCAPED|g" -e "s|__TODAY__|$(date +%F)|g" "$HERE/template/$f" > "$dest"
    echo "created  ${f#./}"
  fi
done

# A brain set up before the wiki rules existed keeps its own CLAUDE.md. Say how to upgrade it.
if ! grep -q 'wiki\.md' "$BRAIN_DIR/CLAUDE.md"; then
  echo "note     your CLAUDE.md predates the wiki rules. To add them, tell your agent:"
  echo "         \"Upgrade my second brain's CLAUDE.md to the wiki version from the second-brain repo.\""
fi

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

# 3. Let any session read and write the brain without permission prompts,
#    and register the optional nudge hook when asked.
HOOK_CMD=""
if [ "$WITH_HOOK" = 1 ]; then
  mkdir -p "$CLAUDE_DIR/hooks"
  cp "$HERE/extras/brain-nudge.py" "$CLAUDE_DIR/hooks/brain-nudge.py"
  HOOK_CMD="python3 \"$CLAUDE_DIR/hooks/brain-nudge.py\" \"$BRAIN_DIR\""
fi
SETTINGS="$CLAUDE_DIR/settings.json"
if python3 - "$SETTINGS" "$BRAIN_DIR" "$HOOK_CMD" <<'PY'
import json, os, shutil, sys

path, brain, hook_cmd = sys.argv[1], sys.argv[2], sys.argv[3]
settings = {}
if os.path.exists(path) and os.path.getsize(path):
    with open(path) as fh:
        settings = json.load(fh)  # invalid JSON raises here, file left untouched
    shutil.copy(path, path + ".bak")
changed = False
dirs = settings.setdefault("permissions", {}).setdefault("additionalDirectories", [])
if brain not in dirs:
    dirs.append(brain)
    changed = True
if hook_cmd:
    stops = settings.setdefault("hooks", {}).setdefault("Stop", [])
    found = [h for g in stops for h in g.get("hooks", []) if "brain-nudge.py" in h.get("command", "")]
    if not found:
        stops.append({"hooks": [{"type": "command", "command": hook_cmd, "timeout": 10}]})
        changed = True
    elif found[0].get("command") != hook_cmd:  # already installed: repoint it at this brain
        found[0]["command"] = hook_cmd
        changed = True
if changed:
    tmp = path + ".tmp"
    with open(tmp, "w") as fh:
        json.dump(settings, fh, indent=2)
        fh.write("\n")
    os.replace(tmp, path)
PY
then
  echo "allowed  $SETTINGS"
  [ "$WITH_HOOK" = 1 ] && echo "hook     $CLAUDE_DIR/hooks/brain-nudge.py"
else
  echo "Could not update $SETTINGS automatically." >&2
  echo "Add \"$BRAIN_DIR\" to permissions.additionalDirectories in that file by hand." >&2
  [ "$WITH_HOOK" = 1 ] && echo "The nudge hook was not registered. See the README to add it by hand." >&2
fi

cat <<EOF

Second brain ready at $SHOWN
Next: open a NEW agent session in any folder and say:
  run the setup interview
EOF
