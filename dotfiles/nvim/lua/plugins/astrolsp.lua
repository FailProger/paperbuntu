-- AstroLSP allows you to customize the features in AstroNvim's LSP configuration engine
-- Configuration documentation can be found with `:h astrolsp`
-- NOTE: We highly recommend setting up the Lua Language Server (`:LspInstall lua_ls`)
--       as this provides autocomplete and documentation while editing

return {
  "AstroNvim/astrolsp",
  opts = {
    -- mappings to be set up on attaching of a language server
    mappings = {
      n = {
        ["<C-k>"] = { vim.lsp.buf.signature_help, desc = "Show signature help" },
      },
      i = {
        ["<C-k>"] = { vim.lsp.buf.signature_help, desc = "Show signature help" },
      },
    },
  },
}
