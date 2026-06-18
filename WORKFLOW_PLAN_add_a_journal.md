# Workflow plan — "Add a new journal" to the COI policies site

*Drafted 18 June 2026; revised to make human verification the default. This is a plan for approval, not an executed change. Nothing in the live site or repo is modified until you sign off.*

## What you asked for

A public-facing function where any visitor can add a journal by name, and the site then, end to end: searches for the journal, identifies its governing conflict-of-interest policy, scores that policy, folds the result into the analysis, regenerates the HTML, and publishes. You chose **public submissions** and a move to a **data file plus generator** so the charts rebuild themselves. On scoring, we have refined the original "fully automated" choice: automation now *drafts* every addition instantly, but interpretive scores enter the published analysis only after your verification. This keeps the public "add a journal" button real and instant while honouring your commitment never to publish unverified scholarly judgement.

## The principle that drives the design

Split every addition into two layers:

- **Factual layer** — journal name, publisher, ISSN, policy URL, the verbatim policy text. These can be checked *mechanically* against Crossref and the live policy page, so they can be added automatically and shown immediately. Publishing them breaches nothing.
- **Interpretive layer** — the Explicit / Partial / Silent scoring across the seven dimensions. This is *your scholarly judgement*. It must never reach the canonical analysis unverified.

The commitment only bites on the second layer. So automation populates a **holding area**, not your analysis; verification is the act that promotes a record into the figures that carry your name. The two run on separate clocks — the public never waits, and you never publish a score you haven't stood behind.

## The one constraint that shapes everything

The site is **static** — three flat files (`academic_journals_coi_policies.md`, `index.html`, `push.command`) served by GitHub Pages. A static page cannot, on its own, search the web, call a model, or push to GitHub. So the build adds a thin compute layer *behind* the static site. The hosting stays exactly as it is; we bolt a pipeline onto the side.

A second fact worth stating plainly: today's scores are **your editorial reading**, authored by hand directly in `index.html`, and the heatmap is organised by *publisher framework* (Elsevier, Wiley, SAGE…), not by individual journal. The plan keeps your framework logic — most new journals simply inherit an existing publisher's row, which means most additions need no fresh scoring at all — and only invokes new scoring (and therefore your review) when a genuinely new framework appears.

## Proposed architecture (all free-tier)

```
Visitor on the live site
   │  types a journal name into an "Add a journal" form
   ▼
[1] Submission form  (static HTML/JS, on the existing Pages site)
   │  POST { journal name, optional ISSN/URL, optional email }
   ▼
[2] Serverless intake  (Cloudflare Worker — free tier)
   │  • spam / rate-limit / honeypot checks
   │  • holds the GitHub token (never exposed to the browser)
   │  • fires a repository_dispatch event
   ▼
[3] GitHub Action pipeline  (free tier, runs on dispatch)
   │  a. Resolve journal     → Crossref API (free): publisher, ISSN, homepage   ┐
   │  b. Identify COI policy  → publisher→framework lookup, else fetch page      │ FACTUAL
   │  c. Fetch + store policy text                                              ┘ (auto-verified)
   │  d. Known framework?  → inherit existing scores → publish immediately
   │     New framework?    → model drafts 7 scores + verbatim-quote evidence    ┐ INTERPRETIVE
   │  e. Open a PULL REQUEST with the drafted record (status: pending_review)   ┘ (held for you)
   ▼
[4] Two outputs
   │  • factual record + "scoring under review" badge → live immediately
   │  • interpretive scores → wait in the PR / pending tier until you verify
   ▼
[5] You review the PR (quote vs proposed score) → merge
   ▼
[6] Generator rebuilds index.html → Pages redeploys → entry enters the analysis
```

Running cost is effectively nil: Crossref and GitHub Actions are free, Cloudflare Workers has a generous free tier, and the model call is a few pence per journal, only on new frameworks.

## The 7 dimensions (unchanged from your current analysis)

Study funding · In-kind contributions · Individual shares · Prior work experience · Personal work contacts · Gifts from companies · Association invitations. Each scored **E / P / S** exactly as now.

## New data model

The analysis stops being hand-written and is driven by a structured file. One record per journal, with verification state as a first-class field:

```json
{
  "name": "Journal of Global Health",
  "publisher": "International Global Health Society",
  "issn": "2047-2986",
  "framework": "ICMJE / COPE baseline",
  "policy_url": "http://jogh.org/guidelines-for-authors/",
  "scores": {
    "study_funding": "E", "in_kind": "P", "individual_shares": "E",
    "prior_work": "P", "personal_contacts": "P", "gifts": "S", "association_invitations": "P"
  },
  "evidence": { "in_kind": "…verbatim quote from the policy…", "…": "…" },
  "verification": "editor_verified",   // machine_drafted | evidence_checked | editor_verified
  "source": "auto",                    // auto | editor
  "added": "2026-06-18"
}
```

