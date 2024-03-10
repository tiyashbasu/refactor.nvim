local M = {}

-- Opens a floating window to display a prompt and get user input, and then calls a callback function with the input.
-- The callback function is called with the input as an argument.
--
-- @param prompt string: The prompt to display in the floating window.
-- @param initial_lines table: A table of strings, each representing a line of the initial text in the floating window.
-- @param on_confirm function: The callback function to call with the input.
-- @return nil
-- @example
-- open_floating_input("New symbol name:", "", vim.lsp.buf.rename)
function M.open_floating_input(prompt, initial_lines, on_confirm)
    -- Create a new buffer
    local buf = vim.api.nvim_create_buf(false, true)

    -- find the length of the longest line
    local max_line_length = 0
    for _, line in ipairs(initial_lines) do
        max_line_length = math.max(max_line_length, #line)
    end

    -- Set the initial text in the buffer
    vim.api.nvim_buf_set_lines(buf, 0, 0, false, initial_lines)

    -- Create a floating window with the buffer and the prompt.
    local width = math.min(80, math.max(#prompt, max_line_length) + 4)
    local config = {
        relative = "cursor",
        width = width,
        height = #initial_lines,
        row = 1,
        col = 0,
        style = "minimal",
        border = "rounded",
        title = prompt,
    }
    local win = vim.api.nvim_open_win(buf, true, config)

    -- Once in the window, move the cursor to the start, and start insert mode.
    vim.api.nvim_win_set_cursor(win, { 1, 0 })
    vim.api.nvim_command("startinsert")

    -- Create callback which will be called once enter key is pressed, inside
    -- the floating window.
    local function confirm_handler()
        local input_lines = vim.api.nvim_buf_get_lines(buf, 0, -2, false)
        vim.api.nvim_win_close(win, true)
        on_confirm(input_lines)
        vim.api.nvim_command("stopinsert")
    end

    -- Store the local function in the buffer's variables
    vim.api.nvim_buf_set_var(buf, "confirm_handler", confirm_handler)

    -- Set up a keymap for the enter key, once inside the floating window.
    vim.api.nvim_buf_set_keymap(
        buf,
        "i",
        "<CR>",
        "<cmd>lua vim.api.nvim_buf_call("
            .. buf
            .. ", function() vim.b.confirm_handler() end)<CR>",
        { nowait = true, noremap = true, silent = true }
    )

    -- Create callback which will be called once escape key is pressed, inside
    -- the floating window.
    local function escape_handler()
        vim.api.nvim_win_close(win, true)
        vim.api.nvim_command("stopinsert")
    end

    -- Store the local function in the buffer's variables
    vim.api.nvim_buf_set_var(buf, "escape_handler", escape_handler)

    -- set up keymaps for the escape key, once inside the floating window.
    local modes = { "i", "n", "v" }
    for _, mode in ipairs(modes) do
        vim.api.nvim_buf_set_keymap(
            buf,
            mode,
            "<ESC>",
            "<cmd>lua vim.api.nvim_buf_call("
                .. buf
                .. ", function() vim.b.escape_handler() end)<CR>",
            { nowait = true, noremap = true, silent = true }
        )
    end
end

return M
