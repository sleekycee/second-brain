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
[ -e "$HOME/.codex" ] && fail "created ~/.codex when Codex is not installed"
mkdir -p "$HOME/.codex"   # Codex now "installed"
echo "# codex rules" > "$HOME/.codex/AGENTS.md"
echo "edited by me" > "$HOME/Documents/secondbrain/what-ive-built.md"
"$HERE/setup.sh" > /dev/null
"$HERE/setup.sh" > /dev/null   # repeat runs must change nothing

grep -q "# codex rules" "$HOME/.codex/AGENTS.md" || fail "existing Codex AGENTS.md content lost"
[ "$(grep -c 'secondbrain/CLAUDE.md' "$HOME/.codex/AGENTS.md")" = 1 ] || fail "Codex pointer missing or duplicated"

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

# Optional hook: quiet for 5 turn-ends, blocks on the 6th, never loops, survives bad input.
hook() { printf '{"session_id":"t1","stop_hook_active":%s}' "$1" | python3 "$HERE/extras/brain-nudge.py" /my/brain; }
for i in 1 2 3 4 5; do [ -z "$(hook false)" ] || fail "hook fired early on turn $i"; done
hook false | grep -q '"decision": "block"' || fail "hook did not block on turn 6"
[ -z "$(hook false)" ] || fail "hook fired again on turn 7"
printf '{"session_id":"t2","stop_hook_active":false}' | BRAIN_NUDGE_EVERY=1 python3 "$HERE/extras/brain-nudge.py" /my/brain | grep -q '/my/brain/index.md' || fail "hook ignores the brain path argument"
[ -z "$(printf '{"session_id":"t3","stop_hook_active":true}' | BRAIN_NUDGE_EVERY=1 python3 "$HERE/extras/brain-nudge.py")" ] || fail "hook loops when already active"
echo 'not json' | python3 "$HERE/extras/brain-nudge.py" || fail "hook exits non-zero on bad input"
echo "PASS brain-nudge.py"

# Same checks for the Windows script, when PowerShell is installed.
command -v pwsh > /dev/null || { echo "SKIP setup.ps1 (pwsh not installed)"; exit 0; }

rm -rf "$HOME/.claude" "$HOME/.codex"; mkdir -p "$HOME/.claude" "$HOME/.codex"
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
[ "$(grep -c 'secondbrain/CLAUDE.md' "$HOME/.codex/AGENTS.md")" = 1 ] || fail "ps1: Codex pointer missing or duplicated"
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
