"""Business logic behind the gb subcommands (kept separate from click for testing)."""

from __future__ import annotations

import shutil
from pathlib import Path

from rich.console import Console
from rich.markup import escape

from gb_cli import config, git, render
from gb_cli.gh import pr_view

PROTECTED_BRANCHES = ("main", "master")


def show_branches(console: Console, cwd: Path) -> None:
    """List local branches with their GitHub PR status and worktree."""
    current = git.current_branch(cwd)
    branches = git.list_branches(cwd)
    worktrees = git.list_worktrees(cwd)

    for branch in branches:
        label = render.branch_label(branch, current)
        wt_label = render.worktree_label(git.worktrees_for_branch(branch, worktrees))
        pr = pr_view(branch, cwd)
        if pr is not None:
            console.print(
                f"{label} {render.pr_link(pr)} \\[{render.pr_state_label(pr)}\\] "
                f"{render.pr_title(pr)}{wt_label}"
            )
        else:
            console.print(f"[dim]{label}  (no PR)[/]{wt_label}")

    unmatched = git.unmatched_worktrees(worktrees, branches)
    if unmatched:
        console.print("\n[bold]Detached worktrees (no local branch)[/]")
        for wt, kind in unmatched:
            console.print(
                f"[dim]  {kind:<10}  {wt.head[:12]}[/]"
                f"  [dim magenta]{escape(git.home_path(wt.path))}[/]"
            )


def _removal_reason(branch: str, base: str, cwd: Path) -> str | None:
    pr = pr_view(branch, cwd)
    if pr is not None:
        if pr.state == "OPEN":
            return None
        if pr.state in ("MERGED", "CLOSED"):
            return f"#{pr.number} \\[{render.pr_state_label(pr)}\\] {render.pr_title(pr)}"
    if git.unique_commit_count(base, branch, cwd) == 0:
        return f"no unique commits vs {base}"
    return None


def _remove_worktrees_for_branch(
    console: Console, branch: str, worktrees: list[git.Worktree], main_worktree: Path
) -> bool:
    """Returns True if all worktrees for `branch` were removed (or there were none)."""
    branch_esc = escape(branch)
    for wt in git.worktrees_for_branch(branch, worktrees):
        path = escape(git.home_path(wt.path))
        if wt.path == main_worktree:
            console.print(f"[yellow]Skip[/] {branch_esc}: checked out in the main worktree")
            return False
        if git.worktree_is_dirty(wt.path):
            console.print(f"[yellow]Skip[/] {branch_esc}: dirty worktree {path}")
            return False
        try:
            git.run("worktree", "remove", str(wt.path), cwd=main_worktree)
        except git.GitError:
            console.print(f"[yellow]Skip[/] {branch_esc}: could not remove worktree {path}")
            return False
        console.print(f"[dim]Removed worktree[/] {path}")
    return True


def clean_branches(console: Console, cwd: Path) -> None:
    """Delete local branches (and worktrees) that are merged, closed, or empty."""
    if not git.is_git_repo(cwd):
        console.print(f"[red]Error[/] not a git repository: {escape(git.home_path(cwd))}")
        raise SystemExit(1)
    main_worktree = git.main_worktree_path(cwd)
    base = git.default_branch(cwd)
    current = git.current_branch(cwd)
    branches = git.list_branches(cwd)
    worktrees = git.list_worktrees(cwd)

    for branch in branches:
        if branch == current or branch in PROTECTED_BRANCHES:
            continue
        reason = _removal_reason(branch, base, cwd)
        if reason is None:
            continue
        if not _remove_worktrees_for_branch(console, branch, worktrees, main_worktree):
            continue
        console.print(f"[dim]Deleting[/] [bold]{escape(branch)}[/] ({reason})")
        git.run("branch", "-D", branch, cwd=cwd)

    for wt, _kind in git.unmatched_worktrees(worktrees, branches):
        if wt.path == main_worktree:
            continue
        path = escape(git.home_path(wt.path))
        if git.unique_commit_count(base, wt.head, cwd) != 0:
            console.print(f"[yellow]Skip[/] detached worktree with unique commits: {path}")
            continue
        if git.worktree_is_dirty(wt.path):
            console.print(f"[yellow]Skip[/] dirty detached worktree {path}")
            continue
        try:
            git.run("worktree", "remove", str(wt.path), cwd=main_worktree)
        except git.GitError:
            console.print(f"[yellow]Skip[/] could not remove detached worktree {path}")
            continue
        console.print(f"[dim]Removed detached worktree[/] {path} (no unique commits vs {base})")

    console.print("\n[green]Done.[/]")


