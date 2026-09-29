"""TOML config: a `gb.toml` marker file at a project's root.

Example ~/ledgy-app/gb.toml:

    remote = "git@github.com:ledgy/ledgy-app.git"

`gb l` lists the clones (e.g. `default`, `app1`, `code-review`) under the
project root; `gb clone`/`gb rm` create and remove them. These commands can
be run from the root itself or any of its subdirectories -- gb-cli walks up
from the current directory looking for `gb.toml`.
"""

from __future__ import annotations

import tomllib
from dataclasses import dataclass
from pathlib import Path

import tomli_w

CONFIG_FILENAME = "gb.toml"


class ConfigError(RuntimeError):
    pass


@dataclass(frozen=True)
class Project:
    name: str
    root: Path
    remote: str


def find_project_root(cwd: Path) -> Path | None:
    """Walk up from `cwd` looking for a directory containing `gb.toml`."""
    for directory in (cwd, *cwd.parents):
        if (directory / CONFIG_FILENAME).is_file():
            return directory
    return None


def load_project(root: Path) -> Project:
    path = root / CONFIG_FILENAME
    try:
        data = tomllib.loads(path.read_text())
    except tomllib.TOMLDecodeError as exc:
        raise ConfigError(f"{path}: invalid TOML: {exc}") from exc
    try:
        remote = data["remote"]
    except KeyError as exc:
        raise ConfigError(f"{path}: missing {exc}") from exc
    return Project(name=root.name, root=root, remote=remote)


def project_for_cwd(cwd: Path) -> Project | None:
    """Find the project enclosing `cwd` by walking up for a `gb.toml`."""
    root = find_project_root(cwd.resolve())
    return load_project(root) if root is not None else None


def write_project(root: Path, remote: str) -> None:
    """Write (or overwrite) the `gb.toml` that marks `root` as a project root."""
    root.mkdir(parents=True, exist_ok=True)
    (root / CONFIG_FILENAME).write_text(tomli_w.dumps({"remote": remote}))
