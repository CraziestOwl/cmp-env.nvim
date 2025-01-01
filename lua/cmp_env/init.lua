local cmp = require('cmp')
local context = require("plenary.context_manager")
local open = context.open
local with = context.with

---@class cmp_env.Source: cmp.Source
---@field cache table: buffer cache
local source = {}

source.cache = {}

---@param file string
---@return string[]
local read = function(file)
  if vim.fn.filereadable(file) == 1 then
    return with(open(file), function(reader)
      return vim.split(reader:read("*a"):gsub("export ", ""), "\n", { trimempty = true })
    end)
  end
  return {}
end

---@return cmp_env.Source
source.new = function()
  return setmetatable({}, { __index = source })
end

---@param callback function
source.complete = function(self, _, callback)
  local bufnr = vim.api.nvim_get_current_buf()
  local items = {}
  if not self.cache[bufnr] and vim.bo.filetype ~= "direnv" then
    local files = vim.tbl_extend('keep', vim.fn.glob(".env*", false, true), { os.getenv("DIRENV_FILE") })
    if not vim.tbl_isempty(files) then
      for _, file in ipairs(files) do
        for _, line in ipairs(read(file)) do
          local k, v = line:match("(.-)=(.+)")
          if vim.regex("TOKEN\\|KEY\\|SECRET"):match_str(k) then
            v = vim.fn.substitute(v, "[^\\*]", "*", "g")
          end
          table.insert(items, {
            label = k,
            documentation = string.format("```sh\n%s=%s\n```", k, v),
            insertText = k, -- the text to insert when completed
            word = k,
            kind = cmp.lsp.CompletionItemKind.Text
          })
        end
      end
    end
    self.cache[bufnr] = items
    callback(items)
  else
    callback(self.cache[bufnr])
  end
end

source.get_trigger_characters = function()
  return { "$", '"' }
end

source.get_keyword_pattern = function()
  return [[\k\+]]
end
return source
