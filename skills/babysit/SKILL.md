---
name: babysit
description: Rebase, test, and clear one GitLab merge request; hand off when only human approval remains.
argument-hint: "GitLab merge request URL or IID"
disable-model-invocation: true
---

# Babysit a GitLab merge request

Run this after the user opens a merge request and provides its URL or IID. Stay on that MR through CI and review cleanup. Hand off when GitLab reports it mergeable, or when all agent work is done and only human review actions remain. Never merge the MR or enable auto-merge.

The invocation authorizes rebasing the MR source branch, making and committing fixes, and pushing them. A rebase rewrite may be pushed only with `--force-with-lease`. Human review threads stay unresolved for their authors to resolve.

Before posting any GitLab reply or final report, load and apply the `unslop` skill. Preserve Monocle's machine-readable markers and required values.

## 1. Pin the MR and start event tracking

Run from the MR's repository root. Read its `AGENTS.md`, `README.md`, and the commands it documents. Resolve a URL to its project and IID; for a bare IID, confirm it belongs to the current repository. `helis` resolves `:id` from the current Git remote, so stop if the remote and MR project do not match or the right source/target remotes are unclear.

Before the first status snapshot, connect to the GitLab Reactor stream from the VPN:

```sh
curl -sS -N https://gitlab-events.eneba.engineering/stream
```

Keep one stream open and act only on events whose `mr_url` is this MR's URL. It needs no token. `-sS` suppresses curl's progress meter while preserving errors. Use the stream as a wake-up signal, not as the source of current state. It sends pipeline success/failure, new notes, approvals, merges, and closes; it has no Monocle-complete event and does not replay missed events after disconnect. Monocle grading replies are not emitted as note events. On reconnect, follow the advertised retry delay and re-read the MR, head pipeline, and open discussions before acting. Ignore events for old SHAs. If the MR is merged or closed, stop.

Take a compact initial snapshot:

```sh
helis gitlab mr view <iid> -F json | jq '{source_branch, target_branch, web_url, sha, draft, state, detailed_merge_status, head_pipeline: {id: .head_pipeline.id, status: .head_pipeline.status, sha: .head_pipeline.sha}}'
```

Record the source branch, target branch, MR URL, current SHA, draft state, and head pipeline. Get the current user's GitLab username with `helis gitlab api user` so your own replies are not mistaken for new review work.

Stop before changing anything if the worktree is dirty. Show `git status --short` and ask the user what to do; do not stash, reset, or overwrite their work.

## 2. Rebase the source branch onto the target

Verify the local source branch and remote against the MR, fetch the target branch, then rebase the source branch onto the fetched target. Use the repository's documented remote names; do not assume `origin` contains both branches when the MR comes from a fork.

Resolve conflicts that have a clear, mechanical answer by reading both sides and checking the result. Run relevant tests. If the conflict requires a product or behavior decision, stop and ask the user rather than guessing. Never overwrite an unexpected remote update: fetch and inspect it before pushing.

If the rebase rewrote the source branch, push that branch with `git push --force-with-lease`. Otherwise, do not force-push. Record the resulting MR head SHA. This push starts a new pipeline and may start a Monocle review.

## 3. Get CI green for the current head

The gate is the head pipeline for the MR's current SHA, not a green pipeline from an older commit. On a pipeline event, compare its `sha` to the MR's current SHA and refresh MR state before relying on it.

Immediately after a push, `head_pipeline` on the MR object may still refer to the previous run. Query the latest pipeline for the source branch and verify its SHA:

```sh
helis gitlab api "projects/:id/pipelines?ref=<source-branch>&per_page=1" | tail -1 | jq '.[0] | {id, sha, status, web_url}'
```

If CI fails, inspect every failed non-allowed job and its log before changing code:

```sh
helis gitlab api --paginate "projects/:id/pipelines/<pipeline-id>/jobs?per_page=100"
helis gitlab ci trace <job-id>
```

