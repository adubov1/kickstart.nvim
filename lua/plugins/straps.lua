return {
  url = 'git@github.com:ducharmemp/straps.git',
  lazy = false,
  config = function()
    require('straps').setup {
      model = 'claude-opus-5',
      default_max_tokens = nil,
      max_turns = 128,
      stall_limit = 6,
      max_tool_result_bytes = 100000,
    }

    vim.api.nvim_set_hl(0, 'StrapsTool', { link = 'Constant' })
  end,
  keys = {
    {
      '<leader>an',
      '<CMD>Straps<CR>',
      desc = 'New Straps session',
    },
    {
      '<leader>ar',
      '<CMD>StrapsResume<CR>',
      desc = 'Resume Straps session',
    },
    {
      '<leader>ac',
      '<CMD>Straps<CR>',
      desc = 'Continue current Straps session',
    },
  },
}
