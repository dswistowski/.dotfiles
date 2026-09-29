from __future__ import annotations

import subprocess
from pathlib import Path

import pytest
from rich.console import Console

from gb_cli import commands, config
from gb_cli.gh import PullRequest


def _git(*args: str, cwd: Path) -> None:
    subprocess.run(["git", *args], cwd=cwd, check=True, capture_output=True)


def _console() -> tuple[Console, list[str]]:
    lines: list[str] = []
    console = Console(record=True, width=120)
    return console, lines


def _plain(console: Console) -> str:
    return console.export_text()


def test_show_branches_no_prs(git_repo: Path) -> None:
    console, _ = _console()
    commands.show_branches(console, git_repo)
    output = _plain(console)
    assert "main" in output
    assert "(no PR)" in output


def test_show_branches_with_pr(git_repo: Path, monkeypatch: pytest.MonkeyPatch) -> None:
    _git("branch", "feature", cwd=git_repo)

    def fake_pr_view(branch: str, cwd: Path | None = None) -> PullRequest | None:
        if branch == "feature":
            return PullRequest(42, "Add feature", "OPEN", False, "https://example.com/pr/42")
        return None

    monkeypatch.setattr(commands, "pr_view", fake_pr_view)

    console, _ = _console()
    commands.show_branches(console, git_repo)
    output = _plain(console)
    assert "#42" in output
    assert "OPEN" in output
    assert "Add feature" in output


def test_clean_branches_removes_merged_pr_branch(
    git_repo: Path, monkeypatch: pytest.MonkeyPatch
) -> None:
    _git("branch", "old-feature", cwd=git_repo)

    def fake_pr_view(branch: str, cwd: Path | None = None) -> PullRequest | None:
        if branch == "old-feature":
            return PullRequest(7, "Old feature", "MERGED", False, "https://example.com/pr/7")
        return None

    monkeypatch.setattr(commands, "pr_view", fake_pr_view)

    console, _ = _console()
    commands.clean_branches(console, git_repo)

    from gb_cli import git

    assert "old-feature" not in git.list_branches(git_repo)


def test_clean_branches_keeps_open_pr_branch(
    git_repo: Path, monkeypatch: pytest.MonkeyPatch
) -> None:
    _git("branch", "wip-feature", cwd=git_repo)

    def fake_pr_view(branch: str, cwd: Path | None = None) -> PullRequest | None:
        if branch == "wip-feature":
            return PullRequest(8, "WIP", "OPEN", True, "https://example.com/pr/8")
        return None

    monkeypatch.setattr(commands, "pr_view", fake_pr_view)

    console, _ = _console()
    commands.clean_branches(console, git_repo)

    from gb_cli import git

    assert "wip-feature" in git.list_branches(git_repo)


def test_clean_branches_removes_branch_with_no_unique_commits(
    git_repo: Path, monkeypatch: pytest.MonkeyPatch
) -> None:
    _git("branch", "stale", cwd=git_repo)
    monkeypatch.setattr(commands, "pr_view", lambda branch, cwd=None: None)

    console, _ = _console()
    commands.clean_branches(console, git_repo)

    from gb_cli import git

    assert "stale" not in git.list_branches(git_repo)


def test_clean_branches_never_deletes_current_or_main(
    git_repo: Path, monkeypatch: pytest.MonkeyPatch
) -> None:
    monkeypatch.setattr(commands, "pr_view", lambda branch, cwd=None: None)
    console, _ = _console()
    commands.clean_branches(console, git_repo)

    from gb_cli import git

    assert "main" in git.list_branches(git_repo)


def test_list_repos_rejects_dir_not_a_project_root(
    tmp_path: Path,
) -> None:
    console, _ = _console()
    with pytest.raises(SystemExit):
        commands.list_repos(console, tmp_path)


def test_list_repos_runs_for_clones(
    git_repo: Path, tmp_path: Path, monkeypatch: pytest.MonkeyPatch
) -> None:
    parent = tmp_path / "parent"
    parent.mkdir()
    repo_link = parent / "default"
    repo_link.symlink_to(git_repo)
    config.write_project(parent, str(git_repo))

    monkeypatch.setattr(commands, "pr_view", lambda branch, cwd=None: None)

    console, _ = _console()
    commands.list_repos(console, parent)
    output = _plain(console)
    assert "default" in output
    assert "main" in output


