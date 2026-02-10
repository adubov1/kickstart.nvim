return {
  'ghillb/cybu.nvim',
  config = function()
    require('cybu').setup {
      position = {
        relative_to = 'win',
        anchor = 'topcenter',
        vertical_offset = 10,
        horizontal_offset = 0,
        max_win_height = 10,
        max_win_width = 0.5,
      },
      style = {
        path = 'relative',
        path_abbreviation = 'none',
        border = 'rounded',
        separator = ' ',
        prefix = '…',
        padding = 1,
        hide_buffer_id = true,
        devicons = {
          enabled = true,
          colored = true,
          truncate = true,
        },
        highlights = {
          current_buffer = 'CybuFocus',
          adjacent_buffers = 'CybuAdjacent',
          background = 'CybuBackground',
          border = 'CybuBorder',
        },
      },
      behavior = {
        mode = {
          default = {
            switch = 'immediate',
            view = 'rolling',
          },
          last_used = {
            switch = 'immediate',
            view = 'paging',
            update_on = 'buf_enter',
          },
          auto = {
            view = 'rolling',
          },
        },
        show_on_autocmd = false,
      },
      display_time = 0,
      exclude = {
        'neo-tree',
        'fugitive',
        'qf',
      },
      filter = {
        unlisted = true,
      },
      fallback = function() end,
    }
    vim.keymap.set('n', '<c-i>', '<c-i>')
    vim.keymap.set('n', '<Tab>', function()
      local alt = vim.fn.bufnr '#'
      if alt > 0 and vim.fn.buflisted(alt) == 1 then
        vim.cmd 'b#'
      else
        vim.notify('No alternate buffer', vim.log.levels.WARN)
      end
    end, { desc = 'Toggle last buffer' })
  end,
}
