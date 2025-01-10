# cmp-env
[nvim-cmp](https://github.com/hrsh7th/nvim-cmp) source for environment variables

## Required dependencies
[nvim-lua/plenary.nvim](https://github.com/nvim-lua/plenary.nvim)

## Optional dependencies
[direnv](https://github.com/direnv/direnv) allows automatic loading of environment variables from .envrc files.

When a .envrc file is loaded from the current working directory or any parent directory, the environment variables specified in the file referenced by `DIRENV_FILE` will be added to the completion list.

## Installation with lazy.nvim
```lua
{
  "hrsh7th/nvim-cmp",
  dependencies = {
   "CraziestOwl/cmp-env.nvim",
   "nvim-lua/plenary.nvim"
  },
}
```
## Setup
```lua
local cmp = require("cmp")
cmp.setup({
    sources = cmp.config.sources({
        { name = "cmp_env" }
    })
})
```
