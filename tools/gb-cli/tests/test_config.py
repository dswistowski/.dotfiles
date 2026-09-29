from __future__ import annotations

from pathlib import Path

import pytest

from gb_cli import config


def test_find_project_root_missing_returns_none(tmp_path: Path) -> None:
    assert config.find_project_root(tmp_path) is None


def test_find_project_root_finds_marker_in_cwd(tmp_path: Path) -> None:
    (tmp_path / config.CONFIG_FILENAME).write_text('remote = "x"\n')
    assert config.find_project_root(tmp_path) == tmp_path


def test_find_project_root_walks_up_parents(tmp_path: Path) -> None:
    (tmp_path / config.CONFIG_FILENAME).write_text('remote = "x"\n')
    child = tmp_path / "default" / "src"
    child.mkdir(parents=True)

    assert config.find_project_root(child) == tmp_path


def test_load_project_parses_remote(tmp_path: Path) -> None:
    (tmp_path / config.CONFIG_FILENAME).write_text(
        'remote = "git@github.com:ledgy/ledgy-app.git"\n'
    )

    project = config.load_project(tmp_path)

    assert project.name == tmp_path.name
    assert project.root == tmp_path
    assert project.remote == "git@github.com:ledgy/ledgy-app.git"


def test_load_project_missing_field_raises(tmp_path: Path) -> None:
    (tmp_path / config.CONFIG_FILENAME).write_text("")

    with pytest.raises(config.ConfigError):
        config.load_project(tmp_path)


def test_load_project_invalid_toml_raises(tmp_path: Path) -> None:
    (tmp_path / config.CONFIG_FILENAME).write_text("not valid toml [[[")

    with pytest.raises(config.ConfigError):
        config.load_project(tmp_path)


def test_project_for_cwd_walks_up_and_loads(tmp_path: Path) -> None:
    (tmp_path / config.CONFIG_FILENAME).write_text('remote = "git@example.com:x/y.git"\n')
    child = tmp_path / "app1"
    child.mkdir()

    project = config.project_for_cwd(child)

    assert project is not None
    assert project.root == tmp_path
    assert project.remote == "git@example.com:x/y.git"


def test_project_for_cwd_returns_none_when_not_found(tmp_path: Path) -> None:
    assert config.project_for_cwd(tmp_path) is None


def test_write_project_creates_file(tmp_path: Path) -> None:
    config.write_project(tmp_path, "git@example.com:x/y.git")

    project = config.load_project(tmp_path)
    assert project.root == tmp_path
    assert project.remote == "git@example.com:x/y.git"


def test_write_project_updates_existing(tmp_path: Path) -> None:
    config.write_project(tmp_path, "old-remote")
    config.write_project(tmp_path, "new-remote")

    assert config.load_project(tmp_path).remote == "new-remote"
