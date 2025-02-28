--- autocmds: while the text was changed, check for the note tags and update the changings
--- first, we need to get the current tags, which could be realized by saving and update a global table with the current posisions
--- then, we need to check the change of the marks, then update the global table and the file on ~/.local/state/nvim/note/
local cmd = vim.api.nvim_create_autocmd
local rem = require("utils.rem")
local search = require("utils.search")

--- TODO: What I need the code to do is: use a regular expression to match {{{type, then find the corresponding tag information, and finally redefine the cursor position in the database by looking up the tag information in the database and the tag information here. This ensures the robustness of the tag system under text restructuring.

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

  local table1_set = {}
  for _, value in ipairs(table1) do
    table1_set[value] = true
  end

  for _, value in ipairs(table2) do
    if table1_set[value] then
      table.insert(similarities, value)
      table1_set[value] = nil
    else
      table.insert(differences.added, value)
    end
  end

  for value, _ in pairs(table1_set) do
    table.insert(differences.removed, value)
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
  pattern = "*.tex",
  callback = function()
    local current_tags = search.find_at_line_start()
    local current_inside = get_line_inside(current_tags)

    local current_inside_in = {}
    for i = 1, #current_inside do
      local inside = current_inside[i].inside
      table.insert(current_inside_in, inside)
    end

    print("Previous Inside: ", vim.inspect(_G.prev_inside.insider))
    print("Current Inside: ", vim.inspect(current_inside_in))

    local similarities, differences = compare_tables(_G.prev_inside, current_inside_in)
    _G.perv_inside = current_inside_in
  end,
})
