# Second Brain for Claude Code

A folder of plain markdown files about you and your work that loads behind every Claude Code session, whatever project folder you open. You stop re-briefing the agent, and your projects stay in their own folders.

## How it works

```
~/Documents/secondbrain/        the brain: knowledge about you, not your code
  CLAUDE.md                     who you are + rules, loaded in every session
  index.md                      map of every file, loaded in every session
  what-ive-built.md             dated log of what you ship
  setup-interview.md            the interview that fills the brain in
  context/                      facts that stay true: role, people, goals, preferences
  projects/                     notes per company or area
  sources/                      files you drop in (CV, decks); read, never edited
```

Three things make it work from any folder:

1. Two import lines in `~/.claude/CLAUDE.md` load the brain's `CLAUDE.md` and `index.md` at the start of every session. About 70 lines of context.
2. The brain folder is added to `permissions.additionalDirectories` in `~/.claude/settings.json`, so any session can read and write it without a prompt.
3. The brain's `CLAUDE.md` uses full paths and tells the agent to open deeper files only when a task needs them, and to save durable facts back.

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

### Option B - give your agent this prompt

Works in Claude Code on any OS. On Windows, replace `~/Documents/secondbrain` with `~/secondbrain`. Paste it as is:

```text
Set up a second brain for me, following https://github.com/sleekycee/second-brain.

1. Create the folder ~/Documents/secondbrain with: CLAUDE.md, index.md,
   what-ive-built.md, setup-interview.md, and empty folders context/, projects/
   and sources/. Copy the file contents from the repo's template/ folder and
   replace every __BRAIN__ with the folder's path. Do not overwrite any file
   that already exists.
2. Add these two lines to my global ~/.claude/CLAUDE.md, keeping everything
   already in it:
   @~/Documents/secondbrain/CLAUDE.md
   @~/Documents/secondbrain/index.md
3. Add the folder's full path to permissions.additionalDirectories in
   ~/.claude/settings.json. Keep every other setting. Back the file up first.
4. Show me what you changed, then run the setup interview in
   setup-interview.md.
```

If you already cloned this repo, the short version is enough:

```text
Run setup.sh from the second-brain repo I cloned, then run the setup interview.
```

## Fill it in

Open a **new** Claude Code session in any folder and say:

```text
run the setup interview
```

It asks one question at a time and saves as you go. Give long answers; voice dictation works well. Stop whenever you like and it picks up the gaps next time.

Shortcuts:

- Drop your CV or LinkedIn PDF into `sources/` first.
- Paste your ChatGPT or Claude memory export and say "sort this into my second brain".

## Use it

- In any project: "save this to my brain" files a fact in the right place.
- The agent writes durable facts back on its own and tells you in one line.
- Ask "what do you know about me?" in a fresh session to check it is loading.
- Edit any file by hand. It is your folder.

## Keep in mind

- **Every session can read the brain**, including sessions opened in client or third-party repos. Keep passwords, API keys and anything under NDA out of it.
- **Work for several companies?** One folder each under `projects/`. For a strict client contract, keep a separate brain and do not import it globally.
- **Do not commit your filled-in brain to this repo.** This repo is the empty template. Your brain lives outside it.
- The any-session loading is Claude Code specific. Other agents can still read the folder if you open it or point them at it.

## Undo

1. Delete the two `@.../secondbrain/...` lines from `~/.claude/CLAUDE.md`.
2. Remove the folder from `permissions.additionalDirectories` in `~/.claude/settings.json`.
3. Delete the brain folder if you no longer want it.

## Check the script

```bash
./test.sh
```

Runs each setup script twice against a throwaway home folder and checks nothing is overwritten or duplicated. The PowerShell script is checked too when `pwsh` is installed.

## License

MIT - see [LICENSE](LICENSE).
