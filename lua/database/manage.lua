local sqlite = require("sqlite.db") --- for constructing sql databases
local tbl = require("sqlite.tbl") --- for constructing sql tables
local uri = require("utils.rem").get_db_path()
local julianday, strftime = sqlite.lib.julianday, sqlite.lib.strftime

-- Define a new table for storing the data
---@class CustomEntryTable: sqlite_tbl
---@field path string
---@field pos string
---@field title string
---@field col number
---@field type string
---@field tag number

---@type CustomEntryTable
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
  uri = uri,
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

--- Function to update an entry by tag
---@param tag number
---@param updates table tables you want to update
function custom_entries:update_by_tag(tag, updates)
  custom_entries:update({
    where = { tag = tag },
    set = updates,
  })
end

--- Function to update an entry by tag
---@param tag number
---@param updates table
function custom_entries:update_entry_by_tag(tag, updates)
  custom_entries:update_by_tag(tag, updates)
end

--- Function to get entries by tag
---@param tag number
---@return table
function custom_entries:get_by_tag(tag)
  return custom_entries:where({ tag = tag })
end
