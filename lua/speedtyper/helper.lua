local M = {}
local api = vim.api
local ns_id = api.nvim_get_namespaces()["Speedtyper"]
local words = require("speedtyper.langs").get_words()
local normal = vim.cmd.normal

---calculate the dimension of the floating window
---@param size number
---@param viewport integer
function M.calc_size(size, viewport)
    if size <= 1 then
        return math.ceil(size * viewport)
    end
    return math.min(size, viewport)
end

---@return integer
---@return integer
function M.get_cursor_pos()
    local line = vim.fn.line(".")
    local col = vim.fn.col(".")
    return line, col
end

---@return string
function M.generate_sentence()
    local win_width = api.nvim_win_get_width(0)
    local width_percentage = 0.85
    local sentence = ""
    local word = words[math.random(1, #words)]
    while #sentence + #word < width_percentage * win_width do
        sentence = word .. " " .. sentence
        word = words[math.random(1, #words)]
    end
    return sentence
end

---@param bufnr integer
---@return integer[]
---@return string[]
function M.generate_extmarks(bufnr)
    M.clear_text(bufnr)
    local extm_ids = {}
    local sentences = {}
    for i = 1, 4 do
        local sentence = M.generate_sentence()
        local extm_id = api.nvim_buf_set_extmark(bufnr, ns_id, i - 1, 0, {
            virt_text = {
                { sentence, "Comment" },
            },
            hl_mode = "combine",
            virt_text_win_col = 0,
        })
        table.insert(sentences, sentence)
        table.insert(extm_ids, extm_id)
    end

    return extm_ids, sentences
end

---additional variables used for fixing edge cases
---@type integer
M.prev_line = 0
---@type integer
M.prev_col = 0

---update extmarks according to the cursor position
---@param sentences string[]
---@param extm_ids integer[]
---@param bufnr integer
---@return integer[]
---@return string[]
function M.update_extmarks(sentences, extm_ids, bufnr)
    local line, col = M.get_cursor_pos()

    -- NOTE: so I don't forget what is going on here
    --[[
        - a lot of +- 1 because of inconsistent indexing in provided functions
        - the main problem is jumping to the end of the previous line when deleting
        - "CursorMovedI" is triggered for the 'next' (the one that has yet to be typed) character,
        so we need to examine 'previous' cursor positon
        - col - 1 and col - 2 is the product of the above statement and the fact that every line
        ends with " " (see speedtyper.helper.generate_sentence), there is no logical explanation,
        the problem was aligning 0-based and 1-based indexing
      ]]
    if col - 1 == #sentences[line] or col - 2 == #sentences[line] then
        if line < M.prev_line or col == M.prev_col then
            --[[ <bspace> will remove the current line and move the cursor to the beginning of the previous,
            so we need to restore the deleted line with 'o' (could be done with api functions) and re-add the virtual text ]]
            normal("o")
            normal("k$")
            api.nvim_buf_set_extmark(bufnr, ns_id, line, 0, {
                id = extm_ids[line + 1],
                virt_text = {
                    { sentences[line + 1], "Comment" },
                },
                virt_text_win_col = 0,
            })
        elseif line == 4 then
            -- move cursor to the beginning of the first line and generate new sentences after the final space in the last line
            normal("gg0")
            M.clear_extmarks(bufnr, extm_ids)
            return M.generate_extmarks(bufnr)
        else
            -- move cursor to the beginning of the next line after the final space in the previous line
            normal("j0")
        end
    end
    api.nvim_buf_set_extmark(bufnr, ns_id, line - 1, 0, {
        id = extm_ids[line],
        virt_text = {
            { string.sub(sentences[line], col), "Comment" },
        },
        virt_text_win_col = col - 1,
    })

    M.prev_line = line
    M.prev_col = col

    return extm_ids, sentences
end

---@param bufnr integer
---@param extm_ids integer[]
function M.clear_extmarks(bufnr, extm_ids)
    for _, id in pairs(extm_ids) do
        api.nvim_buf_del_extmark(bufnr, ns_id, id)
    end
end

---@param bufnr integer
function M.clear_text(bufnr)
    api.nvim_buf_set_lines(bufnr, 0, 5, false, { "", "", "", "", "" })
end

return M
