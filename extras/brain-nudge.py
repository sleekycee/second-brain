#!/usr/bin/env python3
"""Optional Claude Code Stop hook for the second brain.

Every Nth time Claude finishes a turn in a session, it is asked to save durable
facts to the brain before stopping, or to reply "Brain: nothing new."

Usage in ~/.claude/settings.json:
    "command": "python3 /full/path/to/brain-nudge.py /full/path/to/secondbrain"

Fails open: any error exits 0, so a broken hook never blocks a session.
"""
import json
import os
import re
import sys
import time

EVERY = int(os.environ.get("BRAIN_NUDGE_EVERY", "6"))  # turns between nudges; raise if it feels noisy
BRAIN = sys.argv[1] if len(sys.argv) > 1 else "~/Documents/secondbrain"
CLAUDE_DIR = os.environ.get("CLAUDE_CONFIG_DIR") or os.path.expanduser("~/.claude")
STATE_DIR = os.path.join(CLAUDE_DIR, "hooks", ".brain-nudge")

REASON = (
    f"Brain check (automatic, every {EVERY} turns). If this session has settled anything durable "
    "since the last check - a decision, a stack change, a new project folder, a person's role, "
    f"a preference - save it to the right file under {BRAIN}/ and update {BRAIN}/index.md, then "
    "tell the user in one line what you saved. Do not save task status, logs, code or secrets. "
    "If nothing durable was settled, reply with exactly: Brain: nothing new."
)


def main():
    data = json.load(sys.stdin)
    if data.get("stop_hook_active"):  # already continuing because of a Stop hook: never loop
        return
    session = re.sub(r"[^A-Za-z0-9_-]", "", str(data.get("session_id", ""))) or "unknown"

    os.makedirs(STATE_DIR, exist_ok=True)
    path = os.path.join(STATE_DIR, session)
    try:
        with open(path) as fh:
            count = int(fh.read().strip() or 0)
    except (OSError, ValueError):
        count = 0
    count += 1

    nudge = count >= EVERY
    with open(path, "w") as fh:
        fh.write("0" if nudge else str(count))

    # Drop counters from sessions idle for a week.
    cutoff = time.time() - 7 * 86400
    for name in os.listdir(STATE_DIR):
        p = os.path.join(STATE_DIR, name)
        if os.path.getmtime(p) < cutoff:
            os.remove(p)

    if nudge:
        print(json.dumps({"decision": "block", "reason": REASON}))


if __name__ == "__main__":
    try:
        main()
    except Exception:
        pass
    sys.exit(0)
