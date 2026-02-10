return {
  'stevearc/conform.nvim',
  event = { 'BufWritePre' },
  cmd = { 'ConformInfo' },
  keys = {
    {
      '<leader>F',
      function()
        require('conform').format { async = true, lsp_format = 'fallback' }
      end,
      mode = '',
      desc = '[F]ormat buffer',
    },
  },
  config = function()
    require('conform').setup {
      notify_on_error = true,
      default_format_opts = {
        lsp_format = 'fallback',
      },
      format_on_save = function(bufnr)
        local disable_filetypes = { c = true, cpp = true }
        if disable_filetypes[vim.bo[bufnr].filetype] then
          return nil
        else
          return { timeout_ms = 2500 }
        end
      end,
      formatters_by_ft = {
        lua = { 'stylua' },
        eruby = { 'herb_format', 'rubocop' },
      },
      formatters = {
        herb_format = {
          command = 'herb-format',
          args = { '--config-file', '.herb.yml', '-' },
          stdin = true,
        },
      },
    }
  end,
}
