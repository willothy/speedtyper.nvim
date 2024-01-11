--- TODO: finish this when other game modes are implemented
local Countdown = require("speedtyper.game_modes.countdown")
local Stopwatch = require("speedtyper.game_modes.stopwatch")
local Rain = require("speedtyper.game_modes.rain")
local Util = require("speedtyper.util")

---@class SpeedTyperRound
---@field active_game_mode SpeedTyperGameMode
---@field bufnr integer

---@class SpeedTyperGameMode
---@field timer uv_timer_t
---@field bufnr integer
---@field ns_id integer
---@field extm_ids integer[]
---@field text string[]
---@field text_generator SpeedTyperText
---@field typos_tracker SpeedTyperTyposTracker

local SpeedTyperRound = {}
SpeedTyperRound.__index = SpeedTyperRound

---@param bufnr? integer
function SpeedTyperRound.new(bufnr)
    local round = {
        active_game_mode = nil,
        bufnr = bufnr or 0,
    }
    return setmetatable(round, SpeedTyperRound)
end

---@param game_mode string
function SpeedTyperRound:set_game_mode(game_mode)
    if game_mode == "countdown" then
        self.active_game_mode = Countdown.new(self.bufnr)
    elseif game_mode == "stopwatch" then
        self.active_game_mode = Stopwatch.new(self.bufnr)
    elseif game_mode == "rain" then
        self.active_game_mode = Rain.new(self.bufnr)
    else
        Util.error("Invalid game mode: " .. game_mode)
    end
end

function SpeedTyperRound:start_round()
    if self.active_game_mode then
        self.active_game_mode:start()
    end
end

function SpeedTyperRound:end_round()
    if self.active_game_mode then
        self.active_game_mode:stop()
    end
end

return SpeedTyperRound
