return {
  url = 'git@github.com:ducharmemp/straps.git',
  config = function()
    require('straps').setup {
      model = 'claude-opus-5',
      default_max_tokens = nil,
      max_turns = 128,
      stall_limit = 6,
      max_tool_result_bytes = 100000,
    }
  end,
}
