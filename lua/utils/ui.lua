-- a note script for editing notes when using chorme
-- keymappings
local map = vim.keymap.set

-- record current url and pdf on first and second line to the specified file
local function InsertLinesAtTop(lines_to_insert)
  -- 获取当前缓冲区的文件路径
  local buf = vim.api.nvim_get_current_buf()
  local file_path = vim.api.nvim_buf_get_name(buf)
  file_path = file_path:gsub("^%s+", ""):gsub("%s+$", "")
  -- 构建新文件的路径
  local new_file_path = vim.fn.expand("$HOME") .. "/.local/state/nvim/note/" .. file_path:gsub("/", "_") .. ".txt"
  print(new_file_path)

  -- 确保目录存在
  vim.fn.mkdir(vim.fn.fnamemodify(new_file_path, ":h"), "p")

  -- 新建文件进行写入（覆盖插入）
  local file = io.open(new_file_path, "w")
  if file then
    -- 逐行写入lines_to_insert
    for _, line in ipairs(lines_to_insert) do
      file:write(line .. "\n")
    end
    file:close()
  else
    print("Error: Unable to create file " .. new_file_path)
  end
end

function InsertPDFurl()
  local url = ReturnChormeReadingState()
  local pdf = ReturnSkimReadingState()
  InsertLinesAtTop({ pdf, url })
end

-- open the document in Skim and Chorme to the specified page
local function ExtractAndPrintFileInfo()
  -- 获取当前缓冲区的文件路径
  local buf = vim.api.nvim_get_current_buf()
  local file_path = vim.api.nvim_buf_get_name(buf)

  -- 构建要查找的文件路径
  local new_file_path = vim.fn.expand("$HOME") .. "/.local/state/nvim/note/" .. file_path:gsub("/", "_") .. ".txt"

  -- 检查文件是否存在
  if vim.fn.filereadable(new_file_path) == 0 then
    print("Error: File does not exist " .. new_file_path)
    return
  end

  -- 读取文件内容
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
