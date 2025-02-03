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
  while table.type == nil do
    table = table[1]
  end
  local result = table.type
  return result
end

return M