Fix failures caused by the MR. Retry a clear infrastructure/transient failure once. If the same failure remains after the fix or retry, or its cause is outside the MR and unclear, stop and ask the user. Run the repository's relevant tests and checks before committing.

Do not push while Monocle is actively reviewing the current SHA; a push can cancel its review. Before any push, check the matching-SHA state described in step 4. If that run is active, keep fixes local and wait. Batch fixes for that head into one commit. A normal follow-up fix uses a normal push. Restart this gate for the new SHA and do not inspect review threads until its pipeline is green.

Wait on matching `pipeline_succeeded` / `pipeline_failed` events. If the stream disconnects, reconnect and snapshot current state. Do not repeatedly fetch job lists while the pipeline is pending.

## 4. Wait for Monocle to finish on the green SHA

Read the MR description with `helis gitlab api "projects/:id/merge_requests/<iid>"`. Parse the `<!-- monocle:state {...} -->` block and select the run whose `head_sha` equals the current MR SHA. `ended_at` means that run completed; `cancelled_at` means it did not complete. A draft MR may skip Monocle. Never treat a missing state or a run for another SHA as completion.

While the matching run is active, keep listening to the event stream and check this state every five minutes as a fallback. Do not push during the run. If the run was cancelled, refresh the MR head and state, then wait for the run for the current SHA.

If no run is recorded for the current SHA, do not claim Monocle is complete. If a previous completed run produced findings and a tested fix batch is ready, fetch a fresh complete discussion snapshot and proceed to step 6. Do not wait for Monocle to review an unchanged remote SHA when the fixes are still local; the push will start a review of the new SHA. If no assessed fix batch is ready, keep checking for the run every five minutes. Send a user update when the state changes, not for each unchanged fallback.

Before handling findings, fetch **all** discussions, including every page, from the current MR:

```sh
helis gitlab api --paginate "projects/:id/merge_requests/<iid>/discussions?per_page=100"
```

Inspect every unresolved, non-system thread and every new note since the prior snapshot. Do not skip a thread because it already has a reply: determine whether the latest note contains a response from you to the current ask. Avoid duplicate replies. Re-snapshot if a `note_created` event arrives before the next push.

## 5. Assess human threads and Monocle findings

### Human-authored threads

Read the relevant code, callers, tests, and repository rules. Decide whether the reported defect exists and whether the MR should change.

- If a fix is needed, include it in the current batch, test it, commit, and push before replying with the short SHA and evidence.
- If no code change is needed, reply with the decision and the evidence checked. Also reply when it is already fixed or when a safe, factual clarification answers the reviewer.
- If the thread needs a product decision, ask the user. Continue independent safe work, but do not guess or claim the thread is addressed.
- **Never resolve a human thread.** Leave that action to the reviewer, even after your fix and reply.

### Monocle findings

Use the Monocle notice on this MR as the grading contract. If it is unavailable, fetch the reference notice with `helis`:

```sh
helis gitlab api 'projects/d5100%2Fservices%2Feneba-pay%2Fcore-ledger/merge_requests/89/notes/4028144674'
```

Apply the grading contract only to comments containing a `<!-- monocle:finding {...} -->` marker. A general Monocle notice or status comment is not a finding. For each finding, verify the named defect in code and tests, decide whether to fix it, and assess whether its severity is correct. In the same thread, say what you checked and provide:

- `valid`: `true` or `false`
- `addressed`: `yes`, `partial`, or `no`
- `importance`: `correct`, `overstated`, or `understated`

Copy the finding's `fp` from its marker. Because this skill is acting as an agent, include a machine-readable HTML comment on its own line in the reply:

```html
<!-- monocle:reply {"fp":"<fingerprint>","valid":true,"addressed":"yes","importance":"correct"} -->
```