def _require_project(console: Console, cwd: Path) -> config.Project:
    try:
        project = config.project_for_cwd(cwd)
    except config.ConfigError as exc:
        console.print(f"[red]Error[/] {escape(str(exc))}")
        raise SystemExit(1) from exc
    if project is None:
        console.print(
            f"[red]Error[/] not inside a project: no {config.CONFIG_FILENAME} found in "
            f"{escape(git.home_path(cwd))} or its parents (see `gb init`)."
        )
        raise SystemExit(1)
    return project


def _clone_dirs(root: Path) -> list[Path]:
    return [p for p in sorted(root.iterdir()) if p.is_dir() and git.is_git_repo(p)]


def _resolve_targets(
    console: Console, cwd: Path, all_: bool = False, clone: str | None = None
) -> tuple[list[Path], bool]:
    """Decide which repo directories a multi-repo-capable command should run on.

    --clone NAME targets one specific clone by name; --all targets every
    clone under the enclosing project's root. With neither flag: running
    from the project root itself defaults to --all, running from inside a
    clone (or a plain, non-gb-managed repo) defaults to just that one repo.

    Returns the target directories plus whether they should be labeled
    (i.e. this is an --all-style, potentially-multi-clone run).
    """
    if all_ and clone:
        console.print("[red]Error[/] --all and --clone are mutually exclusive.")
        raise SystemExit(1)

    if clone:
        project = _require_project(console, cwd)
        target = project.root / clone
        if not git.is_git_repo(target):
            console.print(f"[red]Error[/] not a clone: {escape(git.home_path(target))}")
            raise SystemExit(1)
        return [target], False

    if all_:
        project = _require_project(console, cwd)
        return _clone_dirs(project.root), True

    project = config.project_for_cwd(cwd)
    if project is not None and project.root.resolve() == cwd.resolve():
        return _clone_dirs(project.root), True

    return [cwd], False


def run_branches(
    console: Console, cwd: Path, all_: bool = False, clone: str | None = None
) -> None:
    """Show branches for one repo, or for every clone under the project root."""
    targets, labeled = _resolve_targets(console, cwd, all_, clone)
    if not targets:
        console.print("[dim]No clones found.[/]")
        return
    if not labeled:
        show_branches(console, targets[0])
        return
    for target in targets:
        console.print(f"[bold cyan]{escape(target.name)}[/]")
        show_branches(console, target)
        console.print()


def run_clean(console: Console, cwd: Path, all_: bool = False, clone: str | None = None) -> None:
    """Clean finished branches in one repo, or in every clone under the project root."""
    targets, labeled = _resolve_targets(console, cwd, all_, clone)
    if not targets:
        console.print("[dim]No clones found.[/]")
        return
    for target in targets:
        if labeled:
            console.print(f"[bold cyan]{escape(target.name)}[/]")
        clean_branches(console, target)
        if labeled:
            console.print()


def list_repos(console: Console, cwd: Path) -> None:
    """Run `show_branches` for each clone under the current project's root."""
    run_branches(console, cwd, all_=True)


