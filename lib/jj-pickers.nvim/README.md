# jj-pickers.nvim

Two [snacks.nvim](https://github.com/folke/snacks.nvim) pickers for [Jujutsu](https://github.com/jj-vcs/jj).

- **`jj_changes`** — files changed in a revision (default `@`). Per-file rows, wide-context
  diff preview parked on the first hunk, `<CR>` opens the file at the change.
- **`jj_revisions`** — revisions on the current branch (`trunk()..@`), capped at 20. jj's own
  `@` / `○` / `◆` node column, `<CR>` runs `jj edit` to switch.

## Requirements

- Neovim >= 0.10 (`vim.system`, `vim.fs.root`, `vim.uv`)
- `jj` >= 0.30 (templates: `path`, `status_char`, `current_working_copy`, `local_bookmarks`)
- `folke/snacks.nvim` with `picker` enabled

`:checkhealth jj-pickers` verifies all of the above plus the current repo.

## Install

```lua
{
  'adubov1/jj-pickers.nvim',
  dependencies = { 'folke/snacks.nvim' },
  cmd = { 'JjChanges', 'JjRevisions' },
  keys = {
    { '<leader>jj', function() require('jj-pickers').changes() end, desc = 'jj changed files in @' },
    { '<leader>jl', function() require('jj-pickers').revisions() end, desc = 'jj revisions on branch' },
  },
  opts = {},
}
```

## Configuration

```lua
require('jj-pickers').setup {
  revset = 'trunk()..@',
  limit = 20,
  revision = '@',
  on_revision = 'edit', -- or 'new'
  context = 12,
  keys = nil,           -- e.g. { changes = '<leader>jj', revisions = '<leader>jl' }
}
```

Appearance and layout are not configured here. Both pickers are ordinary snacks sources, so
use snacks' own config:

```lua
{ 'folke/snacks.nvim', opts = { picker = { sources = {
  jj_revisions = { layout = { preset = 'vertical' } },
} } } }
```

## Keys

### `jj_changes`

| key | action |
|---|---|
| `<CR>` | open the file at the first hunk |
| `<c-s>` `<c-v>` `<c-t>` | split / vsplit / tab |
| `<c-o>` | switch to the revisions picker |
| `<c-y>` | yank absolute path |

### `jj_revisions`

| key | action |
|---|---|
| `<CR>` | `jj edit` (or `jj new`, per `on_revision`) |
| `<c-e>` | `jj edit` — `@` becomes this revision; later saves amend it in place |
| `<a-n>` | `jj new` — empty child; the right move on an immutable revision |
| `<c-l>` | drill into this revision's changed files |
| `<c-y>` | yank change id |
| `<a-a>` | lift the 20-row cap |

## Notes

`jj edit` prompts when buffers are unsaved. This is not politeness: jj snapshots the working
copy from disk, so an unwritten buffer still belongs to the revision you are leaving, and
saving it after the switch would land that work in a different change.

`trunk()` falls back to `root()` in a repo with no remote bookmarks, which would turn
`trunk()..@` into the whole history. jj-pickers detects that, warns, and uses `::@` instead.

## Events

`User JjPickersWorkingCopy` fires after a successful `jj edit`/`jj new`, with
`data = { root, change_id, verb }`. `:checktime` is already issued; use this to refresh
anything else.

```lua
vim.api.nvim_create_autocmd('User', {
  pattern = 'JjPickersWorkingCopy',
  callback = function() require('gitsigns').refresh() end,
})
```

## Vendoring

This repo can be developed in place inside a Neovim config by pointing lazy.nvim at it with
`dir = vim.fn.stdpath 'config' .. '/lib/jj-pickers.nvim'`. Deleting that one line switches to
the published version; lazy derives the URL from the plugin name and skips all git tasks for
local directories, so the vendored form never clones or writes a lockfile entry.
