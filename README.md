# Second Brain for AI Agents

A folder of plain markdown files about you and your work that loads behind every agent session, whatever project folder you open. Works with Claude Code, Codex, and any agent that can read files. You stop re-briefing the agent, and your projects stay in their own folders.

## Quick start - one prompt

Paste this into Claude Code or Codex, in any folder. It sets the brain up and interviews you in the same session:

```text
Set up my second brain from https://github.com/sleekycee/second-brain and fill it in.

1. Clone the repo to a temporary folder and run its setup script for my operating system (setup.sh on macOS or Linux, setup.ps1 on Windows). If you cannot run scripts, follow the manual steps in the repo's README instead.
2. Show me what it created and changed.
3. Then interview me straight away, following setup-interview.md in my new brain folder: one question at a time, saving as we go, until the brain is filled in or I say stop.
```

Add "with the nudge hook" to the first line if you want the optional hook described further down.

The interview runs in the same session. The brain starts loading automatically in every session you open after that.

## How it works

```
secondbrain/                    the brain: knowledge about you, not your code
  CLAUDE.md                     who you are + rules, loaded in every session
  index.md                      map of every file, loaded in every session
  what-ive-built.md             dated log of what you ship
  setup-interview.md            the interview that fills the brain in
  context/                      facts that stay true: role, people, goals, preferences
  projects/                     notes per company or area
  sources/                      files you drop in (CV, decks); read, never edited
```

The brain is one folder. Each agent is told where it is through that agent's own global instructions file:

| Agent | How the brain loads | Set up by the script |
|-------|---------------------|----------------------|
| Claude Code | Two `@import` lines in `~/.claude/CLAUDE.md` pull in the brain's `CLAUDE.md` and `index.md`. The folder is added to `permissions.additionalDirectories` in `~/.claude/settings.json`. | Yes |
| Codex | `AGENTS.md` has no import syntax, so a short pointer in `~/.codex/AGENTS.md` tells Codex to read the brain's two files at the start of each session. | Yes, when `~/.codex` exists |
| Any other agent | Paste the one-line pointer below into that agent's global or custom instructions. | No - one manual paste |

The brain's own `CLAUDE.md` uses full paths, tells the agent to open deeper files only when a task needs them, and tells it to save durable facts back. Despite the filename, it is plain markdown any agent can follow.

No plugin, no hook, no server. Plain files you own.

## Set it up

### Option A - run the script

Clone the repo first (any OS):

```bash
git clone https://github.com/sleekycee/second-brain.git
```

**macOS / Linux** - brain goes to `~/Documents/secondbrain`:

```bash
./second-brain/setup.sh
```

**Windows** (PowerShell) - brain goes to `%USERPROFILE%\secondbrain`, outside Documents so OneDrive does not sync it:

```powershell
powershell -ExecutionPolicy Bypass -File .\second-brain\setup.ps1
```

To put the brain somewhere else, pass a folder:

```bash
./second-brain/setup.sh ~/brain
```

```powershell
powershell -ExecutionPolicy Bypass -File .\second-brain\setup.ps1 -BrainDir D:\brain
```

Both scripts never overwrite an existing file, back up `settings.json` to `settings.json.bak`, and are safe to run twice. A folder under your home folder is written as `~/...`, so a space in your username is fine; a space anywhere else in the path is refused.

Installed Codex after running the script? Run it again; it adds the Codex pointer and changes nothing else.

### Option B - give your agent the manual steps

The quick-start prompt at the top is the short way. Use this longer one when the agent cannot clone the repo or run scripts. Works in any agent that can edit files, on any OS. On Windows, replace `~/Documents/secondbrain` with `~/secondbrain`. Paste it as is:

```text
Set up a second brain for me, following https://github.com/sleekycee/second-brain.

1. Create the folder ~/Documents/secondbrain with: CLAUDE.md, index.md,
   what-ive-built.md, setup-interview.md, and empty folders context/, projects/
   and sources/. Copy the file contents from the repo's template/ folder and
   replace every __BRAIN__ with the folder's path. Do not overwrite any file
   that already exists.
2. Make it load in every session of the agent I am using right now:
   - Claude Code: add these two lines to ~/.claude/CLAUDE.md, keeping
     everything already in it:
       @~/Documents/secondbrain/CLAUDE.md
       @~/Documents/secondbrain/index.md
     Then add the folder's full path to permissions.additionalDirectories in
     ~/.claude/settings.json. Keep every other setting. Back the file up first.
   - Codex: append a short "Second brain" section to ~/.codex/AGENTS.md that
     says to read the folder's CLAUDE.md and index.md at the start of every
     session and follow them. Use the folder's full path.
   - Any other agent: tell me which global instructions file or setting you
     read at startup, and add the same pointer there.
3. Show me what you changed, then run the setup interview in
   setup-interview.md.
```

If you already cloned this repo, the short version is enough:

```text
Run the setup script from the second-brain repo I cloned, then run the setup interview.
```

