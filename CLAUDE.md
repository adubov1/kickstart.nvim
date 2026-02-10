# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Overview

This is a Neovim configuration using **lazy.nvim** as the plugin manager, optimized for **Ruby/Rails development** with modern tooling (blink.cmp, conform.nvim, tree-sitter main branch).

## Architecture

**Entry point**: `init.lua` (~170 lines) contains only: leader key, options, keymaps, Neovide config, autocommands, and lazy.nvim bootstrap. No plugin specs live here.

**Plugin organization**:
- `lua/plugins/` — all plugin specs, one file per plugin (auto-imported via `{ import = 'plugins' }`)

**Adding a new plugin**: Create a new `.lua` file in `lua/plugins/` that returns a lazy.nvim plugin spec table. It will be auto-loaded.

## Key Patterns

- **Leader key**: Space
- **LSP servers** are configured in `lua/plugins/lsp.lua` via a `servers` table, then iterated with `vim.lsp.config()` + `vim.lsp.enable()`. Mason auto-installs servers listed there plus extras in `ensure_installed`.
- **LSP keymaps** are set in an `LspAttach` autocmd callback in `lua/plugins/lsp.lua`, making them buffer-local. Telescope also sets LSP-related keymaps via its own `LspAttach` autocmd in `lua/plugins/telescope.lua`.
- **Completion**: blink.cmp (`lua/plugins/blink-cmp.lua`) with `super-tab` preset. Sources: lsp, path, snippets (LuaSnip).
- **Formatting**: conform.nvim (`lua/plugins/conform.lua`) with format-on-save. Formatters: `stylua` (Lua), `herb_format` + `rubocop` (ERB). Manual format: `<leader>f`.
- **Treesitter**: `lua/plugins/treesitter.lua` — uses main branch. Languages are explicitly listed; `vim.treesitter.start()` is called via FileType autocmd. Addon plugins (autotag, endwise, context, textobjects) are in the same file.
- **Diagnostics**: Configured in `init.lua`. virtual_text enabled, underline only for ERROR severity, floating windows with rounded borders.

## Important Keymaps

- `jk` / `Jk` / `JK` — escape from insert mode
- `<leader>sf` — find files, `<leader>sg` — live grep, `<leader><leader>` — buffers
- `H` / `L` — cycle buffers, `<Tab>` — toggle last buffer
- `gd` — go to definition, `grr` — references, `grn` — rename (LSP, buffer-local)
- `<leader>bd` — delete buffer, `<leader>bO` — close other buffers
- `ga*` — Rails navigation (gac=controller, gam=model, gav=view, etc.)
- `-` — open mini.files browser
- `gsa`/`gsd`/`gsr` — mini.surround add/delete/replace

## LSP Servers

Currently configured: `ruby_lsp` (with Rails addon), `herb_ls`, `lua_ls`. Mason auto-installs these plus `stylua`.

## Neovide

The config detects Neovide (GUI) and applies special handling: clipboard keymaps (Cmd+C/V), zoom (Cmd+/- /0), and disables mini.animate.
