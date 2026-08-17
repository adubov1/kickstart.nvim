local M = {}

local done

function M.setup()
  if done then return end
  done = true
  pcall(require, 'snacks.picker')
  Snacks.util.set_hl({
    JJCurrent = 'SnacksPickerUndoCurrent',
    JJChangeId = 'SnacksPickerGitCommit',
    JJImmutable = 'DiagnosticWarn',
    JJEmpty = 'SnacksPickerDimmed',
    GitChange = 'SnacksPickerJJChangeId',
    GitBookmarks = 'SnacksPickerGitBranch',
    GitConflict = 'SnacksPickerGitStatusUnmerged',
  }, { prefix = 'SnacksPicker', default = true })
end

return M
