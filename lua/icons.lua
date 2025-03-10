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

--- @param icon_type string
--- @return string colored icon
function M.get_colored_icon(icon_type)
  if icon_type == "pdf" then
    return "%#IconPdf#" .. M.icons.pdf .. "%*"
  elseif icon_type == "url" then
    return "%#IconUrl#" .. M.icons.url .. "%*"
  else
    return ""
  end
end

return M
