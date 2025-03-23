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

-- Command definitions
vim.api.nvim_create_user_command("PhonographInsertPdf", function()
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
end, {})

vim.api.nvim_create_user_command("PhonographInsertUrl", function()
  local tab = rem.InsertPDFurl:url()
  if not tab then
    print("Error: rem.InsertPDFurl() returned nil")
    return
  end
  local url = rem.url_line_to_table(tab)
  --- TODO: fully costumizable bookmark
  mark.insert_note_at_cursor({ url.title, url.tag, url.url }, "url")
end, {})

vim.api.nvim_create_user_command("PhonographOpen", function()
  local current_line = vim.api.nvim_win_get_cursor(0)[1]
  local db_path = paths.get_db_path()
  local line = data.read_tbl_with_selection(db_path, { where = { col = current_line } })[1]

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
end, {})

vim.api.nvim_create_user_command("PhonographMouseOpen", function()
  local mouse_pos = vim.fn.getmousepos()

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
end, {})

vim.api.nvim_create_user_command("PhonographEdit", function()
  local current_line = vim.api.nvim_win_get_cursor(0)[1]
  local db_path = paths.get_db_path()
  --- NOTE: we can use this way to find wheather a folded line is a bookmark or not
  local line = data.read_tbl_with_selection(db_path, { where = { col = current_line } })[1]

  if not line then
    vim.notify("phonograph.nvim: No history in this line", vim.log.levels.ERROR)
    return
  end

  local tag = line.tag
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
end, {})

vim.api.nvim_create_user_command("PhonographReview", function()
  if not paths.check_db_file_exists() then
    vim.notify("phonograph.nvim: Database does not exist!", vim.log.levels.ERROR)
  else
    local db_path = paths.get_db_path()

    local table1 = data.read_tbl_with_selection(db_path, { where = { type = "pdf" } })
    local table2 = data.read_tbl_with_selection(db_path, { where = { type = "url" } })
    local pos = vim.api.nvim_win_get_cursor(0)

    local indPDF = sel.GenerateIndex(table1)
    local indTitle = sel.GenerateIndex(table2)

    table1 = sel.SortTablebyDistance(indPDF, table1, pos[1])
    table2 = sel.SortTablebyDistance(indTitle, table2, pos[1])

    ui.create_selection_window(table1, table2)
  end
end, {})
