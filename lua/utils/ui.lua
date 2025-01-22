-- a note script for editing notes when using chorme
-- keymappings
local map = vim.keymap.set

local function GetCursorPosition()
  local row, col = unpack(vim.api.nvim_win_get_cursor(0))
  return { row = row, col = col }
end

-- record current url and pdf on first and second line to the specified file
local function InsertLinesAtTop(lines_to_insert, pos)
  local buf = vim.api.nvim_get_current_buf()
  local file_path = vim.api.nvim_buf_get_name(buf)
  file_path = file_path:gsub("^%s+", ""):gsub("%s+$", "")
  local new_file_path = vim.fn.expand("$HOME") .. "/.local/state/nvim/note/" .. file_path:gsub("/", "_") .. ".txt"

  vim.fn.mkdir(vim.fn.fnamemodify(new_file_path, ":h"), "p")

  local file = io.open(new_file_path, "a") -- 使用 "a" 模式以追加内容而不是覆盖
  if file then
    for _, line in ipairs(lines_to_insert) do
      file:write(string.format("{%d, %d, %s}\n", pos.row, pos.col, line))
    end
    file:close()
  else
    print("Error: Unable to create file " .. new_file_path)
  end
end

function InsertPDFurl()
  local pos = GetCursorPosition()
  local url = ReturnChormeReadingState()
  local pdf = ReturnSkimReadingState()
  InsertLinesAtTop({ pdf, url }, pos)
end

-- open the document in Skim and Chorme to the specified page
local function ExtractAndPrintFileInfo()
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

  -- 提取信息
  local path = content:match("path: ([^\n,]+)"):gsub("^%s+", ""):gsub("%s+$", "")
  local page = content:match("page: (%d+)")
  local scrollY = content:match("scrollY:(%d+)")
  local url = content:match("url:([^\n,]+)")

  -- 输出表格
  if path and page and scrollY and url then
    print("path: " .. path)
    print("page: " .. page)
    return { path, page, scrollY, url }
  else
    print("Error: Unable to extract required information from the file")
    return nil
  end
end

local function OpenPDFAndURL()
  local info = ExtractAndPrintFileInfo()
  if info then
    OpenSkimToReadingState(info[2], info[1])
    OpenUntilReady(info[4], info[3])
  end
end

map("n", "<leader>nn", function()
  InsertPDFurl()
end, { noremap = true, silent = true, desc = "New note" })

map("n", "<leader>nf", function()
  OpenPDFAndURL()
end, { noremap = true, silent = true, desc = "Extract and print file info" })
