return {
  {
    'nvim-treesitter/nvim-treesitter',
    branch = 'main',
    config = function()
      local filetypes = {
        'bash',
        'c',
        'diff',
        'html',
        'lua',
        'luadoc',
        'markdown',
        'markdown_inline',
        'query',
        'vim',
        'vimdoc',
        'ruby',
        'rbs',
        'toml',
      }
      require('nvim-treesitter').install(filetypes)

      vim.api.nvim_create_autocmd('FileType', {
        pattern = filetypes,
        callback = function() vim.treesitter.start() end,
      })

      vim.api.nvim_create_autocmd('User', {
        pattern = 'TSUpdate',
        callback = function()
          require('nvim-treesitter.parsers').straps = {
            install_info = {
              path = '~/.config/nvim/lib/straps',
              location = 'tree-sitter-straps',
            },
          }
        end,
      })
    end,
  },
  { 'windwp/nvim-ts-autotag', dependencies = { 'nvim-treesitter/nvim-treesitter' }, opts = {} },
  { 'RRethy/nvim-treesitter-endwise', dependencies = { 'nvim-treesitter/nvim-treesitter' } },
  {
    'nvim-treesitter/nvim-treesitter-context',
    version = '*',
    dependencies = { 'nvim-treesitter/nvim-treesitter' },
    opts = {
      multiwindow = true,
      line_numbers = false,
      max_lines = 5,
      multiline_threshold = 2,
    },
  },
  {
    'nvim-treesitter/nvim-treesitter-textobjects',
    branch = 'main',
    dependencies = { 'nvim-treesitter/nvim-treesitter' },
    init = function() vim.g.no_plugin_maps = true end,
  },
}
