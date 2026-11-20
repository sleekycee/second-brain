# How This Wiki Runs

Instructions for the agent. The brain follows the LLM-wiki pattern: instead of piecing me together from scratch in every chat, you fold each new document into pages you keep current, so what you know builds up.

Three layers:

- Raw sources - `sources/`. My originals. Read, never edit.
- The wiki - `context/` and `projects/`. Pages you write and keep current.
- The rules - `CLAUDE.md` and this file.

Plus `index.md` (the map, read first) and `log.md` (a dated diary, newest at the bottom).

## Ingest a document

Run when I say "ingest [file]" or say yes to your offer.

1. Check first. If the document holds personal details about other people, or confidential material, say so before going further and ask: leave it out, summarise without names, or check my organisation's AI rules first. Never copy passwords, keys or tokens into the brain.
2. Save the original to `sources/` if it is not there, with a clear name and its date. Do not edit it afterwards.
3. Read it. If it is too long to read in full, say which parts you read in full and which you skimmed.
4. Tell me the 3 to 5 key points.
5. Update every page it affects. Only pages for the project or client it is about, never another's. Extend existing pages before creating new ones. Cite the source file on facts that came from it.
6. Do not add people's names or personal details to a people page without my yes.
7. Note the document's own date. If it is old, mark what you take from it as "as of [date]".
8. Show me anything it contradicts: both versions, side by side. Change nothing until I say which is right.
9. Update `index.md` and add a line to `log.md`: `## [YYYY-MM-DD] ingest | filename`.
10. Finish with the list of pages you changed, one line each.

## Save an answer as a page

Run when I say "save that as a page" or say yes to your offer.

- Put it under the right folder in `context/` or `projects/`. Extend an existing page if one fits.
- Write it so it stands alone: someone reading it without this chat should understand it.
- Add it to `index.md` and add a line to `log.md`: `## [YYYY-MM-DD] page | path`.

## Health check

Run when I say "run a health check" or say yes to your offer. About monthly.

1. Back up first: make a dated copy of the brain folder next to it and tell me where it is. If the brain is in git, that is the backup; if it is on GitHub, check the repository is private and stop if it is not.
2. Read every file except the originals in `sources/`. Judge files by their content, not their names.
3. Look for:
   - Duplication: the same fact in several files.
   - Conflicts: two files that disagree.
   - Stale content: "as of" dates long past, finished projects still marked active.
   - Orphans: files `index.md` does not list. Index lines pointing at missing files.
   - Bloat: `CLAUDE.md` over about 150 lines, or any page over about 300.
   - Sensitive content in `CLAUDE.md` or `index.md`, which load in every session.
   - Files in `sources/` that `log.md` does not list as ingested.
   - A second copy of the rules file, such as a lowercase `claude.md` or a sync app's "conflicted copy".
4. Report before touching anything: a short table (file - issue - fix), and the 2 or 3 changes that would help most, each with one line on how it helps me day to day.
5. Apply only what I approve. Move and merge; never delete. Anything retired goes to `_archive/`. For a conflict, show both versions and ask.
6. If a folder holds more than about 15 files, give it its own `index.md` and make the root `index.md` point to it.
7. Confirm nothing was lost, show before and after (file count, `CLAUDE.md` line count, duplicates removed), and add a line to `log.md`: `## [YYYY-MM-DD] health-check`.

## Log format

One line per event, newest at the bottom:

```
## [YYYY-MM-DD] setup | brain created
## [YYYY-MM-DD] ingest | q4-plan.pdf
## [YYYY-MM-DD] page | projects/acme/pricing-comparison.md
## [YYYY-MM-DD] health-check
```
