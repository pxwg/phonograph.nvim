local M = {}

--- @return string ... The comment string
local function get_comment_string()
  local commentstring = vim.bo.commentstring
  -- print(commentstring)
  if commentstring == "" then
    --- FIX: hard-coded comment string for LaTeX
    commentstring = "// %s"
    --- latex "% %s" could not be formatted
  elseif vim.bo.filetype == "tex" then
    commentstring = "%% %s"
  end
  return commentstring
end

--- @param commented_string string The string with comment
--- @return string The uncommented string
local function uncomment_string(commented_string)
  --- FIX: hard-coded comment string for html comment in markdown
  if commented_string:match("^<!%-%-") and commented_string:match("%-%->$") then
    local uncommented = commented_string:gsub("^<!%-%-", ""):gsub("%-%->$", "")
    uncommented = uncommented:gsub("^%s+", ""):gsub("%s+$", "")
    return uncommented
  end

  local commentstring = get_comment_string()
  if not commentstring:find("%%s") then
    commentstring = commentstring .. " %s"
  end

  local escaped_commentstring = commentstring:gsub("%%", "%%%%"):gsub("%s", "%%s")
  local uncommented = commented_string:gsub("^" .. escaped_commentstring:format(""), "")
  uncommented = uncommented:gsub("^%s+", "")
  return uncommented
end

M.uncomment_string = uncomment_string

--- @param input table The input table whose strings are to be commented
--- @return table ... The table with each string commented
function M.comment_string(input)
  local commentstring = get_comment_string()
  local commented_table = {}
  for _, item in ipairs(input) do
    table.insert(commented_table, commentstring:format(item))
  end
  return commented_table
end

--- @param input table The input table whose strings are to be uncommented
--- @return table ... The table with each string uncommented
function M.uncomment_string_table(input)
  local uncommented_table = {}
  for i = 1, #input do
    table.insert(uncommented_table, uncomment_string(input[i]))
  end
  return uncommented_table
end

--- input the table of bookmarks, return the comment of note
--- @param  titles table The note to be inserted
--- @param format string The type of the input string
--- @return nil
function M.insert_note_at_cursor(titles, format)
  if not titles or #titles == 0 then
    vim.notify("note.nvim: Titles cannot be nil or empty!", vim.log.levels.ERROR)
    return
  end

  local filtered_args = {}
  for _, arg in ipairs(titles) do
    if arg ~= nil and arg ~= "" then
      table.insert(filtered_args, tostring(arg))
    end
  end

  if #filtered_args == 0 then
    vim.notify("Filtered arguments cannot be empty", vim.LOG.ERROR)
  end

  -- Split the note into lines
  local note_lines = { "{{{" .. format .. ": " .. filtered_args[1] }
  for _, arg in ipairs(filtered_args) do
    table.insert(note_lines, arg)
  end
  table.insert(note_lines, "}}}")

  local comment_line = M.comment_string(note_lines)

  local cursor_pos = vim.api.nvim_win_get_cursor(0)
  local row = cursor_pos[1]
  -- Insert the lines at the cursor position
  vim.api.nvim_buf_set_lines(0, row - 1, row - 1, false, comment_line)
end

return M
