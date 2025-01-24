local M = {}

--- Icons for the different types of notes
M.icons = {
  pdf = " ",
  url = "󰖟 ",
}

--- Get the type of the table
--- @param table table
--- @return string The icon type of table
function M.get_type(table)
  while type(table) == "table" and table[1] ~= nil do
    table = table[1]
  end
  local result = table
  return tostring(result)
end

return M
