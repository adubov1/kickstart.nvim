return {
  'sergey-arkhipov/rails-nvim',
  name = 'rails-nvim',
  ft = 'ruby',
  config = function()
    require('rails-nvim').setup()
  end,
  keys = {
    { 'ga', '', desc = 'Rails fast move', mode = 'n', noremap = true },
    { 'gac', '<cmd>GC<cr>', desc = 'Controller', mode = 'n', noremap = true },
    { 'gah', '<cmd>GH<cr>', desc = 'Helper', mode = 'n', noremap = true },
    { 'gam', '<cmd>GM<cr>', desc = 'Model', mode = 'n', noremap = true },
    { 'gar', '<cmd>GR<cr>', desc = 'Route', mode = 'n', noremap = true },
    { 'gat', '<cmd>GS<cr>', desc = 'Spec', mode = 'n', noremap = true },
    { 'gav', '<cmd>GV<cr>', desc = 'View', mode = 'n', noremap = true },
  },
}
