--- TODO: open the pdf/url under the cursor when we moved to the bookmark(which is folded text in neovim)
local M = {}

--- Search file from tag
--- @param tag table {tag: string, type: string}
--- @param path string the log file path
--- @return table the line that contains the tag
function M.search_from_tag(tag, path)
  if tag.type == "pdf" or tag.type == "url" then
    local file = io.open(path, "r")
    if not file then
      vim.notify("File not found: " .. path, vim.log.levels.ERROR)
      return { line = nil, type = tag.type }
    end

    for line in file:lines() do
      if line:find(tag.tag) then
        file:close()
        return { line = line, type = tag.type }
      end
    end

    file:close()
  end
end

return M
