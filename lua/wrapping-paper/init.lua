local M = {}
local Popup = require("nui.popup")

local config = {
  width = 100, -- wrap at 100 chars
}

M.setup = function(opts)
  config = vim.tbl_deep_extend("force", config, opts or {})
end

-- TODO: This is just a rough estimate, it doesn't take into account chars in 'breakat'
local calc_height = function(text, width)
  local lines = vim.split(text, "\n")
  local height = 0
  for _, line in ipairs(lines) do
    while #line > 0 do
      if #line < width then
        height = height + 1
        break
      end
      local chunk = line:sub(0, width)
      local i = #chunk
      while i > 0 do
        if vim.tbl_contains({ " ", "\t" }, chunk:sub(i, i)) then
          break
        end
        i = i - 1
        if i == 0 then
          -- we didn't find a space, so we just break the line at the width
          i = width
          break
        end
      end
      line = line:sub(i)
      height = height + 1
    end
  end
  return height
end

local linenumber = nil
M.wrap_line = function()
  linenumber = vim.api.nvim_win_get_cursor(0)[1]

  local win = vim.api.nvim_get_current_win()
  local pos = vim.fn.screenpos(win, linenumber, 0)
  local win_off = P(vim.fn.getwininfo(win)[1])
  local row = pos.row - (win_off.winrow)
  local col = pos.col - (win_off.wincol)

  vim.api.nvim_win_set_cursor(0, { linenumber, 0 })
  local text = vim.api.nvim_get_current_line()
  local buf = vim.api.nvim_get_current_buf()

  local popup = Popup({
    focusable = true,
    enter = true,
    bufnr = buf,
    border = { style = "none" },
    relative = {
      type = "editor",
    },
    position = {
      row = row,
      col = col,
    },
    size = {
      height = calc_height(text, config.width),
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
  popup:on({ "BufLeave", "BufDelete", "WinScrolled" }, function()
    local line = vim.api.nvim_get_current_line()
    local linenr = vim.api.nvim_win_get_cursor(0)[1]
    -- potentially update the height
    if linenr == linenumber then
      local height = calc_height(line, config.width)
      popup:update_layout({
        relative = "editor",
        position = {
          row = popup.win_config.row,
          col = popup.win_config.col,
        },
        size = {
          height = height,
          width = config.width,
        },
      })
      linenumber = linenr
      return
    end
    popup:unmount()
    popup:off({ "BufLeave", "BufDelete", "WinScrolled" })
  end)
  popup:show()
end

return M
