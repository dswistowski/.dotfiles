# Keymap Cheatsheet

Press `<leader>hh` any time to bring this back up. Close with `q` or `<Esc>`.
Leader key is `<Space>`.

## General

| Key    | Action                     |
| ------ | --------------------------- |
| `;`    | Enter command mode (`:`)    |
| `jk`   | Escape insert mode          |
| `<Esc>`| Clear search highlight      |
| `<C-h/j/k/l>` | Move between windows |

## Find (Telescope)

| Key          | Action                    |
| ------------ | -------------------------- |
| `<leader>ff` | Find files                 |
| `<leader>fg` | Live grep                  |
| `<leader>fb` | Open buffers               |
| `<leader>fr` | Recent files                |
| `<leader>fh` | Help tags                  |
| `<leader>fd` | Diagnostics list            |
| `<leader>fs` | Workspace symbols           |

## LSP

| Key    | Action                            |
| ------ | ---------------------------------- |
| `grn`  | Rename symbol (built-in)           |
| `gra`  | Code action (built-in)             |
| `grr`  | References (built-in)              |
| `gri`  | Go to implementation (built-in)    |
| `grt`  | Go to type definition (built-in)   |
| `K`    | Hover documentation (built-in)     |
| `[d` / `]d` | Previous / next diagnostic   |
| `<leader>e`  | Show line diagnostic float   |
| `<leader>cf` | Format buffer (conform)      |

## Git (fugitive + gitsigns)

| Key          | Action              |
| ------------ | -------------------- |
| `<leader>gg` | Git status (fugitive) |
| `]h` / `[h`  | Next / previous hunk  |
| `<leader>hs` | Stage hunk            |
| `<leader>hr` | Reset hunk            |
| `<leader>hp` | Preview hunk          |
| `<leader>hb` | Blame line            |

## Harpoon

| Key           | Action              |
| ------------- | -------------------- |
| `<leader>la`  | Add current file     |
| `<leader>ll`  | Toggle quick menu     |
| `<leader>l1-4`| Jump to file 1-4      |
| `<leader>l]`  | Next harpoon file     |
| `<leader>l[`  | Previous harpoon file |

## Testing (vim-test)

| Key          | Action        |
| ------------ | -------------- |
| `<leader>tt` | Test nearest   |
| `<leader>tf` | Test file      |
| `<leader>ts` | Test suite     |
| `<leader>tl` | Test last      |
| `<leader>tv` | Test visit     |

## Just

| Key          | Action           |
| ------------ | ----------------- |
| `<leader>jj` | Select just recipe |

## Sidekick (Claude CLI)

| Key          | Action                     |
| ------------ | --------------------------- |
| `<leader>ac` | Toggle Claude CLI            |
| `<leader>aa` | Toggle sidekick CLI          |
| `<leader>as` | Select CLI tool              |
| `<leader>at` | Send current context         |
| `<leader>av` | Send visual selection         |
| `<leader>ap` | Select a prompt               |
| `<C-.>`      | Switch focus to/from CLI      |
| `<Tab>`      | Jump to / apply next edit suggestion |
