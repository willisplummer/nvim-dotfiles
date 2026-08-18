# NVIM DOTFILES

I moved these to their own repo because I'm managing the rest of my config in
home-manager

This is going to be a really long line because I want to see what happens if I
exceed the number of characters

## Setup

clone the repo to ~/nvim and cd into the directory `cp .env.example .env` set
any environment variables

Plugins are managed by `vim.pack` (built into Neovim 0.12+), so there is nothing
to bootstrap. Start `nvim` and anything missing is cloned during startup.

## Plugins

Specs live in `lua/config/pack.lua`; per-plugin config lives in `lua/plugins/`.
Revisions are pinned in `nvim-pack-lock.json`, which is written by `vim.pack`
and tracked in git — don't edit it by hand.

- `:PackUpdate` — fetch updates, review the diff, `:w` to accept or `:q` to
  discard. Restart to pick up the new code.
- `:PackStatus` — review what's installed without fetching.
- `:PackClean` — delete plugins on disk that are no longer in the spec list.

To pin a plugin, set `version` on its spec to a tag, branch, or the revision
from the lockfile. `nvim-surround` uses `vim.version.range("*")` to follow its
latest release tag.

nvim-treesitter and its grammars come from Nix (`programs.neovim.plugins`), not
from `vim.pack`.

## Improvements To Do

- snippets/completions -- the keybindings are weird/i don't know how they work.
  (haven't figured out how to accept a snippet)
- figure out how to get debugger working with nix
- snacks picker instead of telescope?
- git diffing visualizer?
- still want a better tool for find and replacing
