--- TODO: open the pdf/url under the cursor when we moved to the bookmark(which is folded text in neovim)
local M = {}

--- Get the tag under the cursor -- Open the file under the cursor
--- @return table tag
function M.get_tag_under_cursor()
  local current_line = vim.api.nvim_win_get_cursor(0)[1]
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

--- Search file from tag
--- @param tag table {tag: string, type: string}
--- @param path string the log file path
--- @return table the line that contains the tag
function M.search_from_tag(tag, path)
  if tag.type == "pdf" or tag.type == "url" then
    local file = io.open(path, "r")
    if not file then
      vim.notify("File not found: " .. path, vim.log.levels.ERROR)
      return { line = nil, type = tag.type }
    end

    for line in file:lines() do
      if line:find(tag.tag) then
        file:close()
        return { line = line, type = tag.type }
      end
    end

    file:close()
  end
end

return M
