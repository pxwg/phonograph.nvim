-- ui module for show the history of urls and pdfs
local M = {}
local api = require("utils.api")
local note = require("note")
local pdf_preview = require("preview.pdf")

local Layout = require("nui.layout")
local Popup = require("nui.popup")
local keymap = vim.keymap

local icons = require("icons").icons
local get_type = require("icons").get_type

--- Get the icon for the table
--- @param table table The table containing the data
--- @return string The icon for the table
local function icon_with_type(table)
  local icon = icons[get_type(table)]
  if icon then
    return icon
  else
    return "󰟢"
  end
end

--- Update the current table of figures
--- @param current_table table The current table containing the data
--- @return table The updated table with the figure paths
local function update_pdf_preview(current_table)
  local fig_path_tab = {}
  for i = 1, #current_table do
    local path = current_table[i].path
    local pos = current_table[i].pos
    fig_path_tab[i] = pdf_preview.TransFigPath(path, pos)
  end
  return fig_path_tab
end

--- Update the detail popup with the current table's content
--- @param current_table table The current table containing the data
--- @param detail_popup table The detail popup window
--- @param row number The row number to show the detail for
--- @param fig_path_tab table The table containing the figure paths
local function update_detail_popup(current_table, detail_popup, row, fig_path_tab)
  local image_loaded, _ = pcall(require, "image")
  local width = vim.api.nvim_win_get_width(detail_popup.winid)
  local height = vim.api.nvim_win_get_height(detail_popup.winid)
  local size = { width = width, height = height }
  if get_type(current_table) == "pdf" and image_loaded and note.opts.integration.image then
    vim.schedule(function()
      vim.api.nvim_buf_set_lines(detail_popup.bufnr, 0, -1, false, {})
      for i = 1, #fig_path_tab do
        pdf_preview.ClearPDFwithPage(fig_path_tab[i], detail_popup.winid, i, size)
      end
      if row >= 1 and row <= #fig_path_tab then
        pdf_preview.PreviewPDFwithPage(fig_path_tab[row], detail_popup.winid, row, size)
      end
    end)
    return
  else
    vim.schedule(function()
      for i = 1, #fig_path_tab do
        pdf_preview.ClearPDFwithPage(fig_path_tab[i], detail_popup.winid, i, size)
      end
    end)
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
end

--- Update the main popup with the current table's content
---@param current_table table The current table containing the data
---@param main_popup table The main popup window
local function update_main_popup(current_table, main_popup)
  local content = {}
  for _, item in ipairs(current_table) do
    table.insert(content, icon_with_type(current_table) .. item.title)
  end
  vim.schedule(function()
    vim.api.nvim_buf_set_lines(main_popup.bufnr, 0, -1, false, content)
    local icon = icon_with_type(current_table)
    local width = vim.fn.strlen(icon)
    vim.api.nvim_win_set_cursor(main_popup.winid, { 1, width }) -- Set cursor position to the first row and second column
  end)
end

--- Attach events to the main popup
---@param main_popup table The main popup window
---@param layout table The layout containing the popups
---@param current_table table The current table containing the data
---@param detail_popup table The detail popup window
---@param fig_path_tab table The table containing the figure paths
local function attach_events(main_popup, layout, current_table, detail_popup, fig_path_tab)
  vim.api.nvim_buf_attach(main_popup.bufnr, false, {
    on_lines = function()
      local row = vim.api.nvim_win_get_cursor(0)[1]
      update_detail_popup(current_table, detail_popup, row, fig_path_tab)
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
      vim.api.nvim_buf_set_lines(detail_popup.bufnr, 0, -1, true, {})
      update_detail_popup(current_table, detail_popup, row, fig_path_tab)
    end,
  })
end

