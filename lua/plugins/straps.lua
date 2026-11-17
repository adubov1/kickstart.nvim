local opts = {
  keymaps = '<leader>a',
  extensions = {
    classifier = false,
    renamer = { auto = { enabled = false } },
  },
}

return {
  'ducharmemp/straps-suite',
  lazy = false,
  dependencies = {
    'ducharmemp/straps',
    'ducharmemp/straps-divergent',
    'ducharmemp/straps-exoskeleton',
    'ducharmemp/straps-chartifier',
    { 'ducharmemp/buff.nvim', commit = '45ad0cb763138be7eeb03436bd34f0add7036257' },
    'ducharmemp/straps-buff',
    'ducharmemp/straps-kagi',
    'ducharmemp/straps-renamer',
    'ducharmemp/straps-classifier',
  },
  init = function(plugin)
    vim.opt.runtimepath:prepend(plugin.dir)
    require('straps_suite').prepare(opts)
  end,
  config = function() require('straps_suite').setup(opts) end,
}