def clone_copy(console: Console, cwd: Path, name: str) -> None:
    """Create a fresh full clone named NAME under the current project's root."""
    project = _require_project(console, cwd)

    target = project.root / name
    if target.exists():
        console.print(f"[red]Error[/] {escape(git.home_path(target))} already exists.")
        raise SystemExit(1)

    console.print(f"[dim]Cloning[/] {escape(project.remote)} -> {escape(git.home_path(target))}")
    try:
        git.run("clone", project.remote, str(target), cwd=project.root)
    except git.GitError as exc:
        console.print(f"[red]Error[/] {escape(str(exc))}")
        raise SystemExit(1) from exc
    console.print(f"[green]Done.[/] {escape(git.home_path(target))}")


def remove_copy(
    console: Console,
    cwd: Path,
    name: str,
    force: bool = False,
) -> None:
    """Safely delete a clone under the current project's root."""
    project = _require_project(console, cwd)

    target = project.root / name
    if not target.is_dir():
        console.print(f"[red]Error[/] {escape(git.home_path(target))} does not exist.")
        raise SystemExit(1)

    resolved_target = target.resolve()
    resolved_cwd = cwd.resolve()
    if resolved_target == resolved_cwd or resolved_target in resolved_cwd.parents:
        console.print("[red]Error[/] refusing to remove the clone you are currently in.")
        raise SystemExit(1)

    if not force:
        if git.worktree_is_dirty(target):
            console.print(
                f"[yellow]Refusing[/] to remove {escape(git.home_path(target))}: "
                "uncommitted changes (use --force to override)."
            )
            raise SystemExit(1)
        if git.has_unpushed_commits(target):
            console.print(
                f"[yellow]Refusing[/] to remove {escape(git.home_path(target))}: "
                "commits not pushed to any remote (use --force to override)."
            )
            raise SystemExit(1)

    shutil.rmtree(target)
    console.print(f"[green]Removed[/] {escape(git.home_path(target))}")


def init_project(console: Console, remote: str, path: Path | None = None) -> None:
    """`gb init REMOTE [PATH]`: create or adopt PATH (default: cwd) as a project root.

    If PATH is already a checkout of REMOTE, it's moved to `<root>/default`;
    otherwise REMOTE is cloned fresh into `<root>/default`. Either way a
    `gb.toml` marking PATH as a project root is written afterwards.
    """
    root = (path or Path.cwd()).expanduser()
    default_clone = root / "default"

    if default_clone.is_dir() and git.is_git_repo(default_clone):
        console.print(f"[yellow]Already initialized[/]: {escape(git.home_path(default_clone))}.")
        config.write_project(root, remote)
        console.print(f"[green]Done.[/] project root {escape(git.home_path(root))}")
        return

    if root.is_dir() and git.is_git_repo(root):
        origin = git.get_remote_url(root)
        if origin is not None and origin != remote:
            console.print(
                f"[red]Error[/] {escape(git.home_path(root))} is already a checkout of "
                f"{escape(origin)}, not {escape(remote)}."
            )
            raise SystemExit(1)

        tmp = root.parent / f".{root.name}.gb-init-tmp"
        if tmp.exists():
            console.print(f"[red]Error[/] temp path {escape(git.home_path(tmp))} already exists.")
            raise SystemExit(1)

        shutil.move(str(root), str(tmp))
        root.mkdir()
        shutil.move(str(tmp), str(default_clone))
        config.write_project(root, remote)
        console.print(
            f"[green]Initialized[/] project root {escape(git.home_path(root))} "
            f"(existing checkout moved to {escape(git.home_path(default_clone))})."
        )
        return

    if root.exists() and any(root.iterdir()):
        console.print(
            f"[red]Error[/] {escape(git.home_path(root))} is not empty and not a git repository."
        )
        raise SystemExit(1)

    root.mkdir(parents=True, exist_ok=True)
    console.print(f"[dim]Cloning[/] {escape(remote)} -> {escape(git.home_path(default_clone))}")
    try:
        git.run("clone", remote, str(default_clone), cwd=root)
    except git.GitError as exc:
        console.print(f"[red]Error[/] {escape(str(exc))}")
        raise SystemExit(1) from exc

    config.write_project(root, remote)
    console.print(f"[green]Initialized[/] project root {escape(git.home_path(root))}.")
