local cmp = require 'cmp'
local lspkind = require 'lspkind'
local luasnip = require 'luasnip'
local codeium = require 'codeium'
local sg = require 'sg'

luasnip.config.setup {}
codeium.setup {}
sg.setup {}

vim.opt.completeopt = { 'menu', 'menuone', 'noselect' }

cmp.setup {
  completion = { completeopt = 'menu,menuone,noinsert' },
  snippet = {
    expand = function(args)
      luasnip.lsp_expand(args.body)
    end,
  },
  formatting = {
    format = lspkind.cmp_format {
      with_text = true,
      maxwidth = 50,
      ellipsis_char = '...',
      menu = {
        -- nvim_lsp = '[LSP]',
        -- luasnip = '[Luasnip]',
        -- treesitter = '[Treesitter]',
        -- buffer = '[Buffer]',
        -- path = '[Path]',
        -- -- cmp_tabnine = "[TabNine]",
        codeium = '""[CODEIUM]',
        nvim_lsp = '[LSP]',
        cody = '[CODY]',
        cmp_tabnine = '[TABNINE]',
        nvim_lua = '[API]',
        nvim_lsp_signature_help = '[LSP]',
        luasnip = '[SNIP]',
        buffer = '[BUF]',
        path = '[PATH]',
        treesitter = '[TREE]',
      },
    },
  },
  -- For an understanding of why these mappings were
  -- chosen, you will need to read `:help ins-completion`
  --
  -- No, but seriously. Please read `:help ins-completion`, it is really good!
  mapping = cmp.mapping.preset.insert {
    -- Select the [n]ext item
    ['<C-n>'] = cmp.mapping.select_next_item(),
    -- Select the [p]revious item
    ['<C-p>'] = cmp.mapping.select_prev_item(),

    -- Scroll the documentation window [b]ack / [f]orward
    ['<C-b>'] = cmp.mapping.scroll_docs(-4),
    ['<C-f>'] = cmp.mapping.scroll_docs(4),

    -- Accept ([y]es) the completion.
    --  This will auto-import if your LSP supports it.
    --  This will expand snippets if the LSP sent a snippet.
    ['<C-y>'] = cmp.mapping.confirm { select = true },

    -- Manually trigger a completion from nvim-cmp.
    --  Generally you don't need this, because nvim-cmp will display
    --  completions whenever it has completion options available.
    ['<C-Space>'] = cmp.mapping.complete {},

    -- Think of <c-l> as moving to the right of your snippet expansion.
    --  So if you have a snippet that's like:
    --  function $name($args)
    --    $body
    --  end
    --
    -- <c-l> will move you to the right of each of the expansion locations.
    -- <c-h> is similar, except moving you backwards.
    ['<C-l>'] = cmp.mapping(function()
      if luasnip.expand_or_locally_jumpable() then
        luasnip.expand_or_jump()
      end
    end, { 'i', 's' }),
    ['<C-h>'] = cmp.mapping(function()
      if luasnip.locally_jumpable(-1) then
        luasnip.jump(-1)
      end
    end, { 'i', 's' }),

    ['<C-e>'] = cmp.mapping.abort(),
    ['<CR>'] = cmp.mapping.confirm {
      behavior = cmp.ConfirmBehavior.Insert,
      select = true,
    },
    ['<Tab>'] = cmp.mapping(function(fallback)
      if cmp.visible() then
        cmp.select_next_item()
      elseif require('luasnip').expand_or_jumpable() then
        vim.fn.feedkeys(vim.api.nvim_replace_termcodes('<Plug>luasnip-expand-or-jump', true, true, true), '')
      else
        fallback()
      end
    end, {
      'i',
      's',
    }),
    ['<S-Tab>'] = cmp.mapping(function(fallback)
      if cmp.visible() then
        cmp.select_prev_item()
      elseif require('luasnip').jumpable(-1) then
        vim.fn.feedkeys(vim.api.nvim_replace_termcodes('<Plug>luasnip-jump-prev', true, true, true), '')
      else
        fallback()
      end
    end, {
      'i',
      's',
    }),

    -- For more advanced Luasnip keymaps (e.g. selecting choice nodes, expansion) see:
    --    https://github.com/L3MON4D3/LuaSnip?tab=readme-ov-file#keymaps
  },
  sources = {
    { name = 'codeium' },
    { name = 'cody' },
    { name = 'nvim_lsp' },
    { name = 'luasnip' },
    { name = 'cmp_tabnine' },
    { name = 'nvim_lua' },
    { name = 'nvim_lsp_signature_help', keyword_length = 3 },
    { name = 'buffer' },
    { name = 'path' },
    { name = 'treesitter' },
  },
}
