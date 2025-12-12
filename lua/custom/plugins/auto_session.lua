-- You can add your own plugins here or in other files in this directory!
--  I promise not to create any merge conflicts in this directory :)
--
-- See the kickstart.nvim README for more information
return {
  {
    'rmagatti/auto-session',
    lazy = false,

    ---enables autocomplete for opts
    ---@module "auto-session"
    ---@type AutoSession.Config
    opts = {
      suppressed_dirs = { '~/', '~/Projects', '~/Downloads', '/' },
      pre_save_cmds = {
        'Neotree close',
      },
      post_restore_cmds = {
        'Neotree action=show reveal_force_cwd',
        'windo wincmd l',
        'tabdo bnext', -- weird hack, autosession always opens prev buf
      },
    },
  },
}
