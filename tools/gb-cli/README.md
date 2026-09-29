# gb-cli

Git branch/worktree helper with a single `gb` command and subcommands
(each has a short alias):

- `gb branches` (`gb a`) — show local branches with their GitHub PR status and worktree.
- `gb clean` (`gb d`) — delete local branches (and worktrees) that are merged,
  closed, or have no unique commits vs the default branch.
- `gb repos` (`gb l`) — run `branches` for every clone under a configured project's root.
- `gb init` (`gb i`) `REMOTE [PATH]` — create or adopt PATH (default: current
  directory) as a project root for REMOTE.
- `gb clone` (`gb c`) `NAME` — create a fresh full clone named `NAME` under
  the current project's root (must be run from inside that root).
- `gb remove` (`gb rm`) `NAME [--force]` — delete a clone named `NAME` from
  the current project's root; refuses (without `--force`) if it has
  uncommitted changes, unpushed commits, or is the clone you're currently
  standing in.

Requires `git` and `gh` on `PATH`.

## Configuration

`repos`/`clone`/`remove`/`init` read and write project definitions in a
TOML config file, default `$XDG_CONFIG_HOME/gb-cli/config.toml` (or
`~/.config/gb-cli/config.toml`), overridable with `GB_CONFIG_FILE`:

```toml
# ~/.config/gb-cli/config.toml
[projects.ledgy-app]
root = "~/ledgy-app"
remote = "git@github.com:ledgy/ledgy-app.git"
```

Each project is a `root` directory holding independent full clones of
`remote` — e.g. `~/ledgy-app/default`, `~/ledgy-app/app1`,
`~/ledgy-app/code-review`. Full clones (not worktrees) because tools like
`gt` (Graphite) don't play well with worktrees. `clone`/`remove`/`repos`
must be run from inside a project's `root`; `branches`/`clean` work on any
git repo (e.g. inside `~/ledgy-app/default`) and don't need the config at all.

To bootstrap a layout from scratch, or adopt an existing single-directory
checkout into it, run `gb init REMOTE [PATH]`:

```sh
gb init git@github.com:ledgy/ledgy-app.git ~/ledgy-app
# or, from inside an existing checkout at ~/ledgy/app:
cd ~/ledgy/app && gb init git@github.com:ledgy/ledgy-app.git
```

If `PATH` (or the current directory) is already a checkout of `REMOTE`, it's
moved to `<root>/default`; if it doesn't exist or is empty, `REMOTE` is
cloned fresh into `<root>/default`. Either way a `[projects.<name>]` entry
(`<name>` is the root directory's basename) is added to the config, so the
root becomes usable with `repos`/`clone`/`remove` right away. Re-running
`gb init` on an already-initialized root is a no-op that just (re)writes the
config entry.

## Development

```sh
uv sync
uv run pytest
uv run ruff format .
uv run ruff check .
```

`tools/bin/gb` is a thin shim (`uv run --project tools/gb-cli gb "$@"`) so the
command works from anywhere on `PATH` (see `~/bin` -> `tools/bin`).

## zsh completion

`completions/gb.zsh` is a static, checked-in completion script generated with:

```sh
_GB_COMPLETE=zsh_source uv run gb > completions/gb.zsh
```

Regenerate it whenever subcommands/options change. It's sourced from `.zshrc`.
