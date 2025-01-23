-- deafult workflows with keymapping
local api = require("utils.api")
local rem = require("utils.rem")
local sel = require("utils.select")
local ui = require("utils.ui")
local map = vim.keymap.set

--- adding reading states
map("n", "<leader>nn", function()
  rem.InsertPDFurl()
end, { noremap = true, silent = true, desc = "New note" })

--- open pdf reading selection ui
map("n", "<leader>nf", function()
  local path = rem.get_file_path()
  local table1 = rem.get_all_pdfs(path)
  local table2 = rem.get_all_titles(path)
  local pos = vim.api.nvim_win_get_cursor(0)

  local indPDF = sel.GenerateIndex(table1)
  local indTitle = sel.GenerateIndex(table2)

  table1 = sel.SortTablebyDistance(indPDF, table1, pos[1])
  table2 = sel.SortTablebyDistance(indTitle, table2, pos[1])

  ui.create_selection_window(table1, table2)
end, { noremap = true, silent = true, desc = "Extract and print file info" })
