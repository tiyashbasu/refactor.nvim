local M = {}

-- Split the input text into lines.
--
-- @param multiline_text string: The multiline text to split.
-- @return table: A table of strings, each representing a line of the input text.
function M.split_into_lines(multiline_text)
    local lines = {}
    for line in multiline_text:gmatch("([^\n]*)\n?") do
        table.insert(lines, line)
    end

    return lines
end

-- Returns the current visual selection.
function M.text_get_selection()
    -- start normal mode, so that the visual selection is available
    vim.cmd("normal! \"xy")
    return vim.fn.getreg("x")
end

return M
