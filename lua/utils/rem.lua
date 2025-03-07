-- getting and remembering the history of pdfs and urls
-- keymappings
local map = vim.keymap.set
local api = require("utils.api")
local data = require("utils.data")
local paths = require("utils.path")
local tags = require("utils.tags")
local log_root = vim.fn.expand("$HOME") .. "/.local/state/nvim/note/"

local M = {}

---@return string
function M.get_file_path()
  local buf = vim.api.nvim_get_current_buf()
  local file_path = vim.api.nvim_buf_get_name(buf)
  file_path = file_path:gsub("^%s+", ""):gsub("%s+$", ""):gsub("%.", ""):gsub("/", "_")
  return vim.fn.expand("$HOME") .. "/.local/state/nvim/note/" .. file_path .. ".txt"
end

---@param file_path string
---@return table
function M.read_file(file_path)
  local file = io.open(file_path, "r")
  local lines = {}
  if file then
    for line in file:lines() do
      table.insert(lines, line)
    end
    file:close()
  end
  return lines
end

---@param file_path string
---@param lines table
function M.write_file(file_path, lines)
  local file = io.open(file_path, "w")
  if file then
    for _, line in ipairs(lines) do
      file:write(line)
      if not line:match("\n$") then
        file:write("\n")
      end
    end
    file:close()
  else
    print("Error: Unable to create file " .. file_path)
  end
end

---@param lines table
---@param lines_to_insert table
---@param pos table? {row: number, col: number}
---@return table
function M.update_lines(lines, lines_to_insert, pos)
  pos = pos or { row = "", col = "" }
  local updated = false
  local new_lines = {}

  for _, line in ipairs(lines) do
    local row, col = line:match("{(%d+), (%d+),")
    if row and col and tonumber(row) == pos.row and tonumber(col) == pos.col then
      updated = true
    else
      table.insert(new_lines, line)
    end
  end

  if updated then
    -- Insert new lines at the position of the removed line
    for _, new_line in ipairs(lines_to_insert) do
      table.insert(new_lines, string.format("{%d, %d, %s}\n", pos.row, pos.col, new_line))
    end
  else
    -- Append new lines at the end if no existing line was updated
    for _, new_line in ipairs(lines_to_insert) do
      table.insert(new_lines, string.format("{%d, %d, %s}\n", pos.row, pos.col, new_line))
    end
  end

  return new_lines
end

---@param lines_to_insert table
---@param pos table {row: number, col: number}
function M.InsertLinesAtTop(lines_to_insert, pos)
  local file_path = M.get_file_path()
  vim.fn.mkdir(vim.fn.fnamemodify(file_path, ":h"), "p")

  local lines = M.read_file(file_path)
  local updated_lines = M.update_lines(lines, lines_to_insert, pos)
  M.write_file(file_path, updated_lines)
end

M.InsertPDFurl = {}

---@return string|nil
function M.InsertPDFurl:pdf()
  local pdf = api.ReturnSkimReadingState()
  local pdf_table = M.pdf_line_to_table(pdf)

  local pos = vim.api.nvim_win_get_cursor(0)
  pos = { row = pos[1], col = pos[2] }
  local col = tonumber(pos.row)

  local db_path = paths.get_db_path()

  data.create_tbl(db_path)

  if not pdf then
    vim.notify("Error: No pdf found!", vim.log.levels.ERROR)
    return nil
  else
    -- M.InsertLinesAtTop({ pdf }, pos)

    local inserted, result = pcall(function()
      data.add_tbl(db_path, "history", {
        path = pdf_table.path,
        type = "pdf",
        pos = pdf_table.pos,
        title = pdf_table.title,
        col = col,
        tag = pdf_table.tag,
      })
    end)
    if inserted then
      return pdf
    else
      vim.notify("phonograh.nvim: Failed to get reading state", vim.log.levels.ERROR)
      return pdf
    end
  end
end

---@return string|nil
function M.InsertPDFurl:url()
  local url = api.ReturnChormeReadingState()
  local url_table = M.url_line_to_table(url)

  local pos = vim.api.nvim_win_get_cursor(0)
  pos = { row = pos[1], col = pos[2] }
  local col = tonumber(pos.row)

  local db_path = paths.get_db_path()

  data.create_tbl(db_path)

  if not url then
    vim.notify("Error: No url found!", vim.log.levels.ERROR)
    return nil
  else
    -- M.InsertLinesAtTop({ url }, pos)
    local inserted, result = pcall(function()
      data.add_tbl(db_path, "history", {
        path = url_table.url,
        type = "url",
        pos = url_table.pos,
        title = url_table.title,
        col = col,
        tag = url_table.tag,
      })
    end)
    if inserted then
      return url
    else
      vim.notify("phonograh.nvim: Failed to get reading state", vim.log.levels.ERROR)
      return url
    end
  end
end

