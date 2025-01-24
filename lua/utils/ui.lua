-- ui module for show the history of urls and pdfs
local M = {}
local api = require("utils.api")

local Layout = require("nui.layout")
local Popup = require("nui.popup")
local event = require("nui.utils.autocmd").event
local keymap = vim.keymap

local icons = {
  pdf = " ",
  url = "󰖟 ",
}

--- Get the type of the table
--- @param table table
--- @return string The type of the table
local function get_type(table)
  while type(table) == "table" and table[1] ~= nil do
    table = table[1]
  end
  local result = table
  return tostring(result)
end

--- Get the icon for the table
--- @param table table The table containing the data
--- @return string The icon for the table
local function icon_with_type(table)
  if table then
    if get_type(table) == "pdf" then
      return icons.pdf
    elseif get_type(table) == "url" then
      return icons.url
    else
      return "󰟢"
    end
  else
    return "󰟢"
  end
end

--- Update the detail popup with the selected row's content
---@param current_table table The current table containing the data
---@param detail_popup table The detail popup window
---@param row number The selected row index
local function update_detail_popup(current_table, detail_popup, row)
  local item = current_table[row]
  if item then
    local content = {}
    for k, v in pairs(item) do
      table.insert(content, k .. ": " .. v)
    end
    vim.schedule(function()
      vim.api.nvim_buf_set_lines(detail_popup.bufnr, 0, -1, false, content)
    end)
  end
end

--- Update the main popup with the current table's content
---@param current_table table The current table containing the data
---@param main_popup table The main popup window
local function update_main_popup(current_table, main_popup)
  local content = {}
  for _, item in ipairs(current_table) do
    table.insert(content, icon_with_type(current_table) .. item[3])
  end
  vim.schedule(function()
    vim.api.nvim_buf_set_lines(main_popup.bufnr, 0, -1, false, content)
    local icon = icon_with_type(current_table)
    local width = vim.fn.strlen(icon)
    vim.api.nvim_win_set_cursor(main_popup.winid, { 1, width }) -- Set cursor position to the first row and second column
  end)
end

--- Set key mappings for the main popup
---@param main_popup table The main popup window
---@param layout table The layout containing the popups
---@param current_table table The current table containing the data
---@param other_table table The other table to switch to
---@param update_main_popup function The function to update the main popup
local function set_keymaps(main_popup, layout, current_table, other_table, update_main_popup)
  keymap.set("n", "l", function()
    current_table, other_table = other_table, current_table
    update_main_popup(current_table, main_popup, icons)
    vim.schedule(function()
      vim.api.nvim_set_current_win(main_popup.winid)
    end)
  end, { noremap = true, silent = true, buffer = main_popup.bufnr })

  keymap.set("n", "h", function()
    current_table, other_table = other_table, current_table
    update_main_popup(current_table, main_popup, icons)
    vim.schedule(function()
      vim.api.nvim_set_current_win(main_popup.winid)
    end)
  end, { noremap = true, silent = true, buffer = main_popup.bufnr })

  keymap.set("n", "j", "j", { noremap = true, silent = true, buffer = main_popup.bufnr })

  keymap.set("n", "k", "k", { noremap = true, silent = true, buffer = main_popup.bufnr })

  keymap.set("n", "q", function()
    layout:unmount()
  end, { noremap = true, silent = true, buffer = main_popup.bufnr })

  keymap.set("n", "<CR>", function()
    local row = vim.api.nvim_win_get_cursor(0)[1]
    if get_type(current_table) == "pdf" then
      api.OpenSkimToReadingState(current_table[row][4], current_table[row][5])
    else
      api.OpenUntilReady(current_table[row][5], current_table[row][4])
    end
    layout:unmount()
  end, { noremap = true, silent = true })
end

--- Attach events to the main popup
---@param main_popup table The main popup window
---@param layout table The layout containing the popups
---@param current_table table The current table containing the data
---@param detail_popup table The detail popup window
local function attach_events(main_popup, layout, current_table, detail_popup)
  vim.api.nvim_buf_attach(main_popup.bufnr, false, {
    on_lines = function()
      local row = vim.api.nvim_win_get_cursor(0)[1]
      update_detail_popup(current_table, detail_popup, row)
      vim.schedule(function()
        vim.api.nvim_set_current_win(main_popup.winid)
      end)
    end,
    on_detach = function()
      layout:unmount()
    end,
  })

  vim.api.nvim_create_autocmd("CursorMoved", {
    buffer = main_popup.bufnr,
    callback = function()
      local row = vim.api.nvim_win_get_cursor(main_popup.winid)[1]
      update_detail_popup(current_table, detail_popup, row)
    end,
  })
end

--- Create the selection window with the given tables
---@param table1 table The first table containing the data
---@param table2 table The second table containing the data
function M.create_selection_window(table1, table2)
  local current_table = table1
  local other_table = table2

  -- Create the main popup window
  local main_popup = Popup({
    enter = true,
    focusable = true,
    border = {
      style = "single",
      text = {
        top = "Selection History",
        top_align = "center",
      },
    },
    size = {
      width = "100%",
      height = "100%",
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

  -- Create the detail view popup window
  local detail_popup = Popup({
    enter = false,
    focusable = false,
    border = {
      style = "single",
      text = {
        top = "Detail View",
        top_align = "center",
      },
    },
    size = {
      width = "100%",
      height = "100%",
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

  -- Layout
  local layout = Layout(
    {
      position = "50%",
      size = {
        width = 80,
        height = "60%",
      },
    },
    Layout.Box({
      Layout.Box(main_popup, { size = "50%" }),
      Layout.Box(detail_popup, { size = "50%" }),
    }, { dir = "row" })
  )

  layout:mount()
  main_popup:mount()
  detail_popup:mount()

  -- Get and print window IDs
  local main_winid = main_popup.winid
  local detail_winid = detail_popup.winid
  print("Main window ID: " .. main_winid)
  print("Detail window ID: " .. detail_winid)

  update_main_popup(current_table, main_popup)
  set_keymaps(main_popup, layout, current_table, other_table, update_main_popup)
  attach_events(main_popup, layout, current_table, detail_popup)
end

return M
