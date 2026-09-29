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


def pr_view(branch: str, cwd: Path | None = None) -> PullRequest | None:
    result = subprocess.run(
        ["gh", "pr", "view", branch, "--json", "number,title,state,isDraft,url"],
        cwd=cwd,
        capture_output=True,
        text=True,
    )
    if result.returncode != 0:
        return None
    data = json.loads(result.stdout)
    return PullRequest(
        number=data["number"],
        title=data["title"],
        state=data["state"],
        is_draft=data["isDraft"],
        url=data["url"],
    )
