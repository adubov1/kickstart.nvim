-- You can add your own plugins here or in other files in this directory!
--  I promise not to create any merge conflicts in this directory :)
--
-- See the kickstart.nvim README for more information
return {
  {
    'akinsho/bufferline.nvim',
    version = '*',
    dependencies = 'nvim-tree/nvim-web-devicons',
    config = function(_, opts)
      require('bufferline').setup(opts)
      local map = vim.keymap.set

      map('n', '<leader>bH', '<Cmd>BufferLineCloseLeft<CR>', { desc = 'Delete buffers to the left' })
      map('n', '<leader>bL', '<Cmd>BufferLineCloseRight<CR>', { desc = 'Delete buffers to the right' })

      map('n', 'H', '<Cmd>BufferLineCyclePrev<CR>', { desc = 'Switch to the previous buffer' })
      map('n', 'L', '<Cmd>BufferLineCycleNext<CR>', { desc = 'Switch to the next buffer' })

      map('n', '<leader>b[', '<Cmd>BufferLineMovePrev<CR>', { desc = 'Move buffer left' })
      map('n', '<leader>b]', '<Cmd>BufferLineMoveNext<CR>', { desc = 'Move buffer right' })
    end,
  },
}
