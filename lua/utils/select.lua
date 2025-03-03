-- fast select

local M = {}

--- Generate an index table from a table
--- @param tbl table|nil The table to be indexed
--- @return number[] The index table
function M.GenerateIndex(tbl)
  local indices = {}
  if tbl then
    for _, entry in ipairs(tbl) do
      table.insert(indices, entry.col) -- Use the num value as the index
    end
  end
  return indices
end

--- Sorts the table based on the distance of indices to a given number x
--- @param indices number[] Array of indices
--- @param tbl table|nil The table to be sorted
--- @param x number The reference number to calculate distance
--- @return table The sorted table
function M.SortTablebyDistance(indices, tbl, x)
  -- Create a table of {index, value} pairs
  if not tbl then
    return {}
  end
  local indexed_tbl = {}
  for i, idx in ipairs(indices) do
    table.insert(indexed_tbl, { index = idx, value = tbl[i] })
  end

  -- Sort the indexed table based on the distance to x
  table.sort(indexed_tbl, function(a, b)
    return math.abs(a.index - x) < math.abs(b.index - x)
  end)

  -- Create a new sorted table based on the sorted indices
  local sorted_tbl = {}
  for _, pair in ipairs(indexed_tbl) do
    table.insert(sorted_tbl, pair.value)
  end

  return sorted_tbl
end

return M

---- Example usage ------
-- local function get_all_pdfs(file_path)
--   local file = io.open(file_path, "r")
--   if not file then
--     print("Error: Unable to open file " .. file_path)
--     return {}
--   end
--
--   local paths = {}
--   for line in file:lines() do
--     if line:match("page:") then
--       local path = line:match("path: ([^,]+)")
--       local num = line:match("{(%d+),")
--       if path and num then
--         -- Extract the part matching 'xxx.pdf'
--         local extracted_path = path:match(".+/([^/]+%.pdf)}")
--         if extracted_path then
--           table.insert(paths, { "pdf", num, extracted_path })
--         end
--       end
--     end
--   end
--
--   file:close()
--   return paths
-- end
--
-- local file_path = vim.fn.expand("~/.local/state/nvim/note/_Users_pxwg-dogggie_.config_nvim_test.tex.txt")
-- local pdfs = get_all_pdfs(file_path)
-- local indices = GenerateIndex(pdfs)
--
-- -- Print the index table
-- for _, index in ipairs(indices) do
--   print(index)
-- end
--
-- local function print_table(pdfs)
--   for _, entry in ipairs(pdfs) do
--     print(string.format('{"%s", %s, "%s"}', entry[1], entry[2], entry[3]))
--   end
-- end
--
-- print_table(pdfs)
