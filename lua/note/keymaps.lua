-- deafult workflows with keymapping
local icon = require("icons")
local mark = require("utils.bookmark")
local prev_pdf = require("preview.pdf")
local rem = require("utils.rem")
local sel = require("utils.select")
local ui = require("utils.ui")
local map = vim.keymap.set

--- adding reading states
--- workflow: read -> remember (included saving the reading state and get the figure of current path)
map("n", "<leader>nn", function()
  local tab = rem.InsertPDFurl()
  if not tab then
    print("Error: rem.InsertPDFurl() returned nil")
    return
  end
  local pdf = rem.pdf_line_to_table(tab.pdf)
  -- MARK : 2024-2025“雅望南归”寒假回访计划（V0111).pdf, P: 3, Nerd Fonts - Iconic font aggregator
  local url = rem.url_line_to_table(tab.url)
  print(tab.url)
  print(url.title)
  -- for i = 1, #tab do
  --   if not tab[i] then
  --     print("Error: tab[" .. i .. "] is nil")
  --     return
  --   elseif string.match(tab[i], "%.pdf$") then
  -- pdf = rem.pdf_line_to_table(tab[i])
  --   elseif string.match(tab[i], "url:%s+") then
  -- url = rem.url_line_to_table(tab[i])
  --   end
  -- end
  mark.insert_note_at_cursor({ pdf.title, "P: " .. pdf.page, url.title })
  vim.schedule(function()
    prev_pdf.GetFigPath(pdf.path, pdf.page)
  end)
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
