local db = require("sqlite.db")
local tbl = require("sqlite.tbl")

local M = {}

--- Connection to the database
local function connect_to_db(path)
  return db({
    uri = path,
    opts = {},
  })
end

-- Define a new table for storing the data
-- the data is the reading history of the user, included
---@class HistoryEntryTable: sqlite_tbl
---@field path string|nil the path of original object (e.g. pdf path/website url)
---@field pos string the reading position in original object while adding the entry into db
---@field title string the title of original object
---@field col number the reading position in note while adding the entry into db
---@field type string the type of original object (e.g. "pdf", "url")
---@field tag number the unique tag of the entry

local history = {
  id = true, -- primary key
  path = { "text", required = true },
  pos = "integer",
  title = "text",
  col = "integer",
  type = "text",
  tag = { "integer", required = true },
  ensure = true, -- create table if it doesn't already exists (THIS IS DEFUAULT)
}

--- Create a table in the database
--- @param path string the path to the database
function M.create_tbl(path)
  local BM = connect_to_db(path)
  BM:with_open(path, function()
    BM:create("history", history)
  end)
end

--- Read a table in the database
--- @param path string the path to the database
--- @return table|nil
function M.read_tbl(path)
  local BM = connect_to_db(path)
  local result = nil
  BM:with_open(path, function()
    result = BM:select("history")
  end)
  return result
end

--- Read a table in the database with selection
--- @param path string the path to the database
--- @param selection table the selection you want to read {where = {xxx= xxx}}
--- @return table|nil
function M.read_tbl_with_selection(path, selection)
  local BM = connect_to_db(path)
  local result = nil
  BM:with_open(path, function()
    result = BM:select("history", selection)
  end)
  return result
end

--- Add a table to the database
--- @param path string the path to the database
--- @param tbl_name string the name of the table
--- @param tbl_insert HistoryEntryTable the table you want to add
function M.add_tbl(path, tbl_name, tbl_insert)
  local BM = connect_to_db(path)
  BM:with_open(path, function()
    BM:insert(tbl_name, tbl_insert)
  end)
end

--- Modify a table in the database
---@param path string the path to the database
---@param tbl_name string the name of the table
---@param tag number the tag of the table you want to update
---@param updates table tables you want to update
---@example custom_entries:update_by_tag(1, {col = 2})
function M.update_tbl_by_tag(path, tbl_name, tag, updates)
  local BM = connect_to_db(path)
  BM:with_open(path, function()
    BM:update(tbl_name, { { where = { tag = tag }, set = updates } })
  end)
end

--- Read a table with tag in the database
---@param path string the path to the database
---@param tbl_name string the name of the table
---@param tag number
---@return table
function M.search_tbl_by_tag(path, tbl_name, tag)
  local BM = connect_to_db(path)
  BM:with_open(path, function()
    BM:select(tbl_name, { where = { tag = tag } })
  end)
end

--- Delete a table with tag in the database
---@param path string the path to the database
---@param tbl_name string the name of the table
---@param tag number
---@return boolean
function M.delete_tbl_by_tag(path, tbl_name, tag)
  local BM = connect_to_db(path)
  BM:with_open(path, function()
    BM:delete(tbl_name, { where = { tag = tag } })
  end)
end

-- M.update_tbl_by_tag(
--   "/Users/pxwg-dogggie/.local/state/nvim/note/_Users_pxwg-dogggie_Downloads_testmd.sqlite",
--   "history",
--   250922106,
--   { col = 2 }
-- )

return M
