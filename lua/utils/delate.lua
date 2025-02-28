local M = {}

local cmd = vim.api.nvim_create_autocmd
local rem = require("utils.rem")
local search = require("utils.search")
local tags = require("utils.tags")

--- TODO: What I need the code to do is: use a regular expression to match {{{type, then find the corresponding tag information, and finally redefine the cursor position in the database by looking up the tag information in the database and the tag information here. This ensures the robustness of the tag system under text restructuring.

local function read_file(file_path)
  local file = io.open(file_path, "r")
  if not file then
    error("无法打开文件: " .. file_path)
  end

  local lines = {}
  for line in file:lines() do
    table.insert(lines, line)
  end
  file:close()
  return lines
end

local function delete_lines(lines, lines_to_delete)
  local delete_set = {}
  for _, line in ipairs(lines_to_delete) do
    delete_set[line] = true
  end

  local new_lines = {}
  for i, line in ipairs(lines) do
    if not delete_set[i] then
      table.insert(new_lines, line)
    end
  end

  return new_lines
end

local function write_file(file_path, lines)
  local file = io.open(file_path, "w")
  if not file then
    error("无法写入文件: " .. file_path)
  end

  for _, line in ipairs(lines) do
    file:write(line .. "\n")
  end
  file:close()
end

function M.delete_lines_in_file(file_path, lines_to_delete)
  local lines = read_file(file_path)
  local new_lines = delete_lines(lines, lines_to_delete)
  write_file(file_path, new_lines)
end

return M
