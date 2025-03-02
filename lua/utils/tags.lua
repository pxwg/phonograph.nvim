local M = {}

--- Generate a timestamp tag
--- @return number timestamp tag
function M.generateTimestampTag()
  local date = os.date("*t")
  local out = vim.fn.str2nr(
    string.format("%04d%02d%02d%02d%02d%02d", date.year, date.month, date.day, date.hour, date.min, date.sec)
  )
  return out
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
        return { line = line, type = tag.type, tag = tag.tag }
      end
    end

    file:close()
  end
end

--- @return table the line numbers in the current buffer
function M.get_folded_lines()
  local folded_lines = {}
  local total_lines = vim.api.nvim_buf_line_count(0)

  for line = 1, total_lines do
    if vim.fn.foldclosed(line) == line then
      table.insert(folded_lines, line)
    end
  end

  return folded_lines
end

--- Get all the tags in the folded lines
--- @param folded_lines table the folded lines
--- @return table the tags in the folded lines
function M.get_folded_tags(folded_lines)
  local output = {}
  for i = 1, #folded_lines do
    table.insert(output, M.get_tag_on_line(folded_lines[i]))
  end
  return output
end

--- Get tags in the base
--- @param tags table the tags table
--- @param path string the path
--- @return table the tags in the base {{line = string, type = string, tag = string},...}
function M.get_tag_on_line_base(tags, path)
  local file = io.open(path, "r")
  if not file then
    vim.notify("File not found: " .. path, vim.log.levels.ERROR)
    return { { line = "", type = "", tag = "" } }
  end

  local output = {}
  for line in file:lines() do
    for i = 1, #tags do
      if line:find(tags[i].tag) then
        table.insert({ line = line, type = tags[i].type, tag = tags[i].tag }, output)
      end
    end
  end

  file:close()

  return output
end

function M.compare_tags(tags1, tags2)
  local output2 = {}

  for i = 1, #tags2 do
    local found = false
    for j = 1, #tags1 do
      if tags2[i].tag == tags1[j].tag then
        found = true
        break
      end
    end
    if not found then
      table.insert(output2, { tag = tags2[i], num = i })
    end
  end

  return output2
end

--- Get the tag line
--- @param tags table the tag
--- @return table the tag line
function M.get_tag_line(tags)
  local output = {}
  for i = 1, #tags do
    table.insert(tags[i].line, output)
  end
  return output
end

return M
