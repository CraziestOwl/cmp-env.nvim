local cmp = require('cmp')
local lsp = require('vim.lsp')
local context = require("plenary.context_manager")
local open = context.open
local with = context.with

---@class cmp_env.Options
---@field public keyword_length number
---@field public filter_by_input boolean

---@type cmp_env.Options
local defaults = {
  keyword_length = 3,
  filter_by_input = false
}


---@class cmp_env.Source: cmp.Source
---@field cache table: buffer cache
---@field public opts cmp_env.Options
local source = {}


---@param file string
---@return string[]
local read = function(file)
  if vim.fn.filereadable(file) == 1 then
    return with(open(file), function(reader)
      return vim.tbl_filter(function(line)
        if line then
          -- Ignore empty lines and comments(starting with #)
          line = line:gsub("^%s*", "")
          return not (line == "" or vim.regex("^#"):match_str(line))
        else
          return false
        end
      end, vim.split(reader:read("*a"):gsub("export%s*", ""), "\n", { trimempty = true }))
    end)
  end
  return {}
end

---@return cmp_env.Source
source.new = function()
  local self = setmetatable({}, { __index = source })
  self.cache = {}
  return self
end

---@return cmp_env.Options
source._validate_options = function(_, params)
  local opts = vim.tbl_deep_extend('keep', params.option, defaults)
  vim.validate({
    keyword_length = { opts.keyword_length, 'number' },
    filter_by_input = { opts.filter_by_input, 'boolean' }
  })
  return opts
end

---@param callback function
---@param params cmp.SourceCompletionApiParams
source.complete = function(self, params, callback)
  local bufnr = vim.api.nvim_get_current_buf()
  if not self.cache[bufnr] and vim.bo.filetype ~= "direnv" then
    local completions = {}
    local files = vim.tbl_extend('keep', vim.fn.glob(".env*", false, true), { os.getenv("DIRENV_FILE") })
    if not vim.tbl_isempty(files) then
      for _, file in ipairs(files) do
        for _, line in pairs(read(file)) do
          local k, v = line:match("%s*(.-)=(.+)%s*")
          if vim.regex("TOKEN\\|KEY\\|SECRET"):match_str(k) then
            v = vim.fn.substitute(v, "[^\\*]", "*", "g")
          end
          table.insert(completions, {
            label = k,
            documentation = string.format("```sh\n%s=%s\n```", k, v),
            insertText = k, -- the text to insert when completed
            word = k,
            kind = cmp.lsp.CompletionItemKind.Text
          })
        end
      end
    end
    self.cache[bufnr] = completions
  end
  callback(self.cache[bufnr])

  -- TODO: Implement filter_by_input
  --
  -- local opts = vim.tbl_deep_extend('keep', params.option, defaults)
  -- if opts.filter_by_input and params.completion_context.triggerKind == 1 then
  --   local input = string.sub(params.context.cursor_before_line, params.offset)
  --   local items = {}
  --   for _, key in ipairs(self.cache[bufnr]) do
  --     key.label
  --   end
  --   callback(self.cache[bufnr])
  -- else
  --   callback(self.cache[bufnr])
  -- end
end
source.get_trigger_characters = function()
  return { "$", '"' }
end

source.resolve = function(completion_item, callback)
  vim.print(completion_item)
  callback(completion_item)
end

source.get_keyword_pattern = function(self, params)
  local opts = self:_validate_options(params)
  return [[\k\{]] .. opts.keyword_length .. [[,}]]
end
return source
