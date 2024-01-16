local Util = require("speedtyper.util")
local Menu = require("speedtyper.menu")

---@class SpeedTyperUI
---@field bufnr integer
---@field winnr integer
---@field active boolean
---@field settings SpeedTyperWindowConfig
---@field menu SpeedTyperMenu

local SpeedTyperUI = {}
SpeedTyperUI.__index = SpeedTyperUI

---@param settings SpeedTyperWindowConfig
---@return SpeedTyperUI
function SpeedTyperUI.new(settings)
    local ui = {
        bufnr = nil,
        winnr = nil,
        settings = settings,
        active = false,
        menu = nil,
    }
    return setmetatable(ui, SpeedTyperUI)
end

function SpeedTyperUI:_create_autocmds()
    local autocmd = vim.api.nvim_create_autocmd
    local augroup = vim.api.nvim_create_augroup
    local grp = augroup("SpeedTyperUI", {})

    autocmd({ "BufLeave", "BufDelete", "BufWinLeave" }, {
        group = grp,
        buffer = self.bufnr,
        once = true,
        callback = function()
            SpeedTyperUI._close(self)
        end,
        desc = "Close SpeedTyper window when leaving buffer (to update the ui internal state)",
    })
    autocmd("WinLeave", {
        group = grp,
        pattern = "*",
        once = true,
        callback = function()
            if self.active then
                SpeedTyperUI._close(self)
            end
        end,
        desc = "If some bug occurs and somehow the user manages to accidentally open something other than SpeedTyper inside its window and then exists that window, update the ui internal state)",
    })
    -- TODO: FIND OUT WHY THIS DOESN'T WORK FOR UNLISTED/SCRATCH BUFFERS EVEN THOUGH THEY GET HIDDEN
    -- autocmd("BufHidden", {
    --     group = grp,
    --     -- buffer = self.bufnr,
    --     pattern = "*",
    --     callback = function(ev)
    --         print(ev.event, ev.buf)
    --     end,
    -- })
    -- HACK: should do the same as the BufHidden autocmd, currently only opening netrw inside Speedtyper window creates problems
    autocmd("FileType", {
        group = grp,
        pattern = "*",
        once = true,
        callback = function(ev)
            if ev.buf ~= self.bufnr and self.active then
                SpeedTyperUI._close(self)
            end
        end,
        desc = "Close the SpeedTyper window if the user opens up netrw inside of it.",
    })
end

---@param settings SpeedTyperWindowConfig
function SpeedTyperUI:_open(settings)
    if self.active then
        return
    end

    local preffered_height = 10
    local preffered_width = 69
    local nvim_uis = vim.api.nvim_list_uis()
    if #nvim_uis > 0 then
        if nvim_uis[1].height <= preffered_height or nvim_uis[1].width <= preffered_width then
            Util.error("Increase the size of your Neovim instance.")
        end
    end
    local cols = vim.o.columns
    local lines = vim.o.lines - vim.o.cmdheight
    local bufnr = vim.api.nvim_create_buf(false, true)
    local winnr = vim.api.nvim_open_win(bufnr, true, {
        relative = "editor",
        anchor = "NW",
        title = "SpeedTyper",
        row = math.floor((lines - preffered_height) / 2),
        col = math.floor((cols - preffered_width) / 2),
        width = preffered_width,
        height = preffered_height,
        style = "minimal",
        border = settings.border,
        noautocmd = true,
    })

    self.bufnr = bufnr
    self.winnr = winnr
    self.active = true

    if winnr == 0 then
        Util.error("Failed to open window")
        SpeedTyperUI._close(self)
    end

    SpeedTyperUI.disable(self)
    SpeedTyperUI._create_autocmds(self)
    Util.clear_buffer_text(10, self.bufnr)
    self.menu = Menu.new(self.bufnr)
    Menu.display_menu(self.menu)
end

function SpeedTyperUI:_close()
    if not self.active then
        return
    end

    if self.bufnr ~= nil and vim.api.nvim_buf_is_valid(self.bufnr) then
        vim.api.nvim_buf_delete(self.bufnr, { force = true })
    end

    if self.winnr ~= nil and vim.api.nvim_win_is_valid(self.winnr) then
        vim.api.nvim_win_close(self.winnr, true)
    end
    self.bufnr = nil
    self.winnr = nil
    self.active = false
    if self.menu then
        self.menu.round:end_round()
        self.menu = nil
    end
    pcall(vim.api.nvim_del_augroup_by_name, "SpeedTyperUI")
end

function SpeedTyperUI:toggle()
    if self.active then
        SpeedTyperUI._close(self)
    else
        SpeedTyperUI._open(self, self.settings)
    end
end

function SpeedTyperUI:disable()
    vim.wo[self.winnr].wrap = false
    if package.loaded["cmp"] then
        -- disable cmp while playing the game
        require("cmp").setup.buffer({ enabled = false })
    end
end

---calculate the dimension of the floating window
---@param size number
---@param viewport integer
function SpeedTyperUI.calc_size(size, viewport)
    if size <= 1 then
        return math.ceil(size * viewport)
    end
    return math.min(size, viewport)
end

return SpeedTyperUI
