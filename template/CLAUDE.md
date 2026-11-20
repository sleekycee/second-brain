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
- `sources/` holds my originals (CV, decks, PDFs, exports). Read them, never edit them.
- `log.md` is a dated diary of changes to the brain.
- Do not read the brain's project notes into work for a different company or a third party's repo unless I ask.

## Small facts: save them yourself

- When a session in any project settles something durable - a decision, a stack change, a person's role, a preference - update the matching brain file and tell me in one line what you saved.
- When I say "save this", put it in the right file or create one, then update `__BRAIN__/index.md`.
- When I build or ship something, add a dated line to `__BRAIN__/what-ive-built.md`.
- When I start work in a project folder the brain does not know, add it to the right `projects/` file with its local path and repo.
- Extend an existing page before creating a new one. Keep pages small and focused.
- Never save session logs, task status, code, passwords, API keys or tokens.
- If something contradicts a brain file, show me both versions and ask which is right before changing either.

## Bigger moves: offer, then wait for my yes

Offer each at most once per chat, in one line.

- Ingest: when I share, paste or mention a document the brain does not have (a plan, deck, meeting notes, report), or there is a file in `sources/` that `log.md` does not list, offer to ingest it. On my yes, or "ingest [file]", follow `__BRAIN__/wiki.md`.
- File it back: when you produce something worth keeping (an analysis, comparison, plan, decision), offer to save it as a page.
- Health check: at the start of a session, if `log.md` shows a month or more since the last health check or since setup, offer one. On my yes, or "run a health check", follow `__BRAIN__/wiki.md`.
