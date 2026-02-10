return {
  'nvim-mini/mini.nvim',
  version = '*',
  config = function()
    local ts_spec = require('mini.ai').gen_spec.treesitter
    require('mini.ai').setup {
      n_lines = 500,
      custom_textobjects = {
        s = ts_spec {
          a = '@string.outer',
          i = '@string.inner',
        },
      },
      search_method = 'cover_or_next',
    }

    require('mini.surround').setup {
      respect_selection_type = true,
      custom_surroundings = {
        d = { output = { left = 'do\n', right = '\nend' } },
      },
      mappings = {
        add = 'sa',
        delete = 'sd',
        replace = 'sr',
      },
    }

    local statusline = require 'mini.statusline'
    statusline.setup { use_icons = vim.g.have_nerd_font }
    ---@diagnostic disable-next-line: duplicate-set-field
    statusline.section_location = function()
      return '%2l:%-2v'
    end

    require('mini.jump').setup()
    require('mini.jump2d').setup()

    require('mini.move').setup()

    require('mini.files').setup()
    vim.keymap.set('n', '-', function()
      if MiniFiles.close() then
        return
      end
      local buf_name = vim.api.nvim_buf_get_name(0)
      local path = vim.fn.filereadable(buf_name) == 1 and buf_name or vim.fn.getcwd()
      MiniFiles.open(path)
      MiniFiles.reveal_cwd()
    end, { desc = 'Toggle Mini Files' })

    vim.api.nvim_create_autocmd('User', {
      pattern = 'MiniFilesActionRename',
      callback = function(event)
        Snacks.rename.on_rename_file(event.data.from, event.data.to)
      end,
    })
  end,
}
