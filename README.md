# macOS dotfiles

On an Apple Silicon Mac, transfer this checkout to `~/.dotfiles`, then run this from Terminal:

```sh
~/.dotfiles/bootstrap.sh
```

If you already have the checkout on GitHub, you can also clone it over HTTPS first. macOS may prompt you to install Command Line Tools when you first run Git or install Homebrew.

The script installs Homebrew when needed, adds the packages in `Brewfile`, installs Oh My Zsh and Pure, then links the dotfiles with GNU Stow. Open a new terminal afterward. Homebrew may ask for your macOS password during its first install.

You can rerun the script. It keeps existing packages at their installed versions and stops if a local config blocks a symlink. Move or merge the conflicting file and rerun. To preview just the links, run `~/.dotfiles/install.sh --dry-run`.

## Project setup

- Check `node -v` for Node 24. If your migrated fnm setup selects a different version, use `fnm install 24` and `fnm default 24`. In each project, run `pnpm --version` to check the version against its `packageManager` field.
- For Gymsembly, run `uv sync --locked` from `apps/api` to install its pinned Python and dependencies. If using local PostgreSQL, start it with `brew services start postgresql@18` and restore or create your development database. Follow the project README for environment files and migrations.
- Sign in to GitHub with `gh auth login` and verify your SSH and GPG signing setup. Move development credentials and environment files privately.
- For iOS development, install Xcode and the iOS simulator runtime through Xcode. If you use Alacritty, install it from [its releases](https://github.com/alacritty/alacritty/releases).
