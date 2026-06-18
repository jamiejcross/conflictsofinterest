# Prompt Log — Conflict of Interest Policies project

A verbatim record of the prompts that shaped this project, in order, with a short note on what each iteration produced.

---

### 1 · Initial request

> produce a textual analysis of conflict of interest policies across ~50 academic journals in this .md file; identify opportunities for tightening policies to declarations around: study funding, and in-kind contributions,, individual shares in companies, previous work experience with companies, personal work contacts, gifts received from companies, invitations from professional associations. Generate an .html output with a graphical visualisation of the analysis.

*Produced:* `coi_policy_analysis.html` — a regulatory-gap analysis of the 50 journals mapped onto ~12 distinct publisher/ICMJE policy frameworks, scored against the seven declaration dimensions (Explicit / Partial / Silent), with a stacked-bar summary, a coverage heatmap, written analysis and tightening recommendations, and a journal-to-framework mapping table.

---

### 2 · Connect to GitHub

> connect this folder to this github repo https://github.com/jamiejcross/conflictsofinterest

*Outcome:* Local git setup was attempted; the mounted folder blocked git's lock files, so the half-built repo was removed and a clean, native Terminal command sequence was provided instead. The repo's existing files (`README.md`, `academic_journals_coi_policies.md`) were pulled into the folder.

---

### 3 · Pages note

> pages for this folder is already enabled

*Outcome:* Confirmed that once pushed, `index.html` would render automatically at the GitHub Pages URL — no extra configuration needed.

---

### 4 · Push script

> create a push command script in the folder, tell me when its done and give me the link

*Produced:* `push.command` — a double-clickable macOS script that initialises git, links the repo, commits all files, and pushes. Live link: https://jamiejcross.github.io/conflictsofinterest/

---

### 5 · Public-facing rewrite

> Rewrite the page as an outward facing website for a public audience, so remove references to "the user" - use the title Conflict of Interest Policies in Academic Publishing - turn background black and use the Google open font Questrial - complete and push

*Produced:* Rewrote `coi_policy_analysis.html` and synced `index.html` — public-facing voice (all second-person / "the user" phrasing removed), title set to **Conflict of Interest Policies in Academic Publishing**, black background, and the Google font **Questrial** applied throughout.

---

### 6 · This log

> out my original prompts and iterations as an .md and save to the folder

*Produced:* `prompt_log.md` (this file).

---

## Files in this folder

| File | Purpose |
|------|---------|
| `coi_policy_analysis.html` | The analysis as a standalone public-facing web page |
| `index.html` | Identical copy; the homepage served by GitHub Pages |
| `academic_journals_coi_policies.md` | Source list of the 50 journals and their COI policy links |
| `README.md` | Repository readme |
| `push.command` | Double-click to publish the folder to GitHub |
| `prompt_log.md` | This prompt history |
| `.gitignore` | Ignores macOS `.DS_Store` files |
