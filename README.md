# wrapping-paper.nvim

https://github.com/benlubas/wrapping-paper.nvim/assets/56943754/c9bc31da-7716-4896-84ae-503b0509a44f


<!-- this line is intentionally not wrapped -->
Simple plugin which enables wrapping a single line at a time using floating windows and virtual text trickery. I'm doing this by creating a floating window on the current line, opening the same buffer in the floating window (so that syntax is normal and changes will take effect), using virtual text so the wrapped line appears to occupy space in the buffer, and then using auto commands to close the window when it scrolls. There are also a few remaps that make the cursor behave itself.

There are probably still bugs and unhandled edge cases, but this is working pretty well and I'm
happy with it for the time being.

## Install

Example with lazy:

```lua
{ "benlubas/wrapping-paper.nvim" },
```

_([nui.nvim](https://github.com/MunifTanjim/nui.nvim) is installed as a dependency
via the rockspec)_

## Usage

call setup if you want to wrap at different width, otherwise you don't need to. Messing with
keybinds is a little fiddly depending on the keybinds you want.

```lua
require("wrapping-paper").setup({
  width = math.huge, -- max width of the wrap window
  remaps = {
    -- { "mode", "lhs", "rhs" }, -- these are added to the buffer on open, and removed on close
    { "n", "j", "v:count == 0 ? 'gj' : 'j'", { expr = true } },
    { "n", "k", "v:count == 0 ? 'gk' : 'k'", { expr = true } }, -- This isn't really how it's done, the real mapping for k is more complicated, but it will function like this
    { "n", "0", "g0" },
    { "n", "_", "g0" },
    { "n", "^", "g^" },
    { "v", "j", "v:count == 0 ? 'gj' : 'j'", { expr = true } },
    { "v", "k", "v:count == 0 ? 'gk' : 'k'", { expr = true } }, -- same as normal mode k ^
    { "v", "0", "g0" },
    { "v", "_", "g0" },
    { "v", "^", "g^" },

    -- NOTE: these functions are called when the cursor is still in the parent window
    -- remap <c-d> and <c-u>, otherwise they scroll half the popup height which is not what you
    -- expect to happen
    function()
      return { "n", "<c-d>", math.floor(vim.api.nvim_win_get_height(0) / 2) .. "j" }
    end,
    function()
      return { "n", "<c-u>", math.floor(vim.api.nvim_win_get_height(0) / 2) .. "k" }
    end,
    {
      "n",
      "<c-e>",
      function()
        local cursor = vim.api.nvim_win_get_cursor(0)
        local keys = vim.api.nvim_replace_termcodes(
          ":q<CR><C-e>:lua require('wrapping-paper').wrap_line()<CR>",
          true,
          false,
          true
        )
        vim.api.nvim_feedkeys(keys, "n", false)
        vim.api.nvim_win_set_cursor(0, cursor)
      end,
    },
    {
      "n",
      "<c-y>",
      function()
        local cursor = vim.api.nvim_win_get_cursor(0)
        local keys = vim.api.nvim_replace_termcodes(
          ":q<CR><C-y>:lua require('wrapping-paper').wrap_line()<CR>",
          true,
          false,
          true
        )
        vim.api.nvim_feedkeys(keys, "n", false)
        vim.api.nvim_win_set_cursor(0, cursor)
      end,
    },
  },
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

- Treesitter context windows don't show up when you're in the window
- If you want to use spell suggest with telescope's floating windows, you're gonna have a bad time
  (z= works fine though) I'm not going to fix this. if you really care, you can use 'eventignore' to
  open the telescope window to avoid setting off the autocommands that close the window. This is
  just something you can do yourself in your telescope mapping.
