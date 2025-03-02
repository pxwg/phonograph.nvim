local M = {}
function M.get_db_path()
  local buf = vim.api.nvim_get_current_buf()
  local file_path = vim.api.nvim_buf_get_name(buf)
  file_path = file_path:gsub("^%s+", ""):gsub("%s+$", ""):gsub("%.", ""):gsub("/", "_")
  return vim.fn.expand("$HOME") .. "/.local/state/nvim/note/" .. file_path .. ".sqlite"
end

return M
