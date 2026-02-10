return {
  {
    'folke/tokyonight.nvim',
    priority = 1000,
    config = function()
      require('tokyonight').setup {
        style = 'night',
        styles = {
          comments = { italic = false },
        },
      }
      vim.cmd.colorscheme 'tokyonight'
    end,
  },
}
