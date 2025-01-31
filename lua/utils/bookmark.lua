local M = {}

--- @return string ... The comment string
local function get_comment_string()
  local commentstring = vim.bo.commentstring
  if commentstring == "" then
    commentstring = "// %s"
    --- latex "% %s" could not be formatted
  elseif vim.bo.filetype == "tex" then
    commentstring = "%% %s"
  end
  return commentstring
end

--- @param  input string The input string to be commented
--- @return string ... The commented string
function M.comment_string(input)
  local commentstring = get_comment_string()
  return commentstring:format(input)
end

--- input the table of bookmarks, return the comment of note
--- @param  titles string[] The note to be inserted
--- @return nil
function M.insert_note_at_cursor(titles)
  local filtered_args = {}
  for _, arg in ipairs(titles) do
    if arg ~= nil and arg ~= "" then
      table.insert(filtered_args, tostring(arg))
    end
  end
  local note = "MARK : " .. table.concat(filtered_args, ", ")
  local comment_note = M.comment_string(note)
  local cursor_pos = vim.api.nvim_win_get_cursor(0)
  local row = cursor_pos[1]
  vim.api.nvim_buf_set_lines(0, row - 1, row - 1, false, { comment_note })
end

return M
