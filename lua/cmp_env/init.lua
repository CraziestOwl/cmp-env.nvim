local cmp = require("cmp")
local util = require("cmp_env.util")
---@class cmp_env.Source: cmp.Source
---@field cache table: buffer cache
local source = {}

source.cache = {}

---@return cmp_env.Source
source.new = function()
  return setmetatable({}, { __index = source })
end

---@param callback function
source.complete = function(self, _, callback)
  local bufnr = vim.api.nvim_get_current_buf()
  if not self.cache[bufnr] and vim.bo.filetype ~= "direnv" then
    local items = {}
    local files = vim.tbl_extend("keep", vim.fn.glob(".env*", false, true), { os.getenv("DIRENV_FILE") })
    if not vim.tbl_isempty(files) then
      for _, file in ipairs(files) do
        for k, v in util.iter_env_vars(file) do
          if vim.regex("TOKEN\\|KEY\\|SECRET"):match_str(k) then
            v = vim.fn.substitute(v, "[^\\*]", "*", "g")
          end
          table.insert(items, {
            label = k,
            documentation = string.format("```bash\n%s=%s\n```", k, v),
            insertText = k, -- the text to insert when completed
            word = k,
            kind = cmp.lsp.CompletionItemKind.Text
          })
        end
      end
    end
    self.cache[bufnr] = items
  end
  callback(self.cache[bufnr])
end

source.get_trigger_characters = function()
  return { "$", '"', "'" }
end

source.get_keyword_pattern = function()
  return [[\k\+]]
end
return source
