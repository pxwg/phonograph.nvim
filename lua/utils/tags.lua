local M = {}

--- Generate a timestamp tag
--- @return string timestamp tag
function M.generateTimestampTag()
  local date = os.date("*t")
  return string.format("%04d%02d%02d%02d%02d%02d", date.year, date.month, date.day, date.hour, date.min, date.sec)
end

return M
