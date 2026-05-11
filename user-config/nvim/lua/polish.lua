-- This will run last in the setup process.
-- This is just pure lua so anything that doesn't
-- fit in the normal config locations above can go here

-- Setup mappings
vim.keymap.set({'n', 'v', 'o'}, 'H', '^', {
  noremap = true,
  silent = true,
  desc = 'Move to beginning of line'
})

vim.keymap.set({'n', 'v', 'o'}, 'L', '$', {
  noremap = true,
  silent = true,
  desc = 'Move to end of line'
})

vim.keymap.set({'n', 'v', 'o'}, '<Leader>s', ":lua vim.ui.input({prompt = 'Save as: '}, function(input) if input then vim.cmd('saveas ' .. input) vim.cmd('bd #') end end)<CR>", {
  desc = 'Save as'
})

vim.keymap.set({'n', 'v', 'o'}, '<Leader>W', ':wa<CR>', {
  desc = 'Save all buffers'
})

-- Disable common
vim.keymap.set({'n', 'v', 'o'}, '^', '<Nop>', {noremap = true, silent = true})
vim.keymap.set({'n', 'v', 'o'}, '$', '<Nop>', {noremap = true, silent = true})
vim.keymap.set({'n', 'v', 'o'}, 'J', '<Nop>', {noremap = true, silent = true})

-- Change back cursor after close vim
vim.api.nvim_create_autocmd({"VimLeave", "VimSuspend"}, {
  pattern = "*",
  callback = function()
    vim.o.guicursor = "a:ver25-blinkon0"
  end,
})
