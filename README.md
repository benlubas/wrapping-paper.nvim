# wrapping-paper.nvim

> [!NOTE]
> This is an incredibly early proof of concept, and it's not fully functional, or even that useful
> at the moment, and it's full of bugs

Simple plugin which enables wrapping a single line at a time using floating windows (and eventually virtual text trickery). I'm doing this by creating a floating window on the current line, opening the same buffer in the floating window, and then closing the window when it scrolls. Like I mentioned, there are a **TON** of bugs and unhandled edge cases. But the approach seems promising.

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
