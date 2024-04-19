require('conform').setup {
  formatters_by_ft = {
    lua = { 'stylua' },
    nix = { 'alejandra' },
    -- Conform will run multiple formatters sequentially
    -- python = { 'isort', 'black' },
    -- Use a sub-list to run only the first available formatter
    -- javascript = { { 'prettierd', 'prettier' } },
  },
  format_on_save = function(bufnr)
    -- Disable "format_on_save lsp_fallback" for languages that don't
    -- have a well standardized coding style. You can add additional
    -- languages here or re-enable it for the disabled ones.
    -- local disable_filetypes = { c = true, cpp = true }
    return {
      timeout_ms = 500,
      lsp_fallback = true,
    }
  end,
}

vim.keymap.set('n', '<leader>f', function()
  require('conform').format { async = true, lsp_fallback = true }
end, { desc = '[F]ormat buffer' })

