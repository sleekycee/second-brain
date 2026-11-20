# Second Brain

My second brain lives at `__BRAIN__/`: plain markdown files about me, my work and my goals. This file loads at the start of every agent session, whatever folder is open. Use it so I never have to re-brief you.

## Who I am

- Not filled in yet. If `__BRAIN__/context/role-profile.md` does not exist, tell me once and offer to run the setup interview in `__BRAIN__/setup-interview.md`.

## Always

- Add rules here that must hold in every session (tone, formatting, facts you must never get wrong).

## How to use the brain

- The brain is separate from my projects. My projects live in their own folders; the brain holds knowledge about them, not their code.
- The map is `__BRAIN__/index.md` (loaded with this file). Every path in it is relative to `__BRAIN__/`. Open only the files the task needs.
- `context/` holds facts about me that stay true (goals, role, people, environment, preferences).
- `projects/` holds notes on my work, one folder per company or area. Never mix one company's information into another's.
- `sources/` holds files I drop in (CV, decks, PDFs). Read them, never edit them.
- Do not read the brain's project notes into work for a different company or a third party's repo unless I ask.

## Writing back to the brain, from any project

- When I say "save this", put it in the right brain file or create one, then add or update its line in `__BRAIN__/index.md`.
- When a session in any project settles something durable - a decision, a stack change, a person's role, a preference - update the matching brain file before the session ends, and tell me in one line what you saved.
- When I build or ship something, add a dated line to `__BRAIN__/what-ive-built.md`.
- When I start work in a project folder the brain does not know, add it to the right `projects/` file with its local path and repo.
- When there is a new file in `sources/` that no brain file mentions, read it and file what matters.
- Do not save session logs, task status, code, passwords, API keys or tokens. Durable facts only.
- Keep files small and focused. Prefer updating an existing file over creating a near-duplicate.
- If something I say contradicts a brain file, ask which is right, then fix the file.
