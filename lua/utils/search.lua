local M = {}

--- Find the Mark symbol at the start of the line
function M.find_at_line_start()
  local search_pattern = "'-- MARK :'"
  local cmd = string.format("rg -n '%s' %s", search_pattern, vim.fn.expand("%:p"))
  local result = vim.fn.systemlist(cmd)

  if vim.v.shell_error ~= 0 then
    cmd = string.format("grep -n '%s' %s", search_pattern, vim.fn.expand("%:p"))
    result = vim.fn.systemlist(cmd)
  end

  local line_numbers = {}

  for _, line in ipairs(result) do
    local line_number = tonumber(vim.split(line, ":")[2])
    if line_number then
      table.insert(line_numbers, line_number)
    end
  end

  return line_numbers
end

return M
