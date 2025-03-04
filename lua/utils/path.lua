local M = {}
function M.get_db_path()
  local buf = vim.api.nvim_get_current_buf()
  local file_path = vim.api.nvim_buf_get_name(buf)
  file_path = file_path:gsub("^%s+", ""):gsub("%s+$", ""):gsub("%.", ""):gsub("/", "_")
  local path = vim.fn.expand("$HOME") .. "/.local/state/nvim/note/" .. file_path .. ".sqlite"
  return path
end

function M.file_exists(file_path)
  local stat = vim.loop.fs_stat(file_path)
  return stat ~= nil
end

function M.check_db_file_exists()
  local db_path = M.get_db_path()
  return M.file_exists(db_path)
end

return M
