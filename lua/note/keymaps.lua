-- TODO: add safety check for the keymapping to prevent the destruction of the database
--
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
  --- TODO: fully costumizable bookmark
  mark.insert_note_at_cursor({ pdf.title, pdf.tag, pdf.pos, pdf.path }, "pdf")

  vim.schedule(function()
    prev_pdf.GetFigPath(pdf.path, pdf.pos, pdf.tag)
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
  local url = rem.url_line_to_table(tab)
  --- TODO: fully costumizable bookmark
  mark.insert_note_at_cursor({ url.title, url.tag, url.url }, "url")
end, { noremap = true, silent = true, desc = "[P]hono [U]rl" })

--- open pdf under cursor
--- workflow: read -> want to back to the point of past -> restore the reading state
map("n", "<leader>po", function()
  local current_line = vim.api.nvim_win_get_cursor(0)[1]
  -- local tag = tags.get_tag_on_line(current_line)
  -- local path = rem.get_file_path()
  -- local line = tags.search_from_tag(tag, path)
  local db_path = paths.get_db_path()
  local line = data.read_tbl_with_selection(db_path, { where = { col = current_line } })[1]

  -- print(vim.inspect(line))

  if not line then
    vim.notify("phonograph.nvim: No history found", vim.log.levels.ERROR)
    return
  end
  if line.type == "pdf" then
    vim.notify("phonograph.nvim: PDF open!", vim.log.levels.INFO)
    api.OpenSkimToReadingState(line.pos, line.path)
  elseif line.type == "url" then
    vim.notify("phonograph.nvim: URL open!", vim.log.levels.INFO)
    api.OpenUntilReady(line.path, line.pos)
  end
end, { noremap = true, silent = true, desc = "[P]hono [O]pen" })

map("n", "<C-LeftMouse>", function()
  local mouse_pos = vim.fn.getmousepos()
  local bufnr = vim.api.nvim_get_current_buf()

  if mouse_pos.winid == 0 or mouse_pos.winid ~= vim.fn.win_getid() then
    vim.cmd("normal! <LeftMouse>")
    return
  end

  vim.api.nvim_win_set_cursor(0, { mouse_pos.line, mouse_pos.column })

  local current_line = vim.api.nvim_win_get_cursor(0)[1]
  local db_path = paths.get_db_path()
  local line = data.read_tbl_with_selection(db_path, { where = { col = current_line } })[1]

  if not line then
    return
  end
  if line.type == "pdf" then
    vim.notify("phonograph.nvim: PDF open!", vim.log.levels.INFO)
    api.OpenSkimToReadingState(line.pos, line.path)
  elseif line.type == "url" then
    vim.notify("phonograph.nvim: URL open!", vim.log.levels.INFO)
    api.OpenUntilReady(line.path, line.pos)
  end
end, { noremap = true, silent = true, desc = "[P]hono [O]pen" })

--- edit the history in database
--- NOTE: workflow: change the reading state -> edit the rading state with the keymapping.
--- TODO: change the editing method: update the tag of the existed line, and define the current preview figure of PDF, instead of updating the figure for the same tag
--- TODO: add bookmark api to match the reconstruction
map("n", "<leader>pe", function()
  local current_line = vim.api.nvim_win_get_cursor(0)[1]
  local db_path = paths.get_db_path()
  --- NOTE: we can use this way to find wheather a folded line is a bookmark or not
  local line = data.read_tbl_with_selection(db_path, { where = { col = current_line } })[1]
  local tag = line.tag

  if not line then
    vim.notify("phonograph.nvim: No history in this line", vim.log.levels.ERROR)
    return
  end
  if line.type == "pdf" then
    local tab = api.ReturnSkimReadingState()
    local pdf = rem.pdf_line_to_table(tab)
    if not pdf then
      vim.notify("phonograph.nvim: No pdf", vim.log.levels.ERROR)
      return
    end
    data.update_tbl_by_tag(db_path, "history", tag, { pos = tostring(pdf.pos) })
    vim.schedule(function()
      prev_pdf.GetFigPath(pdf.path, pdf.pos, tag)
    end)
  elseif line.type == "url" then
  end
end, { noremap = true, silent = true, desc = "[P]hono [U]pdate" })

--- open reading selection ui
--- workflow: read -> back to the point of past via chosing the reading states -> restore the reading state
map("n", "<leader>pr", function()
  if not paths.check_db_file_exists() then
    vim.notify("phonograph.nvim: Database does not exist!", vim.log.levels.ERROR)
  else
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
  end
end, { noremap = true, silent = true, desc = "[P]hono [R]estore" })
