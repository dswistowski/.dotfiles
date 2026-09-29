"""Rich-markup formatting helpers shared by the gb subcommands."""

from __future__ import annotations

from rich.markup import escape

from gb_cli import git
from gb_cli.gh import PullRequest


def pr_state_label(pr: PullRequest) -> str:
    match pr.state, pr.is_draft:
        case "OPEN", True:
            return "[dim yellow]DRAFT[/]"
        case "OPEN", False:
            style = "green"
        case "MERGED", _:
            style = "cyan"
        case "CLOSED", _:
            style = "red"
        case _:
            style = "white"
    return f"[{style}]{pr.state}[/]"


def pr_link(pr: PullRequest) -> str:
    return f"[link={pr.url}]#{pr.number}[/link]"


def pr_title(pr: PullRequest) -> str:
    return escape(pr.title)


def worktree_label(worktrees: list[git.Worktree]) -> str:
    if not worktrees:
        return ""
    paths = "".join(f"  [dim magenta]{escape(git.home_path(w.path))}[/]" for w in worktrees)
    return paths


def branch_label(branch: str, current: str, width: int = 30) -> str:
    marker = "*" if branch == current else " "
    plain = escape(f"{marker} {branch}")
    return f"[bold blue]{plain:<{width}}[/]"
