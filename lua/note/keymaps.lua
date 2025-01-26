-- deafult workflows with keymapping
local pdf = require("preview.pdf")
local rem = require("utils.rem")
local sel = require("utils.select")
local ui = require("utils.ui")
local map = vim.keymap.set

--- adding reading states
--- cannot work right now!!!!!
--- workflow: read -> remember
map("n", "<leader>nn", function()
  local tab = rem.InsertPDFurl()
  local out = {}
  for i = 1, #tab do
    out = rem.line_to_table(tab[i])
  end
  pdf.GetFigPath(out[4], out[3])
end, { noremap = true, silent = true, desc = "[N]ew [n]ote" })

--- open pdf reading selection ui
--- workflow: read -> back to the point of past -> restore the reading state
map("n", "<leader>nr", function()
  local path = rem.get_file_path()
  local table1 = rem.get_all_pdfs(path)
  local table2 = rem.get_all_titles(path)
  local pos = vim.api.nvim_win_get_cursor(0)

  local indPDF = sel.GenerateIndex(table1)
  local indTitle = sel.GenerateIndex(table2)

  table1 = sel.SortTablebyDistance(indPDF, table1, pos[1])
  table2 = sel.SortTablebyDistance(indTitle, table2, pos[1])

  ui.create_selection_window(table1, table2)
end, { noremap = true, silent = true, desc = "[N]ote [R]estore" })
