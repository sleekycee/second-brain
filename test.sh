#!/usr/bin/env bash
# Runs setup.sh twice against a throwaway HOME and checks the result.
set -euo pipefail

HERE="$(cd "$(dirname "$0")" && pwd)"
export HOME="$(mktemp -d)"
unset CLAUDE_CONFIG_DIR
trap 'rm -rf "$HOME"' EXIT

fail() { echo "FAIL: $1" >&2; exit 1; }

mkdir -p "$HOME/.claude"
echo '{"outputStyle": "Concise", "permissions": {"allow": ["Edit"]}}' > "$HOME/.claude/settings.json"
echo "# my rules" > "$HOME/.claude/CLAUDE.md"

"$HERE/setup.sh" > /dev/null
echo "edited by me" > "$HOME/Documents/secondbrain/what-ive-built.md"
"$HERE/setup.sh" > /dev/null   # second run must change nothing

B="$HOME/Documents/secondbrain"
for f in CLAUDE.md index.md what-ive-built.md setup-interview.md context/.gitkeep projects/.gitkeep sources/.gitkeep; do
  [ -e "$B/$f" ] || fail "missing $f"
done
grep -rq "__BRAIN__" "$B" && fail "placeholder left in brain files"
grep -q '~/Documents/secondbrain/index.md' "$B/CLAUDE.md" || fail "brain path not written into CLAUDE.md"
[ "$(cat "$B/what-ive-built.md")" = "edited by me" ] || fail "second run overwrote an existing file"

G="$HOME/.claude/CLAUDE.md"
grep -q "# my rules" "$G" || fail "existing global CLAUDE.md content lost"
[ "$(grep -cxF '@~/Documents/secondbrain/CLAUDE.md' "$G")" = 1 ] || fail "CLAUDE.md import missing or duplicated"
[ "$(grep -cxF '@~/Documents/secondbrain/index.md' "$G")" = 1 ] || fail "index.md import missing or duplicated"

python3 - "$HOME/.claude/settings.json" "$B" <<'PY' || fail "settings.json wrong"
import json, os, sys
s = json.load(open(sys.argv[1]))
brain = os.path.realpath(sys.argv[2])
dirs = [os.path.realpath(d) for d in s["permissions"]["additionalDirectories"]]
assert dirs.count(brain) == 1, dirs
assert s["outputStyle"] == "Concise" and s["permissions"]["allow"] == ["Edit"], s
PY

# Invalid settings.json must be left untouched.
echo '{broken' > "$HOME/.claude/settings.json"
"$HERE/setup.sh" > /dev/null 2>&1
[ "$(cat "$HOME/.claude/settings.json")" = '{broken' ] || fail "invalid settings.json was modified"

# Paths with spaces are refused.
"$HERE/setup.sh" "$HOME/my brain" > /dev/null 2>&1 && fail "path with a space was accepted"

echo "PASS setup.sh"

# Same checks for the Windows script, when PowerShell is installed.
command -v pwsh > /dev/null || { echo "SKIP setup.ps1 (pwsh not installed)"; exit 0; }

rm -rf "$HOME/.claude"; mkdir -p "$HOME/.claude"
echo '{"outputStyle": "Concise", "permissions": {"allow": ["Edit"]}}' > "$HOME/.claude/settings.json"
echo "# my rules" > "$HOME/.claude/CLAUDE.md"

pwsh -NoProfile -File "$HERE/setup.ps1" > /dev/null
echo "edited by me" > "$HOME/secondbrain/what-ive-built.md"
pwsh -NoProfile -File "$HERE/setup.ps1" > /dev/null

P="$HOME/secondbrain"
for f in CLAUDE.md index.md what-ive-built.md setup-interview.md context/.gitkeep projects/.gitkeep sources/.gitkeep; do
  [ -e "$P/$f" ] || fail "ps1: missing $f"
done
grep -rq "__BRAIN__" "$P" && fail "ps1: placeholder left in brain files"
grep -q '~/secondbrain/index.md' "$P/CLAUDE.md" || fail "ps1: brain path not written into CLAUDE.md"
[ "$(cat "$P/what-ive-built.md")" = "edited by me" ] || fail "ps1: second run overwrote an existing file"
grep -q "# my rules" "$G" || fail "ps1: existing global CLAUDE.md content lost"
[ "$(grep -cxF '@~/secondbrain/CLAUDE.md' "$G")" = 1 ] || fail "ps1: CLAUDE.md import missing or duplicated"
[ "$(grep -cxF '@~/secondbrain/index.md' "$G")" = 1 ] || fail "ps1: index.md import missing or duplicated"
head -c 3 "$HOME/.claude/settings.json" | grep -q $'\xef\xbb\xbf' && fail "ps1: settings.json written with a BOM"

python3 - "$HOME/.claude/settings.json" "$P" <<'PY' || fail "ps1: settings.json wrong"
import json, os, sys
s = json.load(open(sys.argv[1]))
brain = os.path.realpath(sys.argv[2])
dirs = [os.path.realpath(d) for d in s["permissions"]["additionalDirectories"]]
assert dirs.count(brain) == 1, dirs
assert s["outputStyle"] == "Concise" and s["permissions"]["allow"] == ["Edit"], s
PY

echo '{broken' > "$HOME/.claude/settings.json"
pwsh -NoProfile -File "$HERE/setup.ps1" > /dev/null 2>&1
[ "$(cat "$HOME/.claude/settings.json")" = '{broken' ] || fail "ps1: invalid settings.json was modified"

pwsh -NoProfile -File "$HERE/setup.ps1" -BrainDir "$HOME/my brain" > /dev/null 2>&1 && fail "ps1: path with a space was accepted"

echo "PASS setup.ps1"
