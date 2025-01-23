-- ui module for show the history of urls and pdfs
local M = {}

local Popup = require("nui.popup")
local event = require("nui.utils.autocmd").event
local api = require("utils.api")
local keymap = require("nui.utils.keymap")

--- Create a selection window with two sub-windows
--- @param table1 table The first table to display
--- @param table2 table The second table to display
function M.create_selection_window(table1, table2)
  local current_table = table1
  local other_table = table2

  local function create_popup(content)
    local popup = Popup({
      enter = true,
      focusable = true,
      border = {
        style = "rounded",
        text = {
          top = "Selection Window",
          top_align = "center",
        },
      },
      position = "50%",
      size = {
        width = "60%",
        height = "60%",
      },
      buf_options = {
        modifiable = true,
        readonly = false,
      },
      win_options = {
        winblend = 10,
        winhighlight = "Normal:Normal,FloatBorder:FloatBorder",
      },
    })

    popup:mount()
    vim.api.nvim_buf_set_lines(popup.bufnr, 0, -1, false, content)
    return popup
  end

  local function update_popup(popup, content)
    if popup and popup.bufnr then
      vim.api.nvim_buf_set_lines(popup.bufnr, 0, -1, false, content)
    end
  end

  local function format_table(tbl)
    local formatted = {}
    for _, item in ipairs(tbl) do
      table.insert(formatted, item[3])
    end
    return formatted
  end

  local popup = create_popup(format_table(current_table))

  if popup then
    popup:on(event.BufLeave, function()
      popup:unmount()
    end)

    keymap.set(popup.bufnr, "n", "<C-]>", function()
      current_table, other_table = other_table, current_table
      update_popup(popup, format_table(current_table))
    end, { noremap = true, silent = true })

    keymap.set(popup.bufnr, "n", "<C-[>", function()
      current_table, other_table = other_table, current_table
      update_popup(popup, format_table(current_table))
    end, { noremap = true, silent = true })

    keymap.set(popup.bufnr, "n", "q", function()
      popup:unmount()
    end, { noremap = true, silent = true })

    keymap.set(popup.bufnr, "n", "<CR>", function()
      local line = vim.api.nvim_get_current_line()
      print("Selected: " .. line)
      popup:unmount()
    end, { noremap = true, silent = true })
  else
    print("Error: Failed to create popup window")
  end
end

---- Example usage ------
local rem = require("utils.rem")
local sel = require("utils.select")
local path = vim.fn.expand("~/.local/state/nvim/note/_Users_pxwg-dogggie_.config_nvim_test.tex.txt")
local table1 = rem.get_all_pdfs(path)
local table2 = rem.get_all_titles(path)

M.create_selection_window(table1, table2)

return M
