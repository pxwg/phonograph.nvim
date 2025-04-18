local M = {}
local tags = require("utils.tags")
-- local udb = require("utils.db")

-- Function to get list of Chrome windows and let user select one
--- TODO: UI for selecting Chrome windows instead of input list
local function select_chrome_window()
  local script = [[
    tell application "Google Chrome"
      set windowList to {}
      repeat with w in every window
        set windowTitle to title of w
        set windowId to id of w
        set end of windowList to windowId & ":" & windowTitle
      end repeat
      return windowList
    end tell
  ]]

  local result = vim.fn.system({ "osascript", "-e", script })
  if result == "" then
    vim.notify("No Chrome windows found", vim.log.levels.ERROR)
    return nil
  end

  local windows = {}
  -- Split by comma for multiple windows in one line
  local entries = vim.split(result:gsub("\n", ""), ",")
  for _, entry in ipairs(entries) do
    -- Extract window ID and title (ID is at start of string before first colon)
    local id, title = entry:match("^%s*(%d+):(.+)$")
    if id and title then
      table.insert(windows, { id = id, title = title })
    end
  end

  if #windows == 0 then
    vim.notify("Failed to parse Chrome windows", vim.log.levels.ERROR)
    return nil
  end

  if #windows == 1 then
    return windows[1].id
  end
  -- Display the list of windows to the user
  local choices = {}
  for i, window in ipairs(windows) do
    table.insert(choices, string.format("%d: %s", i, window.title))
  end
  local choice = vim.fn.inputlist(choices)
  if choice < 1 or choice > #windows then
    vim.notify("Invalid choice", vim.log.levels.ERROR)
    return nil
  end
  local selected_window = windows[choice].id
  return selected_window
end

local function is_website(url, pattern)
  return url:match("^https?://" .. pattern) ~= nil
end

-- Helper function to get current URL from Chrome
local function get_current_url(window_id)
  local window_id_str = window_id and ("window id " .. window_id) or "front window"
  local script_init = string.format(
    [[
      tell application "Google Chrome"
          set currentTab to active tab of %s
          set tabURL to URL of currentTab
          execute currentTab javascript "(window.location.href)"
      end tell
  ]],
    window_id_str
  )
  return vim.fn.system({ "osascript", "-e", script_init })
end

-- YouTube handler
local function handle_youtube(window_id)
  local window_id_str = window_id and ("window id " .. window_id) or "front window"
  local script_youtube = string.format(
    [[
  tell application "Google Chrome"
      set currentTab to active tab of %s
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
    window_id_str,
    tags.generateTimestampTag()
  )
  local result = vim.fn.system({ "osascript", "-e", script_youtube })
  return result
end

-- Bilibili handler
local function handle_bilibili(window_id)
  local window_id_str = window_id and ("window id " .. window_id) or "front window"
  local script_bilibili = string.format(
    [[
  tell application "Google Chrome"
      set currentTab to active tab of %s
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
    window_id_str,
    tags.generateTimestampTag()
  )
  local result = vim.fn.system({ "osascript", "-e", script_bilibili })
  return result
end

-- Generic website handler
local function handle_generic_website(window_id)
  local window_id_str = window_id and ("window id " .. window_id) or "front window"
  local script = string.format(
    [[
      tell application "Google Chrome"
          set currentTab to active tab of %s
          set tabURL to URL of currentTab
          set tabTitle to title of currentTab
          execute currentTab javascript "({url: window.location.href, title: document.title, scrollY: window.scrollY, tag: '%s'})"
      end tell
  ]],
    window_id_str,
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
  local window_id = select_chrome_window()
  if not window_id then
    vim.notify("No Chrome window selected", vim.log.levels.ERROR)
    return ""
  end

  local current_url = get_current_url(window_id)

  -- Determine website type and handle accordingly
  local result
  if is_website(current_url, "www.youtube.com") then
    result = handle_youtube(window_id)
    return process_result(result, "YouTube")
  elseif is_website(current_url, "www.bilibili.com") then
    result = handle_bilibili(window_id)
    return process_result(result, "Bilibili")
  else
    result = handle_generic_website(window_id)
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

  local script = string.format(
    [[
    tell application "Google Chrome"
        activate
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
  handle = vim.uv.spawn("osascript", {
    args = { "-e", script },
    stdio = { nil, nil, nil },
  }, function()
    handle:close()
  end)
end

return M
