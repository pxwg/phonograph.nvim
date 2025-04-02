local sqlite = require("sqlite.db") --- for constructing sql databases
local tbl = require("sqlite.tbl") --- for constructing sql tables
local julianday, strftime = sqlite.lib.julianday, sqlite.lib.strftime

local M = {}

---@return string

-- Define a new table for storing the data
-- the data is the reading history of the user, included
---@class CustomEntryTable: sqlite_tbl
---@field path string the path of original object (e.g. pdf path/website url)
---@field pos string the reading position in original object while adding the entry into db
---@field title string the title of original object
---@field col number the reading position in note while adding the entry into db
---@field type string the type of original object (e.g. "pdf", "url")
---@field tag number the unique tag of the entry

---@class CustomEntryTable
local custom_entries = tbl("custom_entries", {
  id = true, -- primary key
  path = { "text", required = true },
  pos = "text",
  title = "text",
  col = "integer",
  type = "text",
  tag = { "integer", required = true },
})

-- sqlite.lua db object will be injected to every table at evaluation.
-- Though no connection will be open until the first sqlite operation.
local BM = sqlite({
  uri = "/Users/pxwg-dogggie/.local/state/nvim/note/_Users_pxwg-dogggie_phonographnvim_lua_utils_apilua.sqlite",
  entries = custom_entries,
  opts = {},
})

-- Add the new table to the database
BM.custom_entries = custom_entries

--- Function to add a new entry
---@param entry {path: string, pos: string, title: string, roll: number, type: string, tag: string}
function custom_entries:add(entry)
  custom_entries:insert(entry)
end

--- Function to get entries by tag
---@param tag number
function custom_entries:get_by_tag(tag)
  return custom_entries:where({ tag = tag })
end

-- Function to update an entry by tag
---@param tag number
---@param updates table tables you want to update
---@example custom_entries:update_by_tag(1, {col = 2})
function custom_entries:update_by_tag(tag, updates)
  custom_entries:update({
    where = { tag = tag },
    set = updates,
  })
end

--- Function to delete an entry by tag
--- @param tag number
--- @return boolean
function custom_entries:delete_by_tag(tag)
  return custom_entries:remove({ { tag = tag } })
end

return M
