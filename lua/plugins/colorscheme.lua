local colorschemes = {
  mac_clear = {
    url = 'https://github.com/boningmaple/mac-clear',
    name = 'mac-clear',
    variant = 'mac-clear',
  },
  kanagawa = {
    url = 'rebelot/kanagawa.nvim',
    name = 'kanagawa',
    variant = 'kanagawa-wave',
  },
  luna = {
    url = 'wtfox/luna.nvim',
    name = 'luna',
    variant = 'luna',
  },
}

local colorscheme = colorschemes['luna']

return {
  {
    colorscheme['url'],
    priority = 1000,
    config = function()
      require(colorscheme['name']).setup {}
      vim.cmd.colorscheme(colorscheme['variant'])
    end,
  },
}
