-- You can add your own plugins here or in other files in this directory!
--  I promise not to create any merge conflicts in this directory :)
--
-- See the kickstart.nvim README for more information
return {
  'ghillb/cybu.nvim',
  config = function()
    require('cybu').setup {
      position = {
        relative_to = 'win', -- win, editor, cursor
        anchor = 'topcenter', -- topleft, topcenter, topright,
        -- centerleft, center, centerright,
        -- bottomleft, bottomcenter, bottomright
        vertical_offset = 10, -- vertical offset from anchor in lines
        horizontal_offset = 0, -- vertical offset from anchor in columns
        max_win_height = 10, -- height of cybu window in lines
        max_win_width = 0.5, -- integer for absolute in columns
        -- float for relative to win/editor width
      },
      style = {
        path = 'relative', -- absolute, relative, tail (filename only),
        -- tail_dir (filename & parent dir)
        path_abbreviation = 'none', -- none, shortened
        border = 'rounded', -- single, double, rounded, none
        separator = ' ', -- string used as separator
        prefix = '…', -- string used as prefix for truncated paths
        padding = 1, -- left & right padding in number of spaces
        hide_buffer_id = true, -- hide buffer IDs in window
        devicons = {
          enabled = true, -- enable or disable web dev icons
          colored = true, -- enable color for web dev icons
          truncate = true, -- truncate wide icons to one char width
        },
        highlights = { -- see highlights via :highlight
          current_buffer = 'CybuFocus', -- current / selected buffer
          adjacent_buffers = 'CybuAdjacent', -- buffers not in focus
          background = 'CybuBackground', -- window background
          border = 'CybuBorder', -- border of the window
        },
      },
      behavior = { -- set behavior for different modes
        mode = {
          default = {
            switch = 'immediate', -- immediate, on_close
            view = 'rolling', -- paging, rolling
          },
          last_used = {
            switch = 'immediate', -- immediate, on_close
            view = 'paging', -- paging, rolling
            update_on = 'buf_enter', -- buf_enter, cursor_moved
          },
          auto = {
            view = 'rolling', -- paging, rolling
          },
        },
        show_on_autocmd = false, -- event to trigger cybu (eg. "BufEnter")
      },
      display_time = 0, -- time the cybu window is displayed
      exclude = { -- filetypes, cybu will not be active
        'neo-tree',
        'fugitive',
        'qf',
      },
      filter = {
        unlisted = true, -- filter & fallback for unlisted buffers
      },
      fallback = function() end, -- arbitrary fallback function
      -- used in excluded filetypes
    }
    vim.keymap.set('n', 'H', '<Plug>(CybuPrev)')
    vim.keymap.set('n', 'L', '<Plug>(CybuNext)')
    vim.keymap.set('n', '<s-tab>', '<plug>(CybuLastusedPrev)')
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
