return {
  'stevearc/conform.nvim',
  event = { 'BufWritePre' },
  cmd = { 'ConformInfo' },
  keys = {
    {
      '<leader>F',
      function() require('conform').format { async = true, lsp_format = 'fallback' } end,
      mode = '',
      desc = '[F]ormat buffer',
    },
  },

  config = function()
    vim.g.fmt_on_save = true

    require('conform').setup {
      notify_on_error = true,
      default_format_opts = { lsp_format = 'fallback' },
      formatters_by_ft = { lua = { 'stylua' } },
      format_on_save = function(bufnr)
        local disable_filetypes = { c = true, cpp = true }

        local filetype_disabled = disable_filetypes[vim.bo[bufnr].filetype] == true
        local global_disabled = vim.g.autoformat == false
        local buffer_disabled = vim.b[bufnr].autoformat == false

        if filetype_disabled or buffer_disabled or global_disabled then return nil end

        return { timeout_ms = 500 }
      end,
    }
  end,

  init = function()
    vim.api.nvim_create_autocmd('User', {
      pattern = 'VeryLazy',
      callback = function()
        Snacks.toggle({
          name = 'Format on save',
          get = function() return vim.g.autoformat ~= false end,
          set = function(state) vim.g.autoformat = state end,
        }):map '<leader>tf'

        Snacks.toggle({
          name = 'Format on save (buffer)',
          get = function()
            local b = vim.b.autoformat
            if b == nil then return vim.g.autoformat ~= false end
            return b
          end,
          set = function(state) vim.b.autoformat = state end,
        }):map '<leader>tF'
      end,
    })
  end,
}
