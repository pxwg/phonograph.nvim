local M = {}

--- @return string The comment string
local function get_comment_string()
  local filetype = vim.bo.filetype
  local commentstring = vim.bo.commentstring
  if commentstring == "" then
    commentstring = "// %s"
  end
  return commentstring
end

--- @param  input string The input string to be commented
--- @return string The commented string
function M.comment_string(input)
  local commentstring = get_comment_string()
  return commentstring:format(input)
end

--- input the table of bookmarks, return the comment of note
--- @param  ... string[] The note to be inserted
--- @return nil
function M.insert_note_at_cursor(...)
  local args = { ... }
  args = table.unpack(args)
  local note = "NOTE : " .. table.concat(args, ", ")
  local comment_note = M.comment_string(note)
  local row, _ = table.unpack(vim.api.nvim_win_get_cursor(0))
  vim.api.nvim_buf_set_lines(0, row - 1, row - 1, false, { comment_note })
end

function M.insert_table_at_cursor(tbl)
  local row, col = table.unpack(vim.api.nvim_win_get_cursor(0))
  for i, line in ipairs(tbl) do
    vim.api.nvim_buf_set_lines(0, row + i - 1, row + i - 1, false, { line })
  end
end

return M
