local M = {}
local tags = require("utils.tags")
-- local udb = require("utils.db")

local function is_website(url, pattern)
  return url:match("^https?://" .. pattern) ~= nil
end

--- Get the reading state of the current tab in Chrome
--- if url == youtube, it will return the video at the proper time with it's url
--- @return string
function M.ReturnChormeReadingState()
  local script_init = string.format([[
        tell application "Google Chrome"
            set currentTab to active tab of front window
            set tabURL to URL of currentTab
            execute currentTab javascript "(window.location.href)"
        end tell
    ]])
  local result_init = vim.fn.system({ "osascript", "-e", script_init })
  -- reading state for youtube is different: video time
  if is_website(result_init, "youtube.com") then
    local script_youtube = string.format(
      [[
    tell application "Google Chrome"
        set currentTab to active tab of front window
        set tabURL to URL of currentTab
        set tabTitle to title of currentTab
        execute currentTab javascript "
            (function() {
                const player = document.querySelector('.video-stream');
                const currentTime = player ? Math.floor(player.currentTime) : 0;
                const url = new URL(window.location.href);
                url.searchParams.set('t', currentTime + 's');
                return {url: url.toString(), title: document.title, scrollY: window.scrollY, tag: '%s'};
            })()
        "
    end tell
    ]],
      tags.generateTimestampTag()
    )
    local result_youtube = vim.fn.system({ "osascript", "-e", script_youtube })
    -- print(result_youtube)
    if result_youtube then
      result_youtube = result_youtube:gsub("%s+$", "")
      print(result_youtube)
      return result_youtube
    else
      vim.notify("phonograph.nvim: Failed to record reading state.", vim.log.levels.ERROR)
      return ""
    end
  -- deal with other websites
  else
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
end

--- Go to the URL and scroll to the position when the page is loaded
--- If url == youtube, it will open the video at the proper time
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
