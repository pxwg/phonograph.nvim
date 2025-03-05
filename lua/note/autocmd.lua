local autocmd = vim.api.nvim_create_autocmd
local data = require("utils.data")
local db_path = require("utils.path")
local delate = require("utils.delate")
local note = require("note")
local rem = require("utils.rem")
local search = require("utils.search")
local tags = require("utils.tags")

local function get_index_pos(table)
  return output
end

--- FIX: Only sqlite supperted in this branch
--- FIX: Only callback while the tag exists in the file
autocmd("BufWritePost", {
  pattern = "*.md",
  callback = function()
    local tag_file = tags.get_folded_tags(tags.get_folded_lines()) or {}

    data.create_tbl(db_path.get_db_path())
    local bd_tbl = data.read_tbl(db_path.get_db_path())
    local diff_db = tags.compare_tags_sql:diff2(tag_file, bd_tbl)
    local same_db = tags.compare_tags_sql:same(tag_file, bd_tbl).same_1

    if diff_db ~= nil then
      if #diff_db > 0 then
        for i = 1, #diff_db do
          data.delete_tbl_by_tag(db_path.get_db_path(), "history", diff_db[i].tag)
        end
      end
    end

    -- print("same_db:" .. vim.inspect(same_db))
    if #same_db > 0 then
      for i = 1, #same_db do
        if same_db[i].tag and same_db[i].col then
          data.update_tbl_by_tag(db_path.get_db_path(), "history", same_db[i].tag, { col = same_db[i].col })
        end
      end
    end
  end,
})
