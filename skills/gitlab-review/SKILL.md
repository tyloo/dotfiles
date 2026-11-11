---
name: gitlab-review
description: Review a colleague's GitLab merge request with two independent models, then post verified, concise inline findings. Use when asked to review an MR or leave review comments in GitLab.
argument-hint: "<GitLab MR URL or IID>"
disable-model-invocation: true
---

# Review a GitLab merge request

Run this only when the user asks for a review. It may create new inline discussion threads. It never changes code, pushes commits, approves, resolves discussions, or merges.

## 1. Pin the merge request

Run from the repository root. Read its `AGENTS.md` and `README.md`. Require a GitLab MR URL or IID. Resolve it with `helis gitlab mr view <iid> -F json`, confirm that its project matches the current Git remote, and record the project, IID, URL, source and target branches, and head SHA. Stop if the project or MR is ambiguous.

Fetch all diff versions with `helis gitlab api --paginate "projects/:id/merge_requests/<iid>/versions?per_page=100"`. Select the version whose `head_commit_sha` matches the recorded head. Use its `start_commit_sha` as the fixed point and its `head_commit_sha` as the end of the review. Capture the diff as `git diff <start_commit_sha>...<head_commit_sha>` and the commit list as `git log <start_commit_sha>..<head_commit_sha> --oneline`. Fetch refs only after confirming which remote owns each branch. Do not check out branches or move the user's `HEAD`.

If the commit objects are not available locally, get the version details from `projects/:id/merge_requests/<iid>/versions/<version-id>?unidiff=true` and use that exact diff. If the version is incomplete or GitLab reports collapsed or oversized diffs, stop and tell the user rather than reviewing a partial change.

Fetch all existing discussions with `helis gitlab api --paginate "projects/:id/merge_requests/<iid>/discussions?per_page=100"`. Use them to avoid duplicate findings. Review only the MR diff at the recorded head SHA. If the head changes before comments are posted, discard the review and restart against the new SHA.

## 2. Review on two axes with two models

Load and follow the Matt Pocock `code-review` skill. Its Standards and Spec axes, fixed-point checks, spec discovery, and smell baseline define the review.

Use two fresh-context review agents in parallel. Check the available model list first and pin a different available model from a different provider or model family to each agent. Do not use the same model twice. If two distinct models are unavailable, ask the user before falling back.

- The **Standards** agent gets the exact MR diff and every applicable repository standard. Ask it to report only concrete standard violations or labelled baseline smells.
- The **Spec** agent gets the same diff and the originating issue or spec. Ask it to report missing or partial requirements, incorrect behavior, and scope creep.

Both agents must name the file and line, describe the failing behavior, and cite the evidence they used. Keep each report under 400 words. Do not show one agent the other's findings.

## 3. Verify and select findings

Independently inspect every candidate against the current diff, surrounding code, callers, tests, and spec. Post only findings that are both introduced by this MR and demonstrably wrong. A standards finding must cite a repository rule or be a clearly labelled, consequential smell. Treat smell-baseline items as judgement calls, not violations.

Combine duplicate findings about the same root cause. Skip preferences, speculative risks, issues outside the diff, findings already covered by an open thread, and comments without a concrete behavior and a useful diff line. Do not turn model agreement into evidence.

Write one short thread per verified issue, usually one to three sentences. State when it fails, the user-visible or system impact, and the smallest useful correction. Match any severity labels already used in the project. Keep the comment factual and specific, with no generic praise, summary, or style advice.

Before sending any review comment or final report, load and apply the `unslop` skill. Preserve technical facts, severity, and any required GitLab syntax.

## 4. Open inline GitLab threads

Refresh the MR and diff versions before posting. Confirm the head still matches the reviewed SHA. Use the matching version's `base_commit_sha`, `head_commit_sha`, and `start_commit_sha` for discussion positions. Fetch its diffs if needed to confirm paths and line numbers.

Create each thread with the GitLab Discussions API, through `helis gitlab api`. Use the current version's SHAs and exact diff paths. For an added line, send `position[new_line]` only. For a removed line, send `position[old_line]` only. For an unchanged line in the diff, send both. Never guess a position. If a finding has no valid diff position, do not post it as an inline thread. Mention it to the user instead.

```sh
helis gitlab api -X POST \
  "projects/:id/merge_requests/<iid>/discussions" \
  -f "body=<concise finding>" \
  -f "position[position_type]=text" \
  -f "position[base_sha]=<base_commit_sha>" \
  -f "position[head_sha]=<head_commit_sha>" \
  -f "position[start_sha]=<start_commit_sha>" \
  -f "position[old_path]=<old path>" \
  -f "position[new_path]=<new path>" \
  -f "position[new_line]=<new line>"
```

For deleted lines, replace `position[new_line]` with `position[old_line]`. For unchanged lines, include both line fields. Confirm each API response contains the new discussion before reporting success.

## 5. Report

Give the MR URL and pinned head SHA, the model IDs used, the number of threads opened with links where available, and any verified finding you held back because it could not be anchored to the diff. If no finding qualifies, say that no inline threads were opened. Do not call the MR approved or ready to merge.
