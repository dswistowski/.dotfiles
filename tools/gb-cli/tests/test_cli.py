from __future__ import annotations

from pathlib import Path

import pytest
from click.testing import CliRunner

from gb_cli import cli, commands


def test_branches_invokes_show_branches(monkeypatch: pytest.MonkeyPatch) -> None:
    calls: list[Path] = []
    monkeypatch.setattr(commands, "show_branches", lambda console, cwd: calls.append(cwd))

    runner = CliRunner()
    result = runner.invoke(cli.cli, ["branches"])

    assert result.exit_code == 0
    assert calls == [Path.cwd()]


def test_branches_alias_a(monkeypatch: pytest.MonkeyPatch) -> None:
    calls: list[Path] = []
    monkeypatch.setattr(commands, "show_branches", lambda console, cwd: calls.append(cwd))

    runner = CliRunner()
    result = runner.invoke(cli.cli, ["a"])

    assert result.exit_code == 0
    assert calls == [Path.cwd()]


def test_clean_invokes_run_clean(monkeypatch: pytest.MonkeyPatch) -> None:
    calls: list[tuple[Path, bool]] = []

    def fake_run_clean(
        console: object,
        cwd: Path,
        all_: bool = False,
        clone: str | None = None,
        *,
        dry_run: bool = False,
    ) -> None:
        calls.append((cwd, dry_run))

    monkeypatch.setattr(commands, "run_clean", fake_run_clean)

    runner = CliRunner()
    result = runner.invoke(cli.cli, ["clean"])

    assert result.exit_code == 0
    assert calls == [(Path.cwd(), False)]


def test_clean_dry_run_flag(monkeypatch: pytest.MonkeyPatch) -> None:
    calls: list[bool] = []

    def fake_run_clean(
        console: object,
        cwd: Path,
        all_: bool = False,
        clone: str | None = None,
        *,
        dry_run: bool = False,
    ) -> None:
        calls.append(dry_run)

    monkeypatch.setattr(commands, "run_clean", fake_run_clean)

    runner = CliRunner()
    result = runner.invoke(cli.cli, ["clean", "--dry-run"])

    assert result.exit_code == 0
    assert calls == [True]


def test_clean_alias_d(monkeypatch: pytest.MonkeyPatch) -> None:
    calls: list[Path] = []

    def fake_run_clean(
        console: object,
        cwd: Path,
        all_: bool = False,
        clone: str | None = None,
        *,
        dry_run: bool = False,
    ) -> None:
        calls.append(cwd)

    monkeypatch.setattr(commands, "run_clean", fake_run_clean)

    runner = CliRunner()
    result = runner.invoke(cli.cli, ["d"])

    assert result.exit_code == 0
    assert calls == [Path.cwd()]


def test_repos_invokes_list_repos(monkeypatch: pytest.MonkeyPatch) -> None:
    calls: list[Path] = []
    monkeypatch.setattr(commands, "list_repos", lambda console, cwd: calls.append(cwd))

    runner = CliRunner()
    result = runner.invoke(cli.cli, ["repos"])

    assert result.exit_code == 0
    assert calls == [Path.cwd()]


def test_repos_alias_l(monkeypatch: pytest.MonkeyPatch) -> None:
    calls: list[Path] = []
    monkeypatch.setattr(commands, "list_repos", lambda console, cwd: calls.append(cwd))

    runner = CliRunner()
    result = runner.invoke(cli.cli, ["l"])

    assert result.exit_code == 0
    assert calls == [Path.cwd()]


def test_clone_invokes_clone_copy(monkeypatch: pytest.MonkeyPatch) -> None:
    calls: list[tuple[Path, str]] = []
    monkeypatch.setattr(
        commands, "clone_copy", lambda console, cwd, name: calls.append((cwd, name))
    )

    runner = CliRunner()
    result = runner.invoke(cli.cli, ["clone", "app1"])

    assert result.exit_code == 0
    assert calls == [(Path.cwd(), "app1")]


def test_clone_alias_c(monkeypatch: pytest.MonkeyPatch) -> None:
    calls: list[tuple[Path, str]] = []
    monkeypatch.setattr(
        commands, "clone_copy", lambda console, cwd, name: calls.append((cwd, name))
    )

    runner = CliRunner()
    result = runner.invoke(cli.cli, ["c", "app1"])

    assert result.exit_code == 0
    assert calls == [(Path.cwd(), "app1")]


def test_remove_invokes_remove_copy(monkeypatch: pytest.MonkeyPatch) -> None:
    calls: list[tuple[Path, str, bool]] = []
    monkeypatch.setattr(
        commands,
        "remove_copy",
        lambda console, cwd, name, force=False: calls.append((cwd, name, force)),
    )

    runner = CliRunner()
    result = runner.invoke(cli.cli, ["remove", "app1", "--force"])

    assert result.exit_code == 0
    assert calls == [(Path.cwd(), "app1", True)]


def test_remove_alias_rm(monkeypatch: pytest.MonkeyPatch) -> None:
    calls: list[tuple[Path, str, bool]] = []
    monkeypatch.setattr(
        commands,
        "remove_copy",
        lambda console, cwd, name, force=False: calls.append((cwd, name, force)),
    )

    runner = CliRunner()
    result = runner.invoke(cli.cli, ["rm", "app1"])

    assert result.exit_code == 0
    assert calls == [(Path.cwd(), "app1", False)]


def test_init_invokes_init_project(monkeypatch: pytest.MonkeyPatch) -> None:
    calls: list[tuple[str, Path | None]] = []
    monkeypatch.setattr(
        commands, "init_project", lambda console, remote, path: calls.append((remote, path))
    )

    runner = CliRunner()
    result = runner.invoke(cli.cli, ["init", "git@example.com:x/y.git"])

    assert result.exit_code == 0
    assert calls == [("git@example.com:x/y.git", None)]


def test_init_alias_i(monkeypatch: pytest.MonkeyPatch) -> None:
    calls: list[tuple[str, Path | None]] = []
    monkeypatch.setattr(
        commands, "init_project", lambda console, remote, path: calls.append((remote, path))
    )

    runner = CliRunner()
    result = runner.invoke(cli.cli, ["i", "git@example.com:x/y.git", "/tmp/root"])

    assert result.exit_code == 0
    assert calls == [("git@example.com:x/y.git", Path("/tmp/root"))]


def test_help_lists_subcommands() -> None:
    runner = CliRunner()
    result = runner.invoke(cli.cli, ["--help"])
    assert result.exit_code == 0
    for name in ("branches", "clean", "repos", "status", "sync", "clone", "remove", "init"):
        assert name in result.output


def test_unknown_command_is_an_error() -> None:
    runner = CliRunner()
    result = runner.invoke(cli.cli, ["nope"])
    assert result.exit_code != 0
