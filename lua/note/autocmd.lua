--- autocmds: while the text was changed, check for the note tags and update the changings
--- first, we need to get the current tags, which could be realized by saving and update a global table with the current posisions
--- then, we need to check the change of the marks, then update the global table and the file on ~/.local/state/nvim/note/
local cmd = vim.api.nvim_create_autocmd
local rem = require("utils.rem")
local search = require("utils.search")

--- @param tags table
--- @return table
local function get_line_inside(tags)
  local result = {}
  for _, line_num in ipairs(tags) do
    local line_content = vim.trim(vim.fn.getline(line_num))
    table.insert(result, { col = line_num, inside = line_content })
  end
  return result
end

--- @param table1 table
--- @param table2 table
--- @return table, table
local function compare_tables(table1, table2)
  local differences = { added = {}, removed = {} }
  local similarities = {}

  for key, value in pairs(table2) do
    if table1[key] == value then
      table.insert(similarities, key)
    else
      table.insert(differences.added, key)
    end
  end

  for key, value in pairs(table1) do
    if table2[key] == nil then
      table.insert(differences.removed, key)
    end
  end

  return similarities, differences
end

cmd("BufEnter", {
  pattern = "*",
  callback = function()
    local path = rem.get_file_path()
    local table1 = rem.get_all_pdfs(path)
    local table2 = rem.get_all_titles(path)
    _G.current_tab = { pdf = table1, url = table2 }

    local prev_tags = search.find_at_line_start()
    local prev_inside = get_line_inside(prev_tags)
    _G.prev_inside = prev_inside
  end,
})

cmd({ "TextChanged" }, {
  pattern = "*",
  callback = function()
    local current_tags = search.find_at_line_start()
    local current_inside = get_line_inside(current_tags)
    -- MARK : MIT_8.513_Fall2017.pdf;141;金牌得主 在线 漫画 - Google Search

    local current_inside_in = {}
    for i = 1, #current_inside do
      local inside = current_inside[i].inside
      table.insert(current_inside_in, inside)
    end
  end,
})
