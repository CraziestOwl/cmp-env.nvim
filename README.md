# cmp-env
nvim-cmp source for environment variables

## Optional dependencies
[direnv](https://github.com/direnv/direnv) allows automatic loading of environment variables from .envrc files.

When a .envrc file is loaded from the current working directory or any parent directory, the environment variables specified in the file referenced by `DIRENV_FILE` will be added to the completion list.

# Setup
```lua
local cmp = require("cmp")
cmp.setup({
    sources = cmp.config.sources({
        { name = "cmp_env" }
    })
})
```
