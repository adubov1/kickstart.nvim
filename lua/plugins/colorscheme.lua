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
}

local colorscheme = colorschemes['mac_clear']

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
