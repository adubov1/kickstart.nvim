-- Neo-tree is a Neovim plugin to browse the file system
-- https://github.com/nvim-neo-tree/neo-tree.nvim

if true then
  return {}
end

return {
  'nvim-neo-tree/neo-tree.nvim',
  version = '*',
  dependencies = {
    'nvim-lua/plenary.nvim',
    'nvim-tree/nvim-web-devicons', -- not strictly required, but recommended
    'MunifTanjim/nui.nvim',
  },
  lazy = false,
  keys = {
    { '\\', ':Neotree reveal reveal_force_cwd<CR>', desc = 'NeoTree reveal', silent = true },
  },
  opts = {
    auto_clean_after_session_restore = false,
    window = {
      width = 30,
    },
    filtered_items = {
      hide_dotfiles = false,
      hide_gitignored = false,
    },
    filesystem = {
      hijack_netrw_behavior = 'disabled',
      window = {
        mappings = {
          ['\\'] = 'close_window',
        },
      },
    },
  },
}
