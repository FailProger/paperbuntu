-- Customize Mason

return {
  -- use mason-tool-installer for automatically installing Mason packages
  {
    "WhoIsSethDaniel/mason-tool-installer.nvim",
    opts = {
      ensure_installed = {
        -- install language servers
        "css-lsp",
        "emmet-language-server",
        "html-lsp",
        "python-lsp-server",
        "typescript-language-server",
      },
    },
  },
}
