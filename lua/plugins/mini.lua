return {
  'nvim-mini/mini.nvim',
  version = '*',
  config = function()
    require('mini.icons').setup()

    local ts_spec = require('mini.ai').gen_spec.treesitter
    require('mini.ai').setup {
      n_lines = 200,
      custom_textobjects = {
        s = ts_spec {
          a = '@string.outer',
          i = '@string.inner',
        },
        m = ts_spec { a = '@function.outer', i = '@function.inner' },
        c = ts_spec { a = '@class.outer', i = '@class.inner' },
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
    statusline.section_location = function() return '%2l:%-2v' end

    require('mini.jump').setup()

    require('mini.move').setup {
      mappings = {
        left = '<M-H>',
        right = '<M-L>',
        down = '<M-J>',
        up = '<M-K>',

        line_left = '<M-H>',
        line_right = '<M-L>',
        line_down = '<M-J>',
        line_up = '<M-K>',
      },
    }

    require('mini.files').setup()
    vim.keymap.set('n', '-', function()
      if MiniFiles.close() then return end
      local buf_name = vim.api.nvim_buf_get_name(0)
      local path = vim.fn.filereadable(buf_name) == 1 and buf_name or vim.fn.getcwd()
      MiniFiles.open(path)
      MiniFiles.reveal_cwd()
    end, { desc = 'Toggle Mini Files' })

    vim.api.nvim_create_autocmd('User', {
      pattern = 'MiniFilesActionRename',
      callback = function(event) Snacks.rename.on_rename_file(event.data.from, event.data.to) end,
    })
  end,
}
