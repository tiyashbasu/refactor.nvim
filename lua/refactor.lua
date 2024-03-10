local inputs = require("refactor.inputs")
local utils = require("refactor.utils")

local function escape(str)
    return vim.fn.escape(str, "/\\\"-")
end

local M = {}

-- Opens a prompt to replace the current word under the cursor with a new word.
function M.text_replace_word()
    -- get the current and replacement words
    local current_word = escape(vim.fn.expand("<cword>"))

    local function text_replace_word_handler(replacement)
        -- store the current cursor position
        local curser_pos = vim.api.nvim_win_get_cursor(0)

        -- get the current and replacement words
        local new_word = escape(replacement[1])

        -- do not replace unnecessarily
        if current_word == new_word then
            return
        end

        -- replace the word
        vim.cmd(":%s/" .. current_word .. "/" .. new_word .. "/g")

        -- move the cursor back to the original position
        vim.api.nvim_win_set_cursor(0, curser_pos)

        -- remove highlighting
        vim.cmd(":noh")
    end

    -- open a floating window to get the new word, and apply the replacement
    inputs.open_floating_input(
        "Replace with:",
        { current_word },
        text_replace_word_handler
    )
end

function M.text_replace_selection()
    local current_text = utils.text_get_selection()

    -- do not replace if the selection is empty
    if current_text == "" or current_text == " " then
        return
    end

    -- split the text into lines
    local current_lines = utils.split_into_lines(current_text)

    -- this function is invoked once for each line in the selection
    local function text_replace_selection_handler(replacement)
        -- store the current cursor position.
        local curser_pos = vim.api.nvim_win_get_cursor(0)

        for idx, current_line in ipairs(current_lines) do
            -- escape special characters
            local current_line_esc = escape(current_line)
            local new_line_esc = escape(replacement[idx])

            -- replace if there is a difference
            if current_line_esc ~= new_line_esc then
                vim.cmd(":%s/" .. current_line_esc .. "/" .. new_line_esc .. "/g")
            end
        end

        -- move the cursor back to the original position
        vim.api.nvim_win_set_cursor(0, curser_pos)

        -- remove highlighting
        vim.cmd(":noh")
    end

    -- open a floating window to get the new word, and apply the replacement
    inputs.open_floating_input(
        "Replace with:",
        current_lines,
        text_replace_selection_handler
    )
end

-- Opens a prompt to rename the current symbol under the cursor using vim's LSP.
function M.lsp_rename_symbol()
    local current_symbol = vim.fn.expand("<cword>")

    local function lsp_rename_symbol_handler(new_name)
        vim.lsp.buf.rename(new_name[1])
    end

    inputs.open_floating_input(
        "New name:",
        { current_symbol },
        lsp_rename_symbol_handler
    )
end

return M