Use the values supported by your assessment. Omit any key you cannot judge; do not turn uncertainty into agreement. Reply to every finding. Fix valid findings that should be addressed in this MR. Resolve a resolvable Monocle finding only after its fix is committed and pushed and its reply says `addressed: "yes"`. Leave invalid, partially addressed, or unaddressed findings open. Non-resolvable Monocle notes cannot be resolved.

## 6. Batch, verify, commit, push, and reply

CI failures are handled in step 3 before review threads are read. For one complete post-Monocle discussion snapshot, batch all safe code fixes from human and Monocle findings together; do not make one push per thread. If there is no code change, do not create an empty commit.

Before committing, run the relevant tests and the repository's required checks, inspect the complete diff, and confirm no unrelated files changed. Commit once for the batch using the repository's commit conventions. Push once. Use `--force-with-lease` only if this batch includes a rebase rewrite; otherwise use a normal push. If the remote head moved unexpectedly, stop and resnapshot instead of overwriting it.

After the push, reply on the addressed human and Monocle threads. Keep replies concise and evidence-based. Human threads remain unresolved. Resolve only the eligible Monocle findings described above. A reply with no code change does not require a commit.

Post replies through the discussion API, preserving the same thread:

```sh
helis gitlab api -X POST \
  "projects/:id/merge_requests/<iid>/discussions/<discussion-id>/notes" \
  -f "body=<reply>"
```

Resolve only an eligible Monocle finding after its pushed fix:

```sh
helis gitlab api -X PUT \
  "projects/:id/merge_requests/<iid>/discussions/<discussion-id>" \
  -F resolved=true
```

The push starts a new head pipeline and may start another Monocle run. Repeat the CI gate, matching-SHA Monocle wait, and complete discussion snapshot only for new or changed work. Do not re-fix or re-reply to an item whose current request was already addressed.

## 7. Stop, run retro, and report

Stop successfully when the latest head pipeline is green, Monocle is complete (or skipped because the MR is a draft), all current findings have been assessed and replied to, all human threads have a substantive reply, and GitLab reports the MR mergeable. Never merge or enable auto-merge.

If all agent work is complete and only human review actions remain, hand off instead of polling indefinitely. Leave human threads unresolved for their authors. For approval-only blockers, read the approval rules and report which approvals remain:

```sh
helis gitlab api "projects/:id/merge_requests/<iid>/approval_state" | tail -1 | jq '{rules: [.rules[] | select(.approved == false) | {name, required: .approvals_required, approved_by: [(.approved_by // [])[] | .username]}]}'
```

Resume monitoring only if the user asks. Stop and ask the user if work depends on a product decision or a repeated/ambiguous failure.

### Required retrospective

Before every terminal report, read `~/.agents/skills/retro/SKILL.md` and apply its workflow to the current babysit session. Follow it inline because `retro` is user-invoked-only. This applies to merge-ready completion, human-only handoff, an MR that merged or closed, a blocker, and user cancellation. A monitoring wait is ongoing work, not completion; retain observations for the terminal retro instead of repeating it on each wake-up.

Use the session's tool results, timings, diffs, and review outcomes as evidence. Reuse snapshots already collected; fetch more only to verify a candidate improvement. Focus on avoidable test reruns, command timeouts, redundant reads or API calls, monitoring gaps, stale-SHA or pagination mistakes, and missed or duplicate review replies.

Rank actionable improvements by impact. For each, name the observed problem, the smallest proposed change and its target file or tool, and how a future run would verify the benefit. Check existing checks and instructions before proposing another. Put mechanical safeguards in automated checks rather than adding prose rules.

Include a short `Retro` section in the final report, or state that no actionable improvement was found. Ask for approval before changing skills, instructions, or tooling outside the user's current authorization. A retro does not authorize self-modification or another MR push.

### Final report

Report the final head SHA, pipeline ID/status for that SHA, Monocle result for that SHA, GitLab mergeability, any remaining approval rules, each discussion's outcome/reply/resolve status, and `git status --short`. State clearly if the MR is still blocked by a human action.
