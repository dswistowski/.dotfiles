"""Thin wrapper around `gh pr view`."""

from __future__ import annotations

import json
import subprocess
from dataclasses import dataclass
from pathlib import Path


@dataclass(frozen=True)
class PullRequest:
    number: int
    title: str
    state: str
    is_draft: bool
    url: str


def _pull_request_from_json(data: dict[str, object]) -> PullRequest:
    return PullRequest(
        number=int(data["number"]),
        title=str(data["title"]),
        state=str(data["state"]),
        is_draft=bool(data["isDraft"]),
        url=str(data["url"]),
    )


def pr_view(branch: str, cwd: Path | None = None) -> PullRequest | None:
    result = subprocess.run(
        ["gh", "pr", "view", branch, "--json", "number,title,state,isDraft,url"],
        cwd=cwd,
        capture_output=True,
        text=True,
    )
    if result.returncode != 0:
        return None
    return _pull_request_from_json(json.loads(result.stdout))


def merged_pr_for_branch(branch: str, cwd: Path | None = None) -> PullRequest | None:
    """Find a merged PR for `branch` when `gh pr view` does not resolve one."""
    result = subprocess.run(
        [
            "gh",
            "pr",
            "list",
            "--head",
            branch,
            "--state",
            "merged",
            "--json",
            "number,title,state,isDraft,url",
            "--limit",
            "1",
        ],
        cwd=cwd,
        capture_output=True,
        text=True,
    )
    if result.returncode != 0:
        return None
    items = json.loads(result.stdout)
    if not items:
        return None
    return _pull_request_from_json(items[0])
