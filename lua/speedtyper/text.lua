local Util = require("speedtyper.util")

---@class SpeedTyperText
---@field selected_lang string
---@field words string[]

local SpeedTyperText = {}
SpeedTyperText.__index = SpeedTyperText

function SpeedTyperText.new()
    local text = {
        selected_lang = "",
        words = {},
    }
    return setmetatable(text, SpeedTyperText)
end

---@return string[]
function SpeedTyperText.get_available_langs()
    return { "en", "sr" }
end

---@param lang string
function SpeedTyperText:set_lang(lang)
    if
        Util.tbl_contains(self.get_available_langs(), lang, function(a, b)
            return a == b
        end)
    then
        self.selected_lang = lang
        self.words = require("speedtyper.langs." .. lang)
        math.randomseed(os.time())
    else
        Util.error("Invalid language: " .. lang)
    end
end

---@return string
function SpeedTyperText:get_word()
    return self.words[math.random(#self.words)]
end

---@param win_width integer
---@return string
function SpeedTyperText:generate_sentence(win_width)
    local border_width = 2
    local extra_space = 1 -- at the end of the sentence
    local usable_width = win_width - 2 * border_width - extra_space -- 2 * border -> left and right border
    local sentence = self:get_word()
    local word = self:get_word()
    while #sentence + #word < usable_width do
        sentence = sentence .. " " .. word
        word = self:get_word()
    end
    return sentence .. " "
end

return SpeedTyperText
