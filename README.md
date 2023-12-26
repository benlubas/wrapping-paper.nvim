# wrapping-paper.nvim

https://github.com/benlubas/wrapping-paper.nvim/assets/56943754/c9bc31da-7716-4896-84ae-503b0509a44f

> [!NOTE]
> This is an early proof of concept, and it's not fully functional. But it's usable and useful in
> some cases

Simple plugin which enables wrapping a single line at a time using floating windows and virtual text trickery. I'm doing this by creating a floating window on the current line, opening the same buffer in the floating window, and then using auto commands to close the window when it scrolls. There are still a **TON** of bugs and unhandled edge cases, but this approach seems promising.

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

call setup if you want to wrap at different width, otherwise you don't need to

```lua
require("wrapping-paper").setup({
  width = math.huge, -- max width of the wrap window
  remaps = {
    -- { "mode", "lhs", "rhs" }, -- these are added to the buffer on open, and removed on close
    { "n", "j", "gj" }, -- defaults:
    { "n", "k", "gk" },
    { "n", "0", "g0" },
    { "n", "_", "g_" },
    { "n", "^", "g^" },
    { "v", "j", "gj" },
    { "v", "k", "gk" },
    { "v", "0", "g0" },
    { "v", "_", "g_" },
    { "v", "^", "g^" },
  }
})
```

Assign a mapping like this:

```lua
vim.keymap.set(
  "n",
  "gww", -- see :h gw to figure out why this makes sense.
  require("wrapping-paper").wrap_line,
  { desc = "fake wrap current line" }
)
```

## Shortcomings

- If you want to use spell suggest with telescope's floating windows, you're gonna have a bad time
  (z= works fine though)
- Moving out of the floating window isn't "natural" because one of your motions gets eaten
- keys that should scroll the buffer (like \<c-e\>) will just close the float when it would be nice
  if they scrolled the outer buffer.

Feel free to open issues/PRs if you find more problems or want to fix these ones!