The generator renders **only `editor_verified` records** into the canonical KPIs, bars, heatmap and mapping table. Records at `machine_drafted` / `evidence_checked` render into a separate, visibly badged "submitted — scoring under review" list. Promotion from one to the other is your merge.

The current 50 journals get migrated into this file once, as the seed corpus (all `editor_verified`, since they are already your reading). A small generator script then recomputes everything the page currently hard-codes — the four KPI numbers, the seven stacked bars, the framework × dimension heatmap, and the journal-to-framework mapping table — from `journals.json`.

## What happens on a single submission (runtime sequence)

1. **Resolve (factual).** Crossref lookup returns the canonical title, ISSN and publisher. No match → the submitter sees "couldn't find that journal — check the spelling or add the ISSN/URL", nothing is committed.
2. **Locate the policy (factual).** Known publisher → inherit that framework. New publisher → fetch the policy page.
3. **Known framework → publish.** The journal inherits an already-verified framework row, so it can enter the analysis immediately with no new judgement and no review needed. This is the common case.
4. **New framework → draft, don't publish.** The model reads the policy text and returns an E/P/S per dimension, **a verbatim supporting quote**, and (as triage only) a confidence. The prompt forbids any E or P without a quote; a score with no quote is auto-rejected. The record is saved as `machine_drafted`.
5. **Evidence check (mechanical).** The pipeline confirms each cited quote appears verbatim in the fetched policy text and flips passing records to `evidence_checked`. This catches fabricated quotes automatically but is *not* scholarly verification.
6. **Open a pull request** containing the drafted record and its quotes. The factual part of the entry goes live immediately with a "scoring under review" badge; the scores wait in the PR.
7. **You verify and merge.** You read the quote against the proposed score, adjust if needed, and merge. The generator rebuilds, Pages redeploys, and the entry enters the canonical analysis as `editor_verified`.

## How this honours "never publish unverified scholarly judgement"

- **The canonical analysis renders verified records only.** Anything a reader could mistake for your judgement has been through your sign-off.
- **Unverified additions are labelled as provisional and machine-drafted**, which reframes the speech act from *you asserting* to *a tool proposing* — outside the scope of the commitment.
- **Verification is cheap, so the queue stays clearable.** Evidence-bound scoring turns review into "does this quote support this score?" — a minute or two per new framework, not a re-reading of the whole policy.
- **Confidence is triage, not verification.** Model confidence is self-reported; a confidently wrong score still breaches the rule. Confidence only orders your queue (shaky drafts float to the top); it never auto-promotes a score.
- **Audit trail.** Every promotion is a merge commit, so provenance and reversibility are built in.

## Abuse safeguards (because the form is public)

Honeypot field, per-IP rate limiting and an optional lightweight CAPTCHA at the Worker; the GitHub token lives only server-side; duplicate-ISSN guard so the corpus can't be flooded with repeats.

## Build phases (what we'd do, in order, once you approve)

1. **Data migration.** Convert the existing 50 journals + your current scores into `data/journals.json`, all `editor_verified`. No behaviour change yet.
2. **Generator.** Write the build script that reproduces today's `index.html` *exactly* from that file, rendering only verified records. Diff old vs new HTML to prove the regeneration is faithful before anything else is added.
3. **Two-tier rendering.** Add the badged "scoring under review" list for non-verified records.
4. **Pipeline core.** Crossref resolver → framework lookup → (new-framework) scorer with quote evidence → mechanical evidence check → write record. Runnable by hand on a test journal first.
5. **Review queue.** Wrap drafts as pull requests; confirm merge → regenerate → publish works end to end.
6. **Automation + intake.** GitHub Action on `repository_dispatch`; Cloudflare Worker + the on-site form.
7. **Safeguards + provenance UI**, then a soft launch behind a link before going fully public.

Phases 1–3 carry no risk to the live site (pure refactor, verified by diff).

## Decisions still open (not blocking the plan, but needed before build)

- **Review cadence** — do you clear the queue ad hoc, or shall we add a weekly digest of pending PRs (a scheduled task) so nothing lingers?
- **Serverless host** — assumed Cloudflare Workers; Netlify or Vercel functions work identically if you prefer one.
- **Submitter email** — collect it (to notify them when their journal is verified and live) or keep submissions anonymous.
- **Anthropic API key** — the new-framework scorer needs one, stored as a GitHub Actions secret.
