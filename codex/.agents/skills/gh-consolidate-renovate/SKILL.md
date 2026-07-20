---
name: gh-consolidate-renovate
description: Consolidate multiple open Renovate dependency update pull requests into a single human-owned GitHub pull request. Use when the user asks to combine, squash, batch, supersede, replace, or merge Renovate PRs, or asks to make Renovate updates green, mergeable, and ready for review.
---

# Consolidate Renovate PRs

## Overview

Use this workflow to turn many Renovate PRs into one branch and one pull request with a clear audit trail, local validation, and green CI before merge.

Prefer the GitHub app tools for PR metadata and comments. Use `gh` only when it is already authenticated and it provides workflow status, mergeability, or branch operations that are easier than the connector.

## Workflow

1. **Start clean from default branch**
   - Fetch the latest remote refs.
   - Preserve unrelated local changes before switching branches.
   - Create a new branch from `origin/main`, named `codex/renovate-consolidated-YYYYMMDD` unless the user asks for another name.
   - Confirm the working tree is clean before applying Renovate changes.

2. **Inventory Renovate PRs**
   - List open PRs authored by `renovate[bot]` or branches matching `renovate/*`.
   - Capture PR number, title, head branch, base branch, dependency/package names, update type, status checks, mergeability, and whether the PR has conflicts.
   - Exclude PRs that are closed, target a non-default base, are security-sensitive in a way the user should review separately, or have failing tests caused by the dependency itself. Mention exclusions explicitly.

3. **Choose consolidation order**
   - Apply low-risk ecosystem/tooling updates first, then provider/runtime updates, then major or breaking updates.
   - Prefer PRs that touch disjoint lockfiles or version pins before conflicting ones.
   - If two Renovate PRs update the same dependency, keep only the newest version.
   - If a PR conflicts or is superseded, record the reason and continue with the compatible set.

4. **Apply changes**
   - For each selected PR, inspect the diff before applying it.
   - Prefer `git cherry-pick -x <renovate-pr-head-sha>` when the PR has a simple single commit.
   - Use patch application or manual edits when a Renovate branch has generated commits, conflict-heavy history, or changes that need combining with a newer dependency version.
   - Resolve conflicts deliberately; do not keep duplicate version pins or stale lockfile entries.
   - For `uv.lock`, preserve the existing `[options].exclude-newer` value exactly. It is a malware-supply-chain guardrail sourced from `pyproject.toml`; do not relax, remove, regenerate to a sentinel value, or otherwise change it while consolidating dependency updates.
   - After each applied PR, run a cheap sanity check such as `git diff --check` and inspect changed files.

5. **Validate locally**
   - Run the repository's normal formatting and validation commands.
   - For this repo, read `references/iac-validation.md` before validating.
   - If validation fails, diagnose the first failing signal and fix it before adding more updates.
   - Commit only after local validation is passing or after clearly documenting a blocker that cannot be reproduced locally.

6. **Open the consolidated PR**
   - Commit with a message like `chore: consolidate renovate updates`.
   - Push the branch.
   - Open a draft PR against `main` with:
     - the list of included Renovate PRs,
     - excluded PRs with reasons,
     - local validation commands and results,
     - any dependency-specific risk notes.

7. **Make it green and mergeable**
   - Wait for CI and inspect failing jobs instead of guessing.
   - Fix failures on the consolidated branch, then push updates.
   - Confirm the PR is up to date with `main`, has no merge conflicts, required checks are green, and review requirements are satisfied.
   - Mark the PR ready only when it is genuinely mergeable.
   - After the consolidated PR merges, close superseded Renovate PRs with a short comment linking the replacement PR.

## Guardrails

- Never merge individual Renovate PRs while building the consolidated branch unless the user explicitly asks.
- Never force-push over a user's branch. Use a new `codex/` branch by default.
- Do not hide excluded or failed updates. A smaller green PR is better than a broad red one.
- Do not claim CI is green until the current pushed commit has completed required checks successfully.
- Treat major-version updates, Terraform provider changes, and GitHub Action pin changes as review-worthy even when tests pass.
- Never change `exclude-newer` in `uv.lock`. If a resolver command rewrites it, restore the prior value before committing and verify the PR diff does not include an `exclude-newer` change.

## Useful Commands

```bash
git fetch origin
git switch -c codex/renovate-consolidated-$(date +%Y%m%d) origin/main
gh pr list --state open --author app/renovate --json number,title,headRefName,baseRefName,mergeable,statusCheckRollup,url
gh pr checkout <number>
git show --stat --oneline HEAD
git cherry-pick -x <sha>
git diff --check
gh pr create --draft --base main --head <branch> --title "chore: consolidate renovate updates" --body-file <body-file>
gh pr checks <number> --watch
```
