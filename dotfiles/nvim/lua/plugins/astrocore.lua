-- AstroCore provides a central place to modify mappings, vim options, autocommands, and more!
-- Configuration documentation can be found with `:h astrocore`
-- NOTE: We highly recommend setting up the Lua Language Server (`:LspInstall lua_ls`)
--       as this provides autocomplete and documentation while editing

return {
  "AstroNvim/astrocore",
  opts = {
    -- Configure auto commands
    autocmds = {
      -- Restore beam cursor after close nvim
      cursor_restore = {
        {
          event = { "VimLeave", "VimSuspend" },
          pattern = "*",
          desc = "Change back cursor after close vim",
          callback = function()
            vim.o.guicursor = "a:ver25-blinkon0"
          end,
        },
      },
    },
    -- NOTE: keycodes follow the casing in the vimdocs. For example, `<Leader>` must be capitalized
    mappings = {
      -- Normal mode
      n = {
        -- Line movement
        H = { "^", desc = "Move to beginning of line" },
        L = { "$", desc = "Move to end of line" },
        
        -- File saving
        ["<Leader>s"] = { ":lua vim.ui.input({prompt = 'Save as: '}, function(input) if input then vim.cmd('saveas ' .. input) vim.cmd('bd #') end end)<CR>", desc = "Save as" },
        ["<Leader>W"] = { ":wa<CR>", desc = "Save all buffers" },

        -- Disable default binds
        ["^"] = false,
        ["$"] = false,
        ["J"] = false,
      },
      -- Visual mode
      v = {
        -- Line movement
        H = { "^", desc = "Move to beginning of line" },
        L = { "$", desc = "Move to end of line" },
      },
      -- Operator-pending mode
      o = {
        -- Line movement
        H = { "^", desc = "Move to beginning of line" },
        L = { "$", desc = "Move to end of line" },
      },
    },
  },
}
