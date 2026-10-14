from __future__ import annotations

import subprocess
from pathlib import Path

from gb_cli import git


def _git(*args: str, cwd: Path) -> None:
    subprocess.run(["git", *args], cwd=cwd, check=True, capture_output=True)


def test_current_branch(git_repo: Path) -> None:
    assert git.current_branch(git_repo) == "main"


def test_list_branches(git_repo: Path) -> None:
    _git("branch", "feature", cwd=git_repo)
    assert set(git.list_branches(git_repo)) == {"main", "feature"}


def test_default_branch_falls_back_to_local_branches(git_repo: Path) -> None:
    # no origin remote configured -> falls back to scanning local branches
    assert git.default_branch(git_repo) == "main"


def test_is_ancestor(git_repo: Path) -> None:
    _git("checkout", "-b", "feature", cwd=git_repo)
    (git_repo / "f.txt").write_text("x\n")
    _git("add", "f.txt", cwd=git_repo)
    _git("commit", "-m", "on feature", cwd=git_repo)
    _git("checkout", "main", cwd=git_repo)
    _git("merge", "--no-ff", "feature", "-m", "merge feature", cwd=git_repo)

    assert git.is_ancestor("feature", "main", git_repo)


def test_unique_commit_count(git_repo: Path) -> None:
    _git("checkout", "-b", "feature", cwd=git_repo)
    (git_repo / "new.txt").write_text("data\n")
    _git("add", "new.txt", cwd=git_repo)
    _git("commit", "-m", "add file", cwd=git_repo)

    assert git.unique_commit_count("main", "feature", git_repo) == 1
    assert git.unique_commit_count("main", "main", git_repo) == 0


def test_list_worktrees_main_only(git_repo: Path) -> None:
    worktrees = git.list_worktrees(git_repo)
    assert len(worktrees) == 1
    assert worktrees[0].path == git_repo
    assert worktrees[0].branch == "main"
    assert not worktrees[0].is_detached


def test_list_worktrees_linked_and_detached(git_repo: Path, tmp_path: Path) -> None:
    _git("branch", "feature", cwd=git_repo)
    linked = tmp_path / "linked"
    _git("worktree", "add", str(linked), "feature", cwd=git_repo)

    detached = tmp_path / "detached"
    _git("worktree", "add", "--detach", str(detached), cwd=git_repo)

    worktrees = git.list_worktrees(git_repo)
    by_path = {w.path: w for w in worktrees}

    assert by_path[linked].branch == "feature"
    assert not by_path[linked].is_detached
    assert by_path[detached].is_detached


def test_worktrees_for_branch(git_repo: Path, tmp_path: Path) -> None:
    _git("branch", "feature", cwd=git_repo)
    linked = tmp_path / "linked"
    _git("worktree", "add", str(linked), "feature", cwd=git_repo)

    worktrees = git.list_worktrees(git_repo)
    matches = git.worktrees_for_branch("feature", worktrees)
    assert [w.path for w in matches] == [linked]


def test_unmatched_worktrees(git_repo: Path, tmp_path: Path) -> None:
    detached = tmp_path / "detached"
    _git("worktree", "add", "--detach", str(detached), cwd=git_repo)

    worktrees = git.list_worktrees(git_repo)
    branches = git.list_branches(git_repo)
    unmatched = git.unmatched_worktrees(worktrees, branches)

    assert len(unmatched) == 1
    wt, kind = unmatched[0]
    assert wt.path == detached
    assert kind == "detached"


def test_worktree_is_dirty(git_repo: Path) -> None:
    assert git.worktree_is_dirty(git_repo) is False
    (git_repo / "dirty.txt").write_text("oops\n")
    assert git.worktree_is_dirty(git_repo) is True


def test_worktree_is_dirty_missing_path(tmp_path: Path) -> None:
    assert git.worktree_is_dirty(tmp_path / "does-not-exist") is False


def test_has_unpushed_commits_no_remote(git_repo: Path) -> None:
    assert git.has_unpushed_commits(git_repo) is False


def test_has_unpushed_commits_clean_clone(git_repo: Path, tmp_path: Path) -> None:
    clone = tmp_path / "clone"
    _git("clone", str(git_repo), str(clone), cwd=tmp_path)
    assert git.has_unpushed_commits(clone) is False


def test_has_unpushed_commits_after_local_commit(git_repo: Path, tmp_path: Path) -> None:
    clone = tmp_path / "clone"
    _git("clone", str(git_repo), str(clone), cwd=tmp_path)
    (clone / "new.txt").write_text("data\n")
    _git("add", "new.txt", cwd=clone)
    _git("commit", "-m", "local only", cwd=clone)
    assert git.has_unpushed_commits(clone) is True


def test_main_worktree_path(git_repo: Path) -> None:
    assert git.main_worktree_path(git_repo) == git_repo


def test_is_git_repo(git_repo: Path, tmp_path: Path) -> None:
    assert git.is_git_repo(git_repo) is True
    assert git.is_git_repo(tmp_path) is False


def test_is_git_repo_nonexistent_path(tmp_path: Path) -> None:
    assert git.is_git_repo(tmp_path / "missing") is False


def test_home_path_inside_home(monkeypatch, tmp_path: Path) -> None:
    monkeypatch.setattr(Path, "home", lambda: tmp_path)
    child = tmp_path / "projects" / "foo"
    assert git.home_path(child) == "~/projects/foo"


def test_home_path_outside_home(monkeypatch, tmp_path: Path) -> None:
    monkeypatch.setattr(Path, "home", lambda: tmp_path / "home")
    other = tmp_path / "elsewhere"
    assert git.home_path(other) == str(other)
