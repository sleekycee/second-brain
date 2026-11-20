# Setup Interview

Instructions for the agent. Run this when I say "run the setup interview" or "interview me".

## Rules

- First read `__BRAIN__/index.md` and every file it lists, plus anything in `sources/`. Never ask what a file already answers.
- Ask one question at a time. Build each question on my last answer.
- Save after every answer, in my own words. Mark anything you inferred as your reading, not as something I said.
- If I paste an export from another AI tool (ChatGPT or Claude memory), sort it into the files below instead of asking those questions again, and note it in `log.md` as `## [YYYY-MM-DD] ingest | baseline: <what it was>`.
- If there are files in `sources/`, ingest them first, following `__BRAIN__/wiki.md`.
- If I say this brain is work-only, leave personal details out and add a "Scope: work only" line to `CLAUDE.md`.
- I can stop any time. Next time, check what is saved and continue with the gaps.

## What to cover, and where it goes

1. Who I am and what I do - `context/role-profile.md` (name, role, employer or business, scope, skills, who I report to, who reports to me).
2. The people I work with - `context/people.md` (name, role, how I work with them).
3. My environment - `context/environment.md` (tools, systems, and facts you must never get wrong).
4. How I like work done - `context/working-preferences.md` (response style, document standards, brand rules, tool opinions).
5. My goals - `context/goals.md` (what I want, why now, constraints, dates, what is out of scope).
6. My projects - one file per area under `projects/<company-or-area>/`. If I have code repos, also write `projects/<company-or-area>/repos.md` mapping each project to its repo and local folder.

## When done

- Fill in "Who I am" and "Always" in `CLAUDE.md`, 3 to 6 lines each. That file loads in every session, so keep it short.
- Update `index.md` with one line per file.
- Add a line to `log.md`: `## [YYYY-MM-DD] setup | interview complete`.
- Tell me which files you wrote and what is still missing.
- Suggest 3 to 5 documents I probably have that would add the most (my team's plan, recent meeting notes, a performance review, a project spec) and offer to ingest one now.
- End with: "Second brain interview complete."
