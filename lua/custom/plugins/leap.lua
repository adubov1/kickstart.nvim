-- You can add your own plugins here or in other files in this directory!
--  I promise not to create any merge conflicts in this directory :)
--
-- See the kickstart.nvim README for more information
return {
  {
    'andyg/leap.nvim',
    lazy = false,
    url = 'https://codeberg.org/andyg/leap.nvim',
    config = function()
      vim.keymap.set({ 'n', 'x', 'o' }, 's', '<Plug>(leap)')
      vim.keymap.set('n', 'S', '<Plug>(leap-from-window)')
      vim.keymap.set({ 'x', 'o' }, 'R', function()
        require('leap.treesitter').select {
          opts = require('leap.user').with_traversal_keys('R', 'r'),
        }
      end)
      require('leap').opts.preview = function(ch0, ch1, ch2)
        return not (ch1:match '%s' or (ch0:match '%a' and ch1:match '%a' and ch2:match '%a'))
      end

      -- Define equivalence classes for brackets and quotes, in addition to
      -- the default whitespace group:
      require('leap').opts.equivalence_classes = {
        ' \t\r\n',
        '([{',
        ')]}',
        '\'"`',
      }

      -- Use the traversal keys to repeat the previous motion without
      -- explicitly invoking Leap:
      require('leap.user').set_repeat_keys('<enter>', '<backspace>')
    end,
  },
}
