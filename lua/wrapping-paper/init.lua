local M = {}
local Popup = require("nui.popup")

local config = {
  width = 100, -- wrap at 100 chars
}


M.setup = function(opts)
  config = vim.tbl_deep_extend("force", config, opts or {})
end

-- TODO: This is just a rough estimate, it doesn't take into account for 'breakat'
local calc_height = function(text)
  local lines = vim.split(text, "\n")
  local height = 0
  for _, line in ipairs(lines) do
    height = height + math.ceil(#line / config.width)
  end
  return height
end

M.wrap_line = function()
  vim.api.nvim_win_set_cursor(0, { vim.api.nvim_win_get_cursor(0)[1], 0 })
  local text = vim.api.nvim_get_current_line()
  local buf = vim.api.nvim_get_current_buf()

  local popup = Popup({
    focusable = true,
    enter = true,
    bufnr = buf,
    border = { style = "none" },
    relative = {
      type = "cursor",
    },
    position = {
      row = 0,
      col = 0,
    },
    size = {
      height = calc_height(text),
      width = config.width,
    },
    -- TODO: there might be more of these, really I should just use the "minimal" window style, but
    -- idk how to do that with nui
    win_options = {
      wrap = true,
      signcolumn = "no",
      number = false,
      relativenumber = false,
      cursorline = false,
      cursorcolumn = false,
      foldcolumn = "0",
      showbreak = "",
    },
  })
  popup:mount()
  local gmaps = { "j", "k", "0", "_", "^" }
  for _, key in ipairs(gmaps) do
    popup:map("n", key, "g" .. key)
  end
  popup:on({"BufLeave", "BufDelete", "WinScrolled"}, function()
    popup:unmount()
  end)
  popup:show()
end

return M
