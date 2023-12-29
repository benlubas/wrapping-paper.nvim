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
    { "n", "j", "v:count == 0 ? 'gj' : 'j'", { expr = true } },
    { "n", "k", "v:count == 0 ? 'gk' : 'k'", { expr = true } },
    { "n", "0", "g0" },
    { "n", "_", "g0" },
    { "n", "^", "g^" },
    { "v", "j", "v:count == 0 ? 'gj' : 'j'", { expr = true } },
    { "v", "k", "v:count == 0 ? 'gk' : 'k'", { expr = true } },
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

    -- remap <c-y> and <c-e> to allow scrolling the screen (this is a hack, and it causes window
    -- flashing. It's the simplest way to do this, and I don't plan to use these mappings very often)
    function()
      return { "n", "<c-e>",
        function()
          local cursor = vim.api.nvim_win_get_cursor(0)
          local keys = vim.api.nvim_replace_termcodes(":q<CR><C-e>:lua require('wrapping-paper').wrap_line()<CR>", true, false, true)
          vim.api.nvim_feedkeys(keys, "n", false)
          vim.api.nvim_win_set_cursor(0, cursor)
        end
      }
    end,
    function()
      return { "n", "<c-y>",
        function()
          local cursor = vim.api.nvim_win_get_cursor(0)
          local keys = vim.api.nvim_replace_termcodes(":q<CR><C-y>:lua require('wrapping-paper').wrap_line()<CR>", true, false, true)
          vim.api.nvim_feedkeys(keys, "n", false)
          vim.api.nvim_win_set_cursor(0, cursor)
        end
      }
    end
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

In rough order of priority:

- Moving out of the floating window isn't "natural" because one of your motions gets eaten
- keys that should scroll the buffer (like \<c-e\>) will just close the float when it would be nice
if they scrolled the outer buffer.
- If you want to use spell suggest with telescope's floating windows, you're gonna have a bad time
  (z= works fine though)

Feel free to open issues/PRs if you find more problems or want to fix these ones!
