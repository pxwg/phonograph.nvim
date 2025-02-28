local M = {}

--- Generate a timestamp tag
--- @return string timestamp tag
function M.generateTimestampTag()
  local date = os.date("*t")
  return string.format("%04d%02d%02d%02d%02d%02d", date.year, date.month, date.day, date.hour, date.min, date.sec)
end

--- Get the tag under the cursor -- Open the file under the cursor
--- @param current_line number the current line number
--- @return table tag
function M.get_tag_on_line(current_line)
  local current_line_content = vim.api.nvim_buf_get_lines(0, current_line - 1, current_line, false)[1]

  if not current_line_content:find("{{{") then
    return { tag = nil, type = nil }
  end

  local first_letter = current_line_content:match("%a+")
  local target_line = current_line + 2

  local line_content = vim.api.nvim_buf_get_lines(0, target_line - 1, target_line, false)[1]

  local number = line_content:match("%d+")

  if number then
    return { tag = number, type = first_letter }
  else
    return { tag = nil, type = first_letter }
  end
end

return M
