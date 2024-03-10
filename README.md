# `refactor.nvim`

A neovim plugin to refactor code.

The implementation is just a set of thin wrappers over a few basic vim
functions, but these expose a few convenient functions in a more approachable
manner, that help me get over my inertia.

The plugin contains the following functions:

- `lsp_rename_symbol()`: Replace the current symbol using the LSP.
- `text_replace_word()`: Replace the current word using `s///g`
- `text_replace_selection()`: Replace the current selection using `s///g`

## Installation and Usage

### `lazy.nvim`

Here is an example of how to use `refactor.nvim` with `lazy.nvim`, with
custom keybindings:

```lua
{
    "tiyashbasu/refactor.nvim",
    config = function()
        local refactor = require("refactor")

        vim.keymap.set("n", "<F2>", function()
            refactor.lsp_rename_symbol()
        end, {})

        vim.keymap.set("n", "<F3>", function()
            refactor.text_replace_word()
        end, {})


        vim.keymap.set("v", "<F3>", function()
            refactor.text_replace_selection()
        end, {})
    end,
}
```

I do not know any other neovim plugin manager, so this is it ¯\\\_(ツ)\_/¯
