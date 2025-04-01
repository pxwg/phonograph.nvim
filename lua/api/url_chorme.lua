local M = {}
local tags = require("utils.tags")
-- local udb = require("utils.db")

--- Get the reading state of the current tab in Chrome
--- @return string
function M.ReturnChormeReadingState()
  local script = string.format(
    [[
        tell application "Google Chrome"
            set currentTab to active tab of front window
            set tabURL to URL of currentTab
            set tabTitle to title of currentTab
            execute currentTab javascript "({url: window.location.href, title: document.title, scrollY: window.scrollY, tag: '%s'})"
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
    return ""
  end
end

--- Go to the URL and scroll to the position when the page is loaded
--- @param url string
--- @param scrollY number
function M.OpenChormeToReadingState(url, scrollY)
  url = url:gsub("%s+", "")
  scrollY = scrollY or 0

  local uv = vim.loop
  local script = string.format(
    [[
    tell application "Google Chrome"
        open location "%s"
        delay 2
        set maxTime to 5
        set elapsedTime to 0
        repeat
            set readyState to execute front window's active tab javascript "document.readyState"
            if readyState is "complete" then
                exit repeat
            end if
            delay 1
            set elapsedTime to elapsedTime + 1
            if elapsedTime is greater than or equal to maxTime then
                exit repeat
            end if
        end repeat
        execute front window's active tab javascript "window.scrollTo(0, %s)"
    end tell
  ]],
    url,
    scrollY
  )

  local handle
  handle = uv.spawn("osascript", {
    args = { "-e", script },
    stdio = { nil, nil, nil },
  }, function()
    handle:close()
  end)
end

return M
