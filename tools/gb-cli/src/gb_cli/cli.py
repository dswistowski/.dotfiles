"""Click entry point for the `gb` command."""

from __future__ import annotations

from pathlib import Path

import click
from rich.console import Console

from gb_cli import commands

console = Console()

ALIASES = {
    "a": "branches",
    "d": "clean",
    "l": "repos",
    "c": "clone",
    "rm": "remove",
    "i": "init",
}


class AliasedGroup(click.Group):
    """A click Group where short aliases resolve to full command names."""

    def get_command(self, ctx: click.Context, cmd_name: str) -> click.Command | None:
        cmd = super().get_command(ctx, cmd_name)
        if cmd is not None:
            return cmd
        canonical = ALIASES.get(cmd_name)
        return super().get_command(ctx, canonical) if canonical else None


def _aliases_for(name: str) -> str:
    matches = sorted(alias for alias, target in ALIASES.items() if target == name)
    return f" [alias: {', '.join(matches)}]" if matches else ""


@click.group(cls=AliasedGroup)
@click.version_option(package_name="gb-cli")
def cli() -> None:
    """Manage local git branches, worktrees, and multi-clone project setups."""


def _repo_scope_options(func: click.decorators.FC) -> click.decorators.FC:
    func = click.option(
        "--all", "all_", is_flag=True, help="Run for every clone under the project root."
    )(func)
    func = click.option(
        "--clone", "clone_name", metavar="NAME", help="Run for a specific clone by name."
    )(func)
    return func


@cli.command("branches", short_help=f"Show local branches and PR status.{_aliases_for('branches')}")
@_repo_scope_options
def branches(all_: bool, clone_name: str | None) -> None:
    """Show local branches with their GitHub PR status and worktree.

    Defaults to the current repo, or to every clone under the project root
    when run from the root itself. --all/--clone override that.
    """
    commands.run_branches(console, Path.cwd(), all_=all_, clone=clone_name)


@cli.command("clean", short_help=f"Delete finished local branches.{_aliases_for('clean')}")
@_repo_scope_options
def clean(all_: bool, clone_name: str | None) -> None:
    """Delete local branches (and worktrees) that are merged, closed, or empty.

    Defaults to the current repo, or to every clone under the project root
    when run from the root itself. --all/--clone override that.
    """
    commands.run_clean(console, Path.cwd(), all_=all_, clone=clone_name)


@cli.command("repos", short_help=f"List clones under a project's root.{_aliases_for('repos')}")
def repos() -> None:
    """Run `branches` for each clone under the current project's configured root."""
    commands.list_repos(console, Path.cwd())


@cli.command("clone", short_help=f"Create a new clone of a project.{_aliases_for('clone')}")
@click.argument("name")
def clone(name: str) -> None:
    """Create a new full clone named NAME under the current project's root."""
    commands.clone_copy(console, Path.cwd(), name)


@cli.command("remove", short_help=f"Safely delete a clone.{_aliases_for('remove')}")
@click.argument("name")
@click.option("--force", is_flag=True, help="Remove even if dirty or has unpushed commits.")
def remove(name: str, force: bool) -> None:
    """Safely delete the clone named NAME under the current project's root."""
    commands.remove_copy(console, Path.cwd(), name, force=force)


@cli.command("init", short_help=f"Create or adopt a project root.{_aliases_for('init')}")
@click.argument("remote")
@click.argument("path", required=False, type=click.Path(path_type=Path))
def init(remote: str, path: Path | None) -> None:
    """Create or adopt a project root for REMOTE at PATH (default: current directory).

    If PATH is already a checkout of REMOTE, it's moved to <root>/default;
    otherwise REMOTE is cloned fresh into <root>/default. Either way the
    project is registered in the config, so `repos`/`clone`/`remove` work
    from PATH afterwards.
    """
    commands.init_project(console, remote, path)


def main() -> None:
    cli()


if __name__ == "__main__":
    main()