def test_run_branches_defaults_to_all_at_project_root(
    git_repo: Path, tmp_path: Path, monkeypatch: pytest.MonkeyPatch
) -> None:
    parent = tmp_path / "parent"
    parent.mkdir()
    (parent / "default").symlink_to(git_repo)
    config.write_project(parent, str(git_repo))
    monkeypatch.setattr(commands, "pr_view", lambda branch, cwd=None: None)

    console, _ = _console()
    commands.run_branches(console, parent)

    assert "default" in _plain(console)


def test_run_branches_defaults_to_single_repo_inside_clone(
    git_repo: Path, tmp_path: Path, monkeypatch: pytest.MonkeyPatch
) -> None:
    parent = tmp_path / "parent"
    parent.mkdir()
    clone = parent / "default"
    clone.symlink_to(git_repo)
    config.write_project(parent, str(git_repo))
    monkeypatch.setattr(commands, "pr_view", lambda branch, cwd=None: None)

    console, _ = _console()
    commands.run_branches(console, clone)

    assert "default" not in _plain(console).splitlines()


def test_run_branches_clone_flag_targets_named_clone(
    git_repo: Path, tmp_path: Path, monkeypatch: pytest.MonkeyPatch
) -> None:
    parent = tmp_path / "parent"
    parent.mkdir()
    (parent / "default").symlink_to(git_repo)
    config.write_project(parent, str(git_repo))
    monkeypatch.setattr(commands, "pr_view", lambda branch, cwd=None: None)

    console, _ = _console()
    commands.run_branches(console, parent, clone="default")

    assert "main" in _plain(console)


def test_run_branches_clone_flag_rejects_unknown_clone(
    git_repo: Path, tmp_path: Path
) -> None:
    parent = tmp_path / "parent"
    parent.mkdir()
    config.write_project(parent, str(git_repo))

    console, _ = _console()
    with pytest.raises(SystemExit):
        commands.run_branches(console, parent, clone="missing")


def test_run_branches_rejects_all_and_clone_together(git_repo: Path) -> None:
    console, _ = _console()
    with pytest.raises(SystemExit):
        commands.run_branches(console, git_repo, all_=True, clone="default")


def test_run_clean_all_runs_across_clones(
    git_repo: Path, tmp_path: Path, monkeypatch: pytest.MonkeyPatch
) -> None:
    _git("branch", "stale", cwd=git_repo)
    parent = tmp_path / "parent"
    parent.mkdir()
    (parent / "default").symlink_to(git_repo)
    config.write_project(parent, str(git_repo))
    monkeypatch.setattr(commands, "pr_view", lambda branch, cwd=None: None)

    console, _ = _console()
    commands.run_clean(console, parent, all_=True)

    from gb_cli import git

    assert "stale" not in git.list_branches(git_repo)
    assert "default" in _plain(console)


def test_clone_copy_creates_new_clone(git_repo: Path, tmp_path: Path) -> None:
    root = tmp_path / "root"
    root.mkdir()
    config.write_project(root, str(git_repo))
    console, _ = _console()

    commands.clone_copy(console, root, "app1")

    assert (root / "app1" / ".git").exists()


def test_clone_copy_works_from_subdirectory(git_repo: Path, tmp_path: Path) -> None:
    root = tmp_path / "root"
    (root / "default").mkdir(parents=True)
    config.write_project(root, str(git_repo))
    console, _ = _console()

    commands.clone_copy(console, root / "default", "app1")

    assert (root / "app1" / ".git").exists()


def test_clone_copy_rejects_outside_project_root(tmp_path: Path) -> None:
    console, _ = _console()
    with pytest.raises(SystemExit):
        commands.clone_copy(console, tmp_path, "app1")


