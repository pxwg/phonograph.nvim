local autocmd = vim.api.nvim_create_autocmd
local data = require("utils.data")
local db_path = require("utils.path")
local delate = require("utils.delate")
local note = require("note")
local rem = require("utils.rem")
local search = require("utils.search")
local tags = require("utils.tags")

local function get_buffer_lines()
  local line_count = vim.api.nvim_buf_line_count(0)
  local lines = vim.api.nvim_buf_get_lines(0, 0, line_count, false)
  return lines
end

local function get_buffer_line_numbers()
  local line_count = vim.api.nvim_buf_line_count(0)
  local line_numbers = {}
  for i = 1, line_count do
    table.insert(line_numbers, i)
  end
  return line_numbers
end

--- FIX: Only callback while the tag exists in the file
autocmd("BufWritePost", {
  pattern = "*",
  callback = function()
    --- WARN: This function would be slow if the file is too large. Rewrite it with a better algorithm.
    local folded_tags = tags.get_folded_tags(get_buffer_line_numbers()) or {}

    data.create_tbl(db_path.get_db_path())
    local database_table = data.read_tbl(db_path.get_db_path())
    local tags_to_delete = tags.compare_tags_sql:diff2(folded_tags, database_table)
    local tags_to_update = tags.compare_tags_sql:same(folded_tags, database_table).same_1
    local tags_to_add = tags.compare_tags_sql:diff1(folded_tags, database_table)

    if tags_to_delete ~= nil then
      if #tags_to_delete > 0 then
        for i = 1, #tags_to_delete do
          data.delete_tbl_by_tag(db_path.get_db_path(), "history", tags_to_delete[i].tag)
        end
      end
    end

    if #tags_to_update > 0 then
      for i = 1, #tags_to_update do
        if tags_to_update[i].tag and tags_to_update[i].col then
          data.update_tbl_by_tag(
            db_path.get_db_path(),
            "history",
            tags_to_update[i].tag,
            { col = tags_to_update[i].col }
          )
        end
      end
    end

    if #tags_to_add > 0 then
      for i = 1, #tags_to_add do
        if tags_to_add[i].tag and tags_to_add[i].col then
          data.add_tbl(db_path.get_db_path(), "history", {
            type = tags_to_add[i].type,
            tag = tags_to_add[i].tag,
            path = tags_to_add[i].path,
            title = tags_to_add[i].title,
            col = tags_to_add[i].col,
            pos = "1",
          })
        end
      end
    end
  end,
})
