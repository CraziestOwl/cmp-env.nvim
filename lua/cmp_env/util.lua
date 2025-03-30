local context = require("plenary.context_manager")
local open = context.open
local with = context.with

local M = {}
--- Reads the content of the specified file, removes export statements, trims whitespace,
--- and filters out empty lines and comments (lines starting with #).
--- @param file string Path to the file to read.
--- @return string[] : Array of the filtered lines from the file, or empty array if the file doesn't exist.
local _read = function(file)
  if vim.fn.filereadable(file) == 1 then
    return with(open(file), function(reader)
      return vim.tbl_filter(function(line)
        if line then
          line = line:gsub("^%s*", "")
          return not (line == "")
        else
          return false
        end
      end, vim.split(reader:read("*a"):gsub("export%s*", ""), "\n", { trimempty = true }))
    end)
  end
  return {}
end

--- Returns an iterator that yields name-value pairs for each environment variable in a file.
--- @param file string Path to the environment file to parse.
--- @return (fun(): string, string) : Iterator that returns (name, value) for each environment variable.
M.iter_env_vars = function(file)
  local ls = _read(file)
  local len = #ls
  local quote = nil
  local start = true
  local key = nil
  local function iter()
    local value = ""
    local current_line = ""
    while len > 0 do
      current_line = table.remove(ls, 1)
      len = len - 1
      if not current_line then
        return nil
      end
      if start then
        if vim.regex("^#"):match_str(current_line) then
          return iter()
        end
        local s = current_line:find("=", 1, true)
        key = current_line:sub(1, s - 1)
        value = ""
        start = false
        current_line = current_line:sub(s + 1)
      end
      if quote then
        if current_line:sub(-1) == quote then
          -- current_line = current_line == quote and "" or current_line:sub(1, -2)
          current_line = current_line == quote and "" or current_line
          quote = nil
          start = true
        else
          current_line = current_line .. "\n"
        end
      else
        local temp = current_line:sub(1, 1)
        if temp == '"' or temp == "'" then
          -- current_line = current_line:sub(2)
          if current_line:sub(-1) == temp then
            -- current_line = current_line:sub(1, -2)
            start = true
          else
            quote = temp
            current_line = current_line .. "\n"
          end
        else
          start = true
        end
      end
      value = value .. current_line
      if key and start then
        return key, value
      end
    end
  end
  return iter
end
return M
