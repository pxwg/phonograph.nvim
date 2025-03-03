-- deafult workflows with keymapping
local icon = require("icons")
local mark = require("utils.bookmark")
local prev_pdf = require("preview.pdf")
local rem = require("utils.rem")
local sel = require("utils.select")
local ui = require("utils.ui")
local map = vim.keymap.set
local api = require("utils.api")
local data = require("utils.data")
local paths = require("utils.path")
local tags = require("utils.tags")

--- adding reading states
--- Mind model: reading paper -> want to take notes about paper -> want to remember the reading state and reload it while review the note -> use this keymapping
--- workflow: read -> remember (included saving the reading state and get the figure of current path)
map("n", "<leader>pp", function()
  local tab = rem.InsertPDFurl:pdf()
  if not tab then
    print("Error: rem.InsertPDFurl() returned nil")
    return
  end
  local pdf = rem.pdf_line_to_table(tab)
  -- local url = rem.url_line_to_table(tab.url)
  --- TODO: fully costumizable bookmark
  mark.insert_note_at_cursor({ pdf.title, pdf.tag, pdf.page }, "pdf")

  vim.schedule(function()
    prev_pdf.GetFigPath(pdf.path, pdf.page)
  end)
end, { noremap = true, silent = true, desc = "[P]hono [P]df" })

--- adding reading states
--- Mind model: reading paper -> want to take notes about paper -> want to remember the reading state and reload it while review the note -> use this keymapping
--- workflow: read -> remember (included saving the reading state and get the figure of current path)
map("n", "<leader>pu", function()
  local tab = rem.InsertPDFurl:url()
  if not tab then
    print("Error: rem.InsertPDFurl() returned nil")
    return
  end
  -- local pdf = rem.pdf_line_to_table(tab)
  local url = rem.url_line_to_table(tab)
  --- TODO: fully costumizable bookmark
  mark.insert_note_at_cursor({ url.title, url.tag, url.url }, "url")
end, { noremap = true, silent = true, desc = "[P]hono [U]rl" })


--- open pdf under cursor
--- workflow: read -> want to back to the point of past -> restore the reading state
map("n", "<leader>po", function()
  local current_line = vim.api.nvim_win_get_cursor(0)[1]
  local tag = tags.get_tag_on_line(current_line)
  local path = rem.get_file_path()
  local line = tags.search_from_tag(tag, path)
  if not line then
    vim.notify("note.nvim: No history found", vim.log.levels.ERROR)
    return
  end
  if line.type == "pdf" then
    vim.notify("note.nvim: PDF open!", vim.log.levels.INFO)
    local pdf = rem.pdf_line_to_table(line.line)
    api.OpenSkimToReadingState(pdf.page, pdf.path)
  elseif line.type == "url" then
    vim.notify("note.nvim: URL open!", vim.log.levels.INFO)
    local url = rem.url_line_to_table(line.line)
    api.OpenUntilReady(url.url, url.ScrollY)
  end
end, { noremap = true, silent = true, desc = "[P]hono [O]pen" })

--- open pdf reading selection ui
--- workflow: read -> back to the point of past -> restore the reading state
map("n", "<leader>pr", function()
  local path = rem.get_file_path()
  local db_path = paths.get_db_path()

  -- local table1 = rem.get_all_pdfs(path)
  -- local table2 = rem.get_all_titles(path)

  local table1 = data.read_tbl_with_selection(db_path, { where = { type = "pdf" } })
  local table2 = data.read_tbl_with_selection(db_path, { where = { type = "url" } })

  local pos = vim.api.nvim_win_get_cursor(0)

  local indPDF = sel.GenerateIndex(table1)
  local indTitle = sel.GenerateIndex(table2)

  table1 = sel.SortTablebyDistance(indPDF, table1, pos[1])
  table2 = sel.SortTablebyDistance(indTitle, table2, pos[1])

  ui.create_selection_window(table1, table2)
end, { noremap = true, silent = true, desc = "[P]hono [R]estore" })