### Any other agent - the one-line pointer

For Cursor, Gemini CLI, Copilot, ChatGPT custom instructions or anything else, paste this into the agent's global or custom instructions, with your own path:

```text
My second brain is at /full/path/to/secondbrain/. At the start of every session, read CLAUDE.md and index.md in that folder and follow them.
```

The agent needs file access to that folder. A chat app with no file access cannot read it; attach or paste `CLAUDE.md` and `index.md` there instead.

### Codex: let it save to the brain

Codex can read the brain from any project. In its default sandbox it can only write inside the current workspace, so saving back needs the brain listed as a writable root in `~/.codex/config.toml`:

```toml
[sandbox_workspace_write]
writable_roots = ["/full/path/to/secondbrain"]
```

The script does not edit `config.toml`. Without this, Codex asks for approval each time it saves to the brain.

## Fill it in

Open a **new** agent session in any folder and say:

```text
run the setup interview
```

It asks one question at a time and saves as you go. Give long answers; voice dictation works well. Stop whenever you like and it picks up the gaps next time.

Shortcuts:

- Drop your CV or LinkedIn PDF into `sources/` first.
- Paste your ChatGPT or Claude memory export and say "sort this into my second brain".

## Does it update itself?

Partly. Be clear on what is automatic and what is not.

- **Reading is automatic.** Every new session starts with the brain's `CLAUDE.md` and `index.md` loaded.
- **Writing is instruction-driven, not guaranteed.** The brain tells the agent to save durable facts, register new project folders and file new material from `sources/`. Agents follow this most of the time, and tell you in one line when they do. Nothing forces it, and a session that ends abruptly saves nothing.
- **To be sure, say it.** "Update my brain with what we settled" at the end of a session always works. So does "save this to my brain" at any point.
- **Nothing runs in the background.** No process watches your folders. A file dropped into `sources/` is picked up the next time a session notices it or you mention it.

### Optional extra: a nudge hook (Claude Code only)

`extras/brain-nudge.py` makes saving more reliable. Every 6th time Claude finishes a turn in a session, it is asked: anything durable settled since the last check? It then saves to the brain and tells you in one line, or replies "Brain: nothing new."

It is off by default. Turn it on with a flag when you run the setup script, first time or any later time:

```bash
./second-brain/setup.sh --with-hook
```

```powershell
powershell -ExecutionPolicy Bypass -File .\second-brain\setup.ps1 -WithHook
```

The flag copies the script to `~/.claude/hooks/brain-nudge.py` and registers it as a `Stop` hook, keeping any hooks you already have. Running it again does not add a second copy; it repoints the existing one at the brain folder you pass.

To add it by hand instead, copy the file somewhere permanent and register it under `hooks` in `~/.claude/settings.json`, keeping any hooks already there:

```json
"Stop": [
  {
    "hooks": [
      {
        "type": "command",
        "command": "python3 /full/path/to/brain-nudge.py /full/path/to/secondbrain",
        "timeout": 10
      }
    ]
  }
]
```

Or ask your agent:

```text
Install extras/brain-nudge.py from the second-brain repo as a Stop hook in my ~/.claude/settings.json, pointing it at my second brain folder. Keep my existing hooks.
```

What to expect:

- Needs Python 3. On Windows the command is usually `python` or `py`, not `python3`; the flag picks whichever it finds and skips the hook with a warning if there is none.
- Costs one extra short reply every 6 turns. Change the number with the `BRAIN_NUDGE_EVERY` environment variable or the `EVERY` line in the script.
- A session shorter than 6 turns is never nudged. Say "update my brain" before closing those.
- It only applies to sessions started after you add it. To remove it, delete the `Stop` block.

## Use it

- In any project: "save this to my brain" files a fact in the right place.
- Ask "what do you know about me?" in a fresh session to check it is loading.
- Edit any file by hand. It is your folder.

## Keep in mind

- **Every session can read the brain**, including sessions opened in client or third-party repos. Keep passwords, API keys and anything under NDA out of it.
- **Work for several companies?** One folder each under `projects/`. For a strict client contract, keep a separate brain and do not load it globally.
- **Do not commit your filled-in brain to this repo.** This repo is the empty template. Your brain lives outside it.
- **Codex size limit.** Codex stops loading instruction files past 32 KiB combined. The pointer is one line, so this only matters if your own `AGENTS.md` files are already large.

## Undo

1. Claude Code: delete the two `@.../secondbrain/...` lines from `~/.claude/CLAUDE.md`, and remove the folder from `permissions.additionalDirectories` in `~/.claude/settings.json`.
2. Codex: delete the "Second brain" section from `~/.codex/AGENTS.md`.
3. Delete the brain folder if you no longer want it.

## Check the scripts

```bash
./test.sh
```

Runs each setup script against a throwaway home folder, several times, and checks nothing is overwritten or duplicated. The PowerShell script is checked too when `pwsh` is installed.

## License

MIT - see [LICENSE](LICENSE).
