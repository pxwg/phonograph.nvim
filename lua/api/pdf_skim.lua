local M = {}
local tags = require("utils.tags")

--- Get the reading state of the current tab in Skim
--- @return string|nil
function M.ReturnSkimReadingState()
  local script = string.format(
    [[
        tell application "Skim"
            set currentDocument to front document
            set documentPath to path of currentDocument
            set currentPage to get index of current page of currentDocument
            return "pos: " & currentPage & ", path: " & documentPath & ", tag:" & "%s"
        end tell
    ]],
    tags.generateTimestampTag()
  )
  local result = vim.fn.system({ "osascript", "-e", script })

  if result then
    result = result:gsub("%s+$", "")
    print(result)
    return result
  else
    print("Failed to record reading state.")
    return nil
  end
end

--- Open the document in Skim to the specified page
--- @param page number
--- @param path string
function M.OpenSkimToReadingState(page, path)
  local script = string.format(
    [[
        tell application "Skim"
            open POSIX file "%s"
            tell front document
                go to page %s
            end tell
        end tell
    ]],
    path,
    page
  )
  local result = vim.fn.system({ "osascript", "-e", script })

  if result then
    print("Opened document to specified page.")
  else
    print("Failed to open document.")
  end
end

return M
