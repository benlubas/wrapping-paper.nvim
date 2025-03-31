local M = {}
local Popup = require("nui.popup")
local namespace = vim.api.nvim_create_namespace("wrapping_paper")

local open_buf = nil

-- special function to account for the way `gk` doesn't do what you expect when the line above
-- would also be wrapped. `gj` does not have this issue, in fact, doing this for `gj` would
-- make it misbehave
local function k()
  local count = vim.v.count
  local cursor = vim.api.nvim_win_get_cursor(0)
  local keys = "gk"
  if count == 0 and (not M.first_line_length or cursor[2] <= M.first_line_length) then
    keys = "k"
  end

  vim.api.nvim_feedkeys(keys, "n", false)
end

local config = {
  width = math.huge,
  remaps = {
    { "n", "j", "v:count == 0 ? 'gj' : 'j'", { expr = true } },
    { "n", "k", k },
    { "n", "0", "g0" },
    { "n", "_", "g0" },
    { "n", "^", "g^" },
    { "v", "j", "v:count == 0 ? 'gj' : 'j'", { expr = true } },
    { "v", "k", k },
    { "v", "0", "g0" },
    { "v", "_", "g0" },
    { "v", "^", "g^" },
    -- these functions are called when the cursor is still in the parent window
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
}

M.setup = function(opts)
  config = vim.tbl_deep_extend("force", config, opts or {})
end

M.first_line_length = nil
local calc_height = function(text, width)
  local lines = vim.split(text, "\n")
  local height = 0
  for li, line in ipairs(lines) do
    local left_offset = 0

    -- account for breakindent
    local leading_white_space = line:match("^%s+")
    if leading_white_space and vim.wo.breakindent then
      left_offset = left_offset + #leading_white_space
      line = line:sub(#leading_white_space)
    end

    -- account for showbreak
    if li > 1 then
      left_offset = left_offset + #vim.wo.showbreak
    end

    width = width - left_offset
    while #line > 0 do
      if #line < width then
        height = height + 1
        break
      end
      local chunk = line:sub(0, width)
      local i = #chunk
      while i > 0 do
        if vim.tbl_contains(vim.split(vim.o.breakat, ""), chunk:sub(i, i)) then
          break
        end
        i = i - 1
        if i == 0 then
          -- we didn't find a space, so we just break the line at the width
          i = width
          break
        end
      end
      M.first_line_length = M.first_line_length or i
      line = line:sub(i)
      height = height + 1
    end
  end
  return height
end

local linenumber = nil
M.wrap_line = function()
  if open_buf then
    return
  end

  local cursor = vim.api.nvim_win_get_cursor(0)
  linenumber = cursor[1]
  local cursor_col = cursor[2]

  local win = vim.api.nvim_get_current_win()
  local pos = vim.fn.screenpos(win, linenumber, cursor_col)
  local win_info = vim.fn.getwininfo(win)[1]
  local row = pos.row - 1
  local col = win_info.wincol + win_info.textoff - 1
  local width = win_info.width - win_info.textoff
  width = math.min(width, config.width)

  local text = vim.api.nvim_get_current_line()

  local height = calc_height(text, width)
  if height <= 1 then
    return
  end

  open_buf = vim.api.nvim_get_current_buf()
  vim.api.nvim_win_set_cursor(0, { linenumber, 0 })

  local popup = Popup({
    focusable = true,
    enter = true,
    bufnr = open_buf,
    border = { style = "none" },
    relative = {
      type = "editor",
    },
    position = {
      row = row,
      col = col,
    },
    size = {
      height = height,
      width = width,
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
      spell = vim.o.spell,
    },
  })
  for _, item in ipairs(config.remaps) do
    if type(item) == "function" then
      item = item()
    end
    popup:map(item[1], item[2], item[3], item[4])
  end
  popup:mount()
  -- add virtual text
  local vt = {}
  for _ = 1, height - 1 do
    table.insert(vt, { { " ", "Comment" } })
  end
  local extmark_id = vim.api.nvim_buf_set_extmark(open_buf, namespace, linenumber - 1, 0, {
    virt_lines = vt,
  })
  popup:on({ "BufLeave", "BufDelete", "WinClosed", "WinLeave" }, function()
    popup:off({ "BufLeave", "BufDelete", "WinScrolled" })
    for _, item in ipairs(config.remaps) do
      if type(item) == "function" then
        item = item()
      end
      popup:unmap(item[1], item[2])
    end
    vim.api.nvim_buf_del_extmark(open_buf, namespace, extmark_id)
    open_buf = nil
    popup:unmount()
  end)
  popup:on({ "WinScrolled", "TextChanged", "TextChangedI" }, function(e)
    vim.api.nvim_get_option_value("eventignore", { scope = "global" })
    local line = vim.api.nvim_get_current_line()
    local moved_cursor = vim.api.nvim_win_get_cursor(0)
    -- potentially update the height
    if moved_cursor[1] == linenumber then
      local updated_height = calc_height(line, width)
      popup:update_layout({
        relative = "editor",
        position = {
          row = popup.win_config.row,
          col = popup.win_config.col,
        },
        size = {
          height = updated_height,
          width = width,
        },
      })

      -- update the virtual text

      local updated_vt = {}
      for _ = 1, updated_height - 1 do
        table.insert(updated_vt, { { " ", "Comment" } })
      end
      -- add virtual text
      vim.api.nvim_buf_set_extmark(open_buf, namespace, linenumber - 1, 0, {
        id = extmark_id,
        virt_lines = updated_vt,
      })
      return
    end

    -- else, if it moved the line, close the window
    popup:off({ "BufLeave", "BufDelete", "WinScrolled" })
    for _, item in ipairs(config.remaps) do
      if type(item) == "function" then
        item = item()
      end
      popup:unmap(item[1], item[2])
    end
    vim.api.nvim_buf_del_extmark(open_buf, namespace, extmark_id)
    open_buf = nil
    popup:unmount()

    -- restore the cursor
    vim.api.nvim_win_set_cursor(0, moved_cursor)
  end)
  popup:show()
  vim.api.nvim_win_set_cursor(popup.winid, { linenumber, cursor[2] })
end

return M
