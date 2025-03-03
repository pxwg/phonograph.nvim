--- autocmds: while the text was changed, check for the note tags and update the changings
--- first, we need to get the current tags, which could be realized by saving and update a global table with the current posisions
--- then, we need to check the change of the marks, then update the global table and the file on ~/.local/state/nvim/note/
local cmd = vim.api.nvim_create_autocmd
local data = require("utils.data")
local db_path = require("utils.path")
local delate = require("utils.delate")
local note = require("note")
local rem = require("utils.rem")
local search = require("utils.search")
local tags = require("utils.tags")

-- --- @param tags table
-- --- @return table
-- local function get_line_inside(tags)
--   local result = {}
--   for _, line_num in ipairs(tags) do
--     local line_content = vim.trim(vim.fn.getline(line_num))
--     table.insert(result, { col = line_num, inside = line_content })
--   end
--   return result
-- end
--
-- --- @param table1 table
-- --- @param table2 table
-- --- @return table, table
-- local function compare_tables(table1, table2)
--   local differences = { added = {}, removed = {} }
--   local similarities = {}
--
--   local table1_set = {}
--   for _, value in ipairs(table1) do
--     table1_set[value] = true
--   end
--
--   for _, value in ipairs(table2) do
--     if table1_set[value] then
--       table.insert(similarities, value)
--       table1_set[value] = nil
--     else
--       table.insert(differences.added, value)
--     end
--end
--
--   for value, _ in pairs(table1_set) do
--     table.insert(differences.removed, value)
--   end
--
--   return similarities, differences
-- end
--
-- cmd("BufEnter", {
--   pattern = "*",
--   callback = function()
--     local path = rem.get_file_path()
--     local table1 = rem.get_all_pdfs(path)
--     local table2 = rem.get_all_titles(path)
--     _G.current_tab = { pdf = table1, url = table2 }
--
--     local prev_tags = search.find_at_line_start()
--     local prev_inside = get_line_inside(prev_tags)
--     _G.prev_inside = prev_inside
--   end,
-- })
--
-- cmd({ "TextChanged" }, {
--   pattern = "*.tex",
--   callback = function()
--     local current_tags = search.find_at_line_start()
--     local current_inside = get_line_inside(current_tags)
--
--     local current_inside_in = {}
--     for i = 1, #current_inside do
--       local inside = current_inside[i].inside
--       table.insert(current_inside_in, inside)
--     end
--
--     print("Previous Inside: ", vim.inspect(_G.prev_inside.insider))
--     print("Current Inside: ", vim.inspect(current_inside_in))
--
--     local similarities, differences = compare_tables(_G.prev_inside, current_inside_in)
--     _G.perv_inside = current_inside_in
--   end,
-- })

local function get_index_pos(table)
  return output
end

cmd("BufWritePre", {
  pattern = "*.md",
  callback = function()
    local path = rem.get_file_path()

    local tag_file = tags.get_folded_tags(tags.get_folded_lines())
    print("tag_file:" .. vim.inspect(tag_file))
    local pdf_base = rem.get_all_pdfs(path)
    local url_base = rem.get_all_titles(path)
    local tag_base = {}
    for _, tag in ipairs(pdf_base) do
      table.insert(tag_base, tag)
    end
    for _, tag in ipairs(url_base) do
      table.insert(tag_base, tag)
    end

    local bd_tbl = data.read_tbl(db_path.get_db_path())

    local diff_db = tags.compare_tags_sql:diff2(tag_file, bd_tbl)

    print("diff_db:" .. vim.inspect(diff_db))

    if diff_db ~= nil then
      if #diff_db > 0 then
        for i = 1, #diff_db do
          data.delete_tbl_by_tag(db_path.get_db_path(), "history", diff_db[i].tag)
        end
      end
    end

    local same_db = tags.compare_tags_sql:same(tag_file, bd_tbl).same_1

    print("same_db:" .. vim.inspect(same_db))
    if #same_db > 0 then
      for i = 1, #same_db do
        if same_db[i].tag and same_db[i].col then
          data.update_tbl_by_tag(db_path.get_db_path(), "history", same_db[i].tag, { col = same_db[i].col })
        end
      end
    end

    local diff = tags.compare_tags(tag_file, tag_base)

    local diff_pos = {}
    if diff ~= nil then
      for i = 1, #diff do
        table.insert(diff_pos, diff[i].num)
      end

      print("pos in data:" .. vim.inspect(diff_pos))

      if #diff_pos > 0 then
        delate.delete_lines_in_file(path, diff_pos)
      end
    end
  end,
})
