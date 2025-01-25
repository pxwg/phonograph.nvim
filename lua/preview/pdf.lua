local M = {}

local image = require("image")

function M.GetFigPath(path, page)
  local extracted_path = vim.fn.fnamemodify(path, ":t:r")
  local fig_path =
    string.format(vim.fn.expand("$HOME") .. "/.local/state/nvim/note/fig/%s_page_%d", extracted_path, page)
  local output_pattern = fig_path .. "-%d.png"
  vim.fn.system(string.format("pdftoppm -f %d -l %d -png -singlefile %s %s", page, page, path, fig_path))
  local abs_fig_path = vim.fn.system(string.format("realpath %s.png", fig_path))
  return vim.fn.trim(abs_fig_path)
end

function M.PreviewPDFwithPage(fig_path, windows, ind)
  ind = tostring(ind)
  image
    .from_file(fig_path, {
      id = ind, -- optional, defaults to a random string
      with_virtual_padding = false, -- optional, pads vertically with extmarks, defaults to false
      window = windows,
      -- optional, binds image to an extmark which it follows. Forced to be true when
      -- `with_virtual_padding` is true. defaults to false.
      inline = false,

      -- geometry (optional)
      x = 1,
      y = 1,
      width = 10,
      height = 10,
    })
    :render()
end

function M.ClearPDFwithPage(fig_path, windows, ind)
  ind = tostring(ind)
  image
    .from_file(fig_path, {
      id = ind, -- optional, defaults to a random string
      with_virtual_padding = false, -- optional, pads vertically with extmarks, defaults to false
      window = windows,

      -- optional, binds image to an extmark which it follows. Forced to be true when
      -- `with_virtual_padding` is true. defaults to false.
      inline = false,

      -- geometry (optional)
      x = 1,
      y = 1,
      width = 10,
      height = 10,
    })
    :clear()
end

-- --- test example
--
-- local path = vim.fn.expand("~/Desktop/physics/B场论/0507118.pdf")
-- local page = 3
-- local fig_path = M.GetFigPath(path, page)
--
-- -- M.PreviewPDFwithPage(fig_path, 1000)
-- M.ClearPDFwithPage(fig_path, 1000)

return M
