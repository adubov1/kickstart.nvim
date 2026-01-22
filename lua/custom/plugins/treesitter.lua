-- You can add your own plugins here or in other files in this directory!
--  I promise not to create any merge conflicts in this directory :)
--
-- See the kickstart.nvim README for more information

-- Additional treesitter functionality
return {
  { 'windwp/nvim-ts-autotag', opts = {} },
  { 'RRethy/nvim-treesitter-endwise', dependencies = { 'nvim-treesitter/nvim-treesitter' } },
  {
    'nvim-treesitter/nvim-treesitter-context',
    version = '*',
    dependencies = { 'nvim-treesitter/nvim-treesitter' },
    opts = {
      max_lines = 5,
      multiline_threshold = 2,
    },
  },
  {
    'nvim-treesitter/nvim-treesitter-textobjects',
    version = '*',
    dependencies = { 'nvim-treesitter/nvim-treesitter' },
    config = function()
      require('nvim-treesitter.configs').setup {}
    end,
  },
}
