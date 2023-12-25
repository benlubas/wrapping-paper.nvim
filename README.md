# wrapping-paper.nvim

> [!NOTE]
> This is an incredibly early proof of concept, and it's not fully functional, or even that useful
> at the moment

Simple plugin which enables wrapping a single line at a time using floating windows (and eventually
virtual text trickery).

## Install

Example with lazy:

```lua
{
  "benlubas/wrapping-paper.nvim",
  dependencies = {
    "MunifTanjim/nui.nvim",
  },
},
```


## Usage

call setup if you want to wrap at different widths, otherwise you don't need to

```lua
require("wrapping-paper").setup({
    width = 100, -- default
})
```

Assign a mapping like this:

```lua
vim.keymap.set(
  "n",
  "<localleader>w",
  require("wrapping-paper").wrap_line,
  { desc = "fake wrap current line" }
)
```
