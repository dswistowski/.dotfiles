"""Thin wrappers around `git` used by the gb subcommands."""

from __future__ import annotations

import subprocess
from dataclasses import dataclass
from datetime import datetime
from pathlib import Path


class GitError(RuntimeError):
    pass


def run(*args: str, cwd: Path | None = None, check: bool = True) -> str:
    result = subprocess.run(
        ["git", *args],
        cwd=cwd,
        capture_output=True,
        text=True,
    )
    if check and result.returncode != 0:
        raise GitError(f"git {' '.join(args)} failed: {result.stderr.strip()}")
    return result.stdout.strip()


def current_branch(cwd: Path | None = None) -> str:
    return run("branch", "--show-current", cwd=cwd)


def list_branches(cwd: Path | None = None) -> list[str]:
    output = run("branch", "--format=%(refname:short)", cwd=cwd)
    return [line for line in output.splitlines() if line]


@dataclass(frozen=True)
class Worktree:
    path: Path
    head: str
    branch: str | None
    locked: bool = False
    prunable: bool = False

    @property
    def is_detached(self) -> bool:
        return self.branch is None


def list_worktrees(cwd: Path | None = None) -> list[Worktree]:
    output = run("worktree", "list", "--porcelain", cwd=cwd, check=False)
    worktrees: list[Worktree] = []
    path: Path | None = None
    head = ""
    branch: str | None = None
    locked = False
    prunable = False

    def flush() -> None:
        nonlocal path, head, branch, locked, prunable
        if path is not None:
            worktrees.append(Worktree(path, head, branch, locked, prunable))
        path, head, branch, locked, prunable = None, "", None, False, False

    for line in output.splitlines():
        if not line:
            flush()
            continue
        key, _, value = line.partition(" ")
        match key:
            case "worktree":
                flush()
                path = Path(value)
            case "HEAD":
                head = value
            case "branch":
                branch = value.removeprefix("refs/heads/")
            case "detached":
                branch = None
            case "locked":
                locked = True
            case "prunable":
                prunable = True
    flush()
    return worktrees


def main_worktree_path(cwd: Path | None = None) -> Path:
    worktrees = list_worktrees(cwd)
    if not worktrees:
        raise GitError("no worktrees found")
    return worktrees[0].path


def worktrees_for_branch(branch: str, worktrees: list[Worktree]) -> list[Worktree]:
    return [w for w in worktrees if w.branch == branch]


def unmatched_worktrees(
    worktrees: list[Worktree], branches: list[str]
) -> list[tuple[Worktree, str]]:
    """Worktrees that don't correspond to any local branch, with a `kind` label."""
    result: list[tuple[Worktree, str]] = []
    for w in worktrees:
        if w.branch is not None and w.branch in branches:
            continue
        match w.prunable, w.locked:
            case True, _:
                kind = "prunable"
            case _, True:
                kind = "locked"
            case _:
                kind = "detached"
        result.append((w, kind))
    return result


def worktree_is_dirty(path: Path) -> bool:
    if not path.exists():
        return False
    status = run("status", "--porcelain", cwd=path, check=False)
    return bool(status)


def default_branch(cwd: Path | None = None) -> str:
    symbolic = run("symbolic-ref", "-q", "refs/remotes/origin/HEAD", cwd=cwd, check=False)
    if symbolic:
        return symbolic.removeprefix("refs/remotes/origin/")
    branches = set(list_branches(cwd))
    for candidate in ("main", "master"):
        if candidate in branches:
            return candidate
    return "main"


def is_ancestor(ancestor: str, descendant: str, cwd: Path | None = None) -> bool:
    result = subprocess.run(
        ["git", "merge-base", "--is-ancestor", ancestor, descendant],
        cwd=cwd,
        capture_output=True,
        text=True,
    )
    return result.returncode == 0


def git_path(relative: str, cwd: Path) -> Path:
    resolved = run("rev-parse", "--git-path", relative, cwd=cwd)
    path = Path(resolved)
    return path if path.is_absolute() else cwd / path


def last_fetch_time(cwd: Path) -> datetime | None:
    fetch_head = git_path("FETCH_HEAD", cwd)
    if not fetch_head.is_file():
        return None
    return datetime.fromtimestamp(fetch_head.stat().st_mtime)


def unique_commit_count(base: str, ref: str, cwd: Path | None = None) -> int:
    output = run("rev-list", "--count", f"{base}..{ref}", cwd=cwd, check=False)
    try:
        return int(output)
    except ValueError:
        return 0


def get_remote_url(cwd: Path, remote: str = "origin") -> str | None:
    output = run("remote", "get-url", remote, cwd=cwd, check=False)
    return output or None


def has_unpushed_commits(cwd: Path) -> bool:
    remotes = run("remote", cwd=cwd, check=False)
    if not remotes:
        return False
    output = run("log", "--branches", "--not", "--remotes", "--oneline", cwd=cwd, check=False)
    return bool(output)


def is_git_repo(cwd: Path) -> bool:
    if not cwd.is_dir():
        return False
    output = run("rev-parse", "--is-inside-work-tree", cwd=cwd, check=False)
    return output == "true"


def home_path(path: Path) -> str:
    home = Path.home()
    try:
        return f"~/{path.relative_to(home)}"
    except ValueError:
        return str(path)
