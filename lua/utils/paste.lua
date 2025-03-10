--- TODO: while dragging pdf or url into the buffer, update bookmark
local bm = require("utils.bookmark")
local prev_pdf = require("preview.pdf")
local tg = require("utils.tags")
local M = {}

local original_paste = vim.paste

vim.paste = function(lines, phase)
  if phase == -1 then
    local file_path = lines[1]
    if file_path:match("%.pdf$") then
      local file_name = vim.fn.fnamemodify(file_path, ":t")
      local tag = tg.generateTimestampTag()

      bm.insert_note_at_cursor({ file_name, tag, file_path }, "pdf")
      vim.schedule(function()
        prev_pdf.GetFigPath(file_path, 1, tag)
      end)
      return true
    end
  end
  return original_paste(lines, phase)
end

return M
