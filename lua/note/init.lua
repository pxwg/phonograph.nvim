local M = {}
M.opts = {}
local default_opts = require("note.default").defalut_opts

function M.setup(user_opts)
  M.opts = vim.tbl_deep_extend("force", default_opts, user_opts or {})

  -- print(vim.inspect(M.opts.ui.selection.border))

  require("note.keymaps")
  require("note.autocmd")
  require("utils.db")
  require("utils.paste")
end

return M
