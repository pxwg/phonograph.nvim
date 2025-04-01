local M = {}
local tags = require("utils.tags")
-- local udb = require("utils.db")

local function is_website(url, pattern)
  return url:match("^https?://" .. pattern) ~= nil
end

-- Helper function to get current URL from Chrome
local function get_current_url()
  local script_init = string.format([[
      tell application "Google Chrome"
          set currentTab to active tab of front window
          set tabURL to URL of currentTab
          execute currentTab javascript "(window.location.href)"
      end tell
  ]])
  return vim.fn.system({ "osascript", "-e", script_init })
end

-- YouTube handler
local function handle_youtube()
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
  local result = vim.fn.system({ "osascript", "-e", script_youtube })
  return result
end

-- Bilibili handler
local function handle_bilibili()
  local script_bilibili = string.format(
    [[
  tell application "Google Chrome"
      set currentTab to active tab of front window
      set tabURL to URL of currentTab
      set tabTitle to title of currentTab
      execute currentTab javascript "
          (function() {
              // Try different selectors for Bilibili video player
              const player = document.querySelector('video.bilibili-player-video') || 
                             document.querySelector('.bpx-player-video-wrap video') ||
                             document.querySelector('video');
              
              const currentTime = player ? Math.floor(player.currentTime) : 0;
              const urlString = window.location.href;
              const baseUrl = urlString.split('?')[0];
              const url = new URL(baseUrl);
              url.searchParams.set('t', currentTime + 's');
              return {url: url.toString(), title: document.title, scrollY: window.scrollY, tag: '%s'};
          })()
      "
  end tell
  ]],
    tags.generateTimestampTag()
  )
  local result = vim.fn.system({ "osascript", "-e", script_bilibili })
  return result
end

-- Generic website handler
local function handle_generic_website()
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
  return result
end

-- Process result from any handler
local function process_result(result, site_name)
  if result then
    result = result:gsub("%s+$", "")
    print(result)
    return result
  else
    vim.notify("phonograph.nvim: Failed to record reading state for " .. site_name .. ".", vim.log.levels.ERROR)
    return ""
  end
end

-- Main function
function M.ReturnChormeReadingState()
  local current_url = get_current_url()

  -- Determine website type and handle accordingly
  local result
  if is_website(current_url, "www.youtube.com") then
    result = handle_youtube()
    return process_result(result, "YouTube")
  elseif is_website(current_url, "www.bilibili.com") then
    result = handle_bilibili()
    return process_result(result, "Bilibili")
  else
    result = handle_generic_website()
    return process_result(result, "website")
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
