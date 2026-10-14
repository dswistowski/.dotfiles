# gb-cli

Git branch/worktree helper with a single `gb` command and subcommands
(each has a short alias):

- `gb branches` (`gb a`) — show local branches with their GitHub PR status and worktree.
- `gb clean` (`gb d`) — delete local branches (and worktrees) that are merged,
  closed, or have no unique commits vs the default branch. Use `--dry-run` to
  preview deletions and see a summary.
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

Multi-clone projects are defined by a **`gb.toml` marker file at the project root**
(not a global config file). `gb` walks up from the current directory until it
finds `gb.toml`:

```toml
# ~/ledgy-app/gb.toml
remote = "git@github.com:ledgy/ledgy-app.git"
```

Each project is a directory (`root`) holding independent full clones of
`remote` — e.g. `~/ledgy-app/default`, `~/ledgy-app/app1`,
`~/ledgy-app/code-review`. Full clones (not worktrees) because tools like
`gt` (Graphite) don't play well with worktrees. `clone`/`remove`/`repos`
must be run from inside a project's `root` or any subdirectory beneath it;
`branches`/`clean` work on any git repo (e.g. inside `~/ledgy-app/default`)
and don't need `gb.toml` at all.

`gb init` writes or refreshes `gb.toml` at the project root.

To bootstrap a layout from scratch, or adopt an existing single-directory
checkout into it, run `gb init REMOTE [PATH]`:

```sh
gb init git@github.com:ledgy/ledgy-app.git ~/ledgy-app
# or, from inside an existing checkout at ~/ledgy/app:
cd ~/ledgy/app && gb init git@github.com:ledgy/ledgy-app.git
```

If `PATH` (or the current directory) is already a checkout of `REMOTE`, it's
moved to `<root>/default`; if it doesn't exist or is empty, `REMOTE` is
cloned fresh into `<root>/default`. Either way `gb.toml` is written at the
root, so the layout is usable with `repos`/`clone`/`remove` right away.
Re-running `gb init` on an already-initialized root is a no-op that just
(re)writes `gb.toml`.

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