--- Set key mappings for the main popup
---@param main_popup table The main popup window
---@param detail_popup table The detail popup window
---@param layout table The layout containing the popups
---@param tables table The list of tables to switch between
---@param _update_main_popup function The function to update the main popup
---@param _attach_events function The function to attach events to the popup
local function set_keymaps(main_popup, detail_popup, layout, tables, _update_main_popup, _attach_events, fig_path_tab)
  local current_index = 1

  local function switch_table(direction)
    current_index = (current_index - 1 + direction + #tables) % #tables + 1
    _update_main_popup(tables[current_index], main_popup)
    vim.schedule(function()
      vim.api.nvim_set_current_win(main_popup.winid)
      _attach_events(main_popup, layout, tables[current_index], detail_popup, fig_path_tab)
    end)
    return current_index
  end

  keymap.set("n", "l", function()
    switch_table(1)
  end, { noremap = true, silent = true, buffer = main_popup.bufnr })

  keymap.set("n", "h", function()
    switch_table(-1)
  end, { noremap = true, silent = true, buffer = main_popup.bufnr })

  keymap.set("n", "j", function()
    vim.api.nvim_feedkeys("j", "n", false)
  end, { noremap = true, silent = true, buffer = main_popup.bufnr })

  keymap.set("n", "k", function()
    vim.api.nvim_feedkeys("k", "n", false)
  end, { noremap = true, silent = true, buffer = main_popup.bufnr })

  keymap.set("n", "q", function()
    vim.schedule(function()
      local width = vim.api.nvim_win_get_width(detail_popup.winid)
      local height = vim.api.nvim_win_get_height(detail_popup.winid)
      local size = { width = width, height = height }
      for i = 1, #fig_path_tab do
        pdf_preview.ClearPDFwithPage(fig_path_tab[i], detail_popup.winid, i, size)
      end
      layout:unmount()
    end)
  end, { noremap = true, silent = true, buffer = main_popup.bufnr })

  keymap.set("n", "<CR>", function()
    local row = vim.api.nvim_win_get_cursor(0)[1]
    if get_type(tables[current_index]) == "pdf" then
      api.OpenSkimToReadingState(tables[current_index][row].pos, tables[current_index][row].path)
    else
      api.OpenUntilReady(tables[current_index][row].path, tables[current_index][row].pos)
    end
    vim.schedule(function()
      local width = vim.api.nvim_win_get_width(detail_popup.winid)
      local height = vim.api.nvim_win_get_height(detail_popup.winid)
      local size = { width = width, height = height }
      for i = 1, #fig_path_tab do
        pdf_preview.ClearPDFwithPage(fig_path_tab[i], detail_popup.winid, i, size)
      end
      layout:unmount()
    end)
  end, { noremap = true, silent = true, buffer = main_popup.bufnr })

  keymap.set("n", "<C-y>", function()
    local row = vim.api.nvim_win_get_cursor(0)[1]
    if get_type(tables[current_index]) == "pdf" then
      api.OpenSkimToReadingState(tables[current_index][row].page, tables[current_index][row].path)
    else
      api.OpenUntilReady(tables[current_index][row].url, tables[current_index][row].scroll)
    end
    vim.schedule(function()
      local width = vim.api.nvim_win_get_width(detail_popup.winid)
      local height = vim.api.nvim_win_get_height(detail_popup.winid)
      local size = { width = width, height = height }
      for i = 1, #fig_path_tab do
        pdf_preview.ClearPDFwithPage(fig_path_tab[i], detail_popup.winid, i, size)
      end
      layout:unmount()
    end)
  end, { noremap = true, silent = true, buffer = main_popup.bufnr })
end

--- Create the selection window with the given tables
---@param ... table The tables containing the data
function M.create_selection_window(...)
  local tables = { ... }

  -- Filter out empty tables
  local non_empty_tables = {}
  for _, tbl in ipairs(tables) do
    if #tbl > 0 then
      table.insert(non_empty_tables, tbl)
    end
  end

  if #non_empty_tables == 0 then
    print("No data to show")
    return
  end

  local fig_path_tab = {}

  for i = 1, #non_empty_tables do
    if get_type(non_empty_tables[i]) == "pdf" then
      fig_path_tab = update_pdf_preview(non_empty_tables[i])
    end
  end

  -- Create the main popup window
  local main_popup = Popup(vim.tbl_deep_extend("force", {
    enter = true,
    focusable = true,
  }, note.opts.ui.selection))

  -- Create the detail view popup window

  local detail_popup = Popup(vim.tbl_deep_extend("force", {
    enter = false,
    focusable = false,
  }, note.opts.ui.preview))

  -- Layout
  local layout = Layout(
    {
      position = "50%",
      size = {
        width = "60%",
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

  -- print(detail_popup.win_config.width)
  -- print(detail_popup.win_config.height)

  update_main_popup(non_empty_tables[1], main_popup)
  attach_events(main_popup, layout, non_empty_tables[1], detail_popup, fig_path_tab)
  set_keymaps(main_popup, detail_popup, layout, non_empty_tables, update_main_popup, attach_events, fig_path_tab)
end

return M