---@return table {pdf: string, url: string}
function M.InsertPDFurl:insert()
  local pos = vim.api.nvim_win_get_cursor(0)
  pos = { row = pos[1], col = pos[2] }
  local pdf = self:pdf()
  local url = self:url()
  M.InsertLinesAtTop({ pdf, url }, pos)
  return { pdf = pdf, url = url }
end

---@return table|nil {path: string, page: number, scrollY: number, url: string} or nil
function M.ExtractAndPrintFileInfo()
  local buf = vim.api.nvim_get_current_buf()
  local file_path = vim.api.nvim_buf_get_name(buf)

  local new_file_path = vim.fn.expand("$HOME") .. "/.local/state/nvim/note/" .. file_path:gsub("/", "_") .. ".txt"

  if vim.fn.filereadable(new_file_path) == 0 then
    print("Error: File does not exist " .. new_file_path)
    return
  end

  local file = io.open(new_file_path, "r")
  if not file then
    print("Error: Unable to open file " .. new_file_path)
    return
  end

  local content = file:read("*all")
  file:close()

  -- Extract information
  local path = content:match("path: ([^\n,]+)"):gsub("^%s+", ""):gsub("%s+$", "")
  local page = content:match("page: (%d+)")
  local scrollY = content:match("scrollY:(%d+)")
  local url = content:match("url:([^\n,]+)")

  -- Output table
  if path and page and scrollY and url then
    print("path: " .. path)
    print("page: " .. page)
    return { path, page, scrollY, url }
  else
    print("Error: Unable to extract required information from the file")
    return nil
  end
end

function M.OpenPDFAndURL()
  local info = M.ExtractAndPrintFileInfo()
  if info then
    api.OpenSkimToReadingState(info[2], info[1])
    api.OpenUntilReady(info[4], info[3])
  end
end

--- Parses the file content and returns all paths from lines
--- Only keeps the content matching 'xxx.pdf'
---@param file_path string {xxx(num),path:xxx,page:xxx,tag:xxx}
---@return table
function M.get_all_pdfs(file_path)
  local file = io.open(file_path, "r")
  if not file then
    -- print("Error: Unable to open file " .. file_path)
    return {}
  end

  local paths_table = {}
  for line in file:lines() do
    if line:match("page:") then
      local path = line:match("path: ([^,]+)")
      local page = line:match("page: (%d+)")
      local num = line:match("{(%d+),")
      local tag = line:match("tag:(%d+)}")
      if path and num then
        -- Extract the part matching 'xxx.pdf'
        local extracted_path = path:match(".+/([^/]+%.pdf)")
        if extracted_path then
          table.insert(
            paths_table,
            { type = "pdf", col = num, title = extracted_path, pos = page, path = path, tag = tag }
          )
        end
      end
    end
  end

  file:close()
  return paths
end

--- Transfer single pdf line to a table element
--- @param line string|nil {xxx(num),path:xxx,page:xxx}
--- @return table
function M.pdf_line_to_table(line)
  if not line then
    return {}
  end

  local path = line:match("path: ([^\n,]+)")
  if not path then
    return {}
  end

  path = path:gsub("^%s+", ""):gsub("%s+$", "")
  local tag = line:match("tag:(%d+)")
  local pos = line:match("pos: (%d+)")
  if path then
    local extracted_path = path:match(".+/([^/]+%.pdf)")

    if extracted_path then
      return { typs = "pdf", title = extracted_path, pos = pos, path = path, tag = tag }
    end
  end
  return { type = "pdf", title = "", page = "", path = "", tag = "" }
end

--- Parses the file content and returns all titles from lines containing 'title'
---@param file_path string {xxx(num),title:xxx,url:xxx,scrollY:xxx}
---@return table
function M.get_all_titles(file_path)
  local file = io.open(file_path, "r")
  if not file then
    -- print("Error: Unable to open file " .. file_path)
    return {}
  end

  local titles = {}
  for line in file:lines() do
    local tag = line:match("tag:(%d+),")
    local title = line:match("title:([^,]+)")
    local url = line:match("url:([^\n,]+)}")
    local scrollY = line:match("scrollY:(%d+)")
    local num = line:match("{(%d+),")
    if title then
      table.insert(titles, { type = "url", pos = num, title = title, scroll = scrollY, url = url, tag = tag })
    end
  end

  file:close()
  return titles
end

--- Transfer single url line to a table element
--- @param urls string {xxx(num),title:xxx,url:xxx,scrollY:xxx}
--- @return table
function M.url_line_to_table(urls)
  if not urls then
    return {}
  end
  local tag = urls:match("tag:(%d+),")
  local title = urls:match("title:([^,]+)")
  local url = urls:match("url:([^\n,]+)")
  local scrollY = urls:match("scrollY:(%d+)")
  local num = urls:match("{(%d+),")
  if title then
    return { type = "url", num = num, title = title, pos = scrollY, url = url, tag = tag }
  end
  return { type = "url", num = "", title = "", pos = "", url = "", tag = "" }
end

return M