def test_clone_copy_rejects_existing_target(git_repo: Path, tmp_path: Path) -> None:
    root = tmp_path / "root"
    root.mkdir()
    config.write_project(root, str(git_repo))
    (root / "app1").mkdir()
    console, _ = _console()

    with pytest.raises(SystemExit):
        commands.clone_copy(console, root, "app1")


def test_remove_copy_deletes_clean_clone(git_repo: Path, tmp_path: Path) -> None:
    root = tmp_path / "root"
    root.mkdir()
    config.write_project(root, str(git_repo))
    console, _ = _console()
    commands.clone_copy(console, root, "app1")

    commands.remove_copy(console, root, "app1")

    assert not (root / "app1").exists()


def test_remove_copy_refuses_dirty_clone(git_repo: Path, tmp_path: Path) -> None:
    root = tmp_path / "root"
    root.mkdir()
    config.write_project(root, str(git_repo))
    console, _ = _console()
    commands.clone_copy(console, root, "app1")
    (root / "app1" / "dirty.txt").write_text("oops\n")

    with pytest.raises(SystemExit):
        commands.remove_copy(console, root, "app1")

    assert (root / "app1").exists()


def test_remove_copy_force_deletes_dirty_clone(git_repo: Path, tmp_path: Path) -> None:
    root = tmp_path / "root"
    root.mkdir()
    config.write_project(root, str(git_repo))
    console, _ = _console()
    commands.clone_copy(console, root, "app1")
    (root / "app1" / "dirty.txt").write_text("oops\n")

    commands.remove_copy(console, root, "app1", force=True)

    assert not (root / "app1").exists()


def test_init_project_moves_existing_checkout_to_default(git_repo: Path) -> None:
    remote = "git@example.com:x/y.git"
    _git("remote", "add", "origin", remote, cwd=git_repo)
    console, _ = _console()

    commands.init_project(console, remote, path=git_repo)

    assert (git_repo / "default" / ".git").exists()
    assert not (git_repo / ".git").exists()


def test_init_project_accepts_checkout_without_origin(git_repo: Path) -> None:
    console, _ = _console()

    commands.init_project(console, "git@example.com:x/y.git", path=git_repo)

    assert (git_repo / "default" / ".git").exists()


def test_init_project_writes_config(git_repo: Path) -> None:
    remote = "git@example.com:x/y.git"
    _git("remote", "add", "origin", remote, cwd=git_repo)
    console, _ = _console()

    commands.init_project(console, remote, path=git_repo)

    project = config.load_project(git_repo)
    assert project.root == git_repo
    assert project.remote == remote


def test_init_project_rejects_mismatched_remote(git_repo: Path) -> None:
    _git("remote", "add", "origin", "git@example.com:x/y.git", cwd=git_repo)
    console, _ = _console()

    with pytest.raises(SystemExit):
        commands.init_project(console, "git@example.com:other/repo.git", path=git_repo)
    assert (git_repo / ".git").exists()


def test_init_project_is_idempotent(git_repo: Path) -> None:
    remote = "git@example.com:x/y.git"
    _git("remote", "add", "origin", remote, cwd=git_repo)
    console, _ = _console()

    commands.init_project(console, remote, path=git_repo)
    # running init again on the already-initialized root should not error
    commands.init_project(console, remote, path=git_repo)

    assert (git_repo / "default" / ".git").exists()


def test_init_project_clones_fresh_into_new_root(git_repo: Path, tmp_path: Path) -> None:
    root = tmp_path / "newroot"
    console, _ = _console()

    commands.init_project(console, str(git_repo), path=root)

    assert (root / "default" / ".git").exists()


def test_init_project_rejects_nonempty_non_git_dir(tmp_path: Path) -> None:
    root = tmp_path / "root"
    root.mkdir()
    (root / "junk.txt").write_text("hi\n")
    console, _ = _console()

    with pytest.raises(SystemExit):
        commands.init_project(console, "git@example.com:x/y.git", path=root)


def test_remove_copy_rejects_missing_target(git_repo: Path, tmp_path: Path) -> None:
    root = tmp_path / "root"
    root.mkdir()
    config.write_project(root, str(git_repo))
    console, _ = _console()

    with pytest.raises(SystemExit):
        commands.remove_copy(console, root, "missing")
