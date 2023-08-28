local M = {}
local api = vim.api
local helper = require("speedtyper.helper")

---@param opts table<string, any>
---@return integer
---@return integer
function M.open_float()
    local opts = require("speedtyper.config").opts.window
    local lines = vim.o.lines - vim.o.cmdheight
    local columns = vim.o.columns
    local height = helper.calc_size(opts.height, lines)
    local width = helper.calc_size(opts.width, columns)
    local bufnr = api.nvim_create_buf(false, true)
    local winnr = api.nvim_open_win(bufnr, true, {
        relative = "editor",
        row = math.floor((lines - height) / 2),
        col = math.floor((columns - width) / 2),
        anchor = "NW",
        width = width,
        height = height,
        border = opts.border,
        title = "Speedtyper",
        title_pos = "center",
        noautocmd = true,
    })
    return winnr, bufnr
end

return M
