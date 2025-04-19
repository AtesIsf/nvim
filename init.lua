
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.loop.fs_stat(lazypath) then
  vim.fn.system({
    "git",
    "clone",
    "--filter=blob:none",
    "https://github.com/folke/lazy.nvim.git",
    "--branch=stable", -- latest stable release
    lazypath,
  })
end
vim.opt.rtp:prepend(lazypath)

require("lazy").setup({
  "neovim/nvim-lspconfig",
	"williamboman/mason.nvim",
	"williamboman/mason-lspconfig.nvim",
	"hrsh7th/nvim-cmp",
  "hrsh7th/cmp-nvim-lsp",
  "hrsh7th/cmp-buffer",
  "hrsh7th/cmp-path",
  "L3MON4D3/LuaSnip",
  "saadparwaiz1/cmp_luasnip",
	"nvim-treesitter/nvim-treesitter",
  {
    "nvim-telescope/telescope.nvim", branch = "0.1.x",
    dependencies = { "nvim-lua/plenary.nvim" }
  },
	{
    "windwp/nvim-autopairs",
    event = "InsertEnter",
    config = true
    -- use opts = {} for passing setup options
    -- this is equivalent to setup({}) function
	},
  "nvim-tree/nvim-web-devicons",
  "nvim-lualine/lualine.nvim",
  "sainnhe/gruvbox-material",
})

local builtin = require('telescope.builtin')
vim.keymap.set('n', '<leader>ff', builtin.find_files, {})
vim.keymap.set('n', '<leader>fg', builtin.live_grep, {})
vim.keymap.set('n', '<leader>fb', builtin.buffers, {})
vim.keymap.set('n', '<leader>fh', builtin.help_tags, {})

if vim.fn.has('termguicolors') == 1 then
  vim.opt.termguicolors = true
end

vim.opt.background = "dark"

vim.g.gruvbox_material_better_performance = 1
-- vim.g.gruvbox_material_foreground = "mix"
-- vim.g.gruvbox_material_foreground = "original"

require'nvim-treesitter.configs'.setup {
  auto_install = false,

  highlight = {
		ensure_installed = { "c", "python", "bash", "rust" },
		enable = true,
    -- Setting this to true will run `:h syntax` and tree-sitter at the same time.
    -- Set this to `true` if you depend on 'syntax' being enabled (like for indentation).
    -- Using this option may slow down your editor, and you may see some duplicate highlights.
    -- Instead of true it can also be a list of languages
    additional_vim_regex_highlighting = false,
  },
}

vim.cmd("colorscheme gruvbox-material")

require('lualine').setup()
options = { theme = 'gruvbox' }

require("mason").setup()
require("mason-lspconfig").setup({
  ensure_installed = { "clangd", "rust_analyzer", "pyright" }
})

-- Your general Neovim settings
vim.cmd [[
  set number
  set relativenumber
  set tabstop=2
  set shiftwidth=2
  set expandtab
  set softtabstop=-1
  set smartindent
  set encoding=utf-8
  set signcolumn=yes
  set mouse=
  set so=7
]]

-- LSP Client stuff
local on_attach = function(client, bufnr)
  local opts = { buffer = bufnr, silent = true }

  -- Keybindings
  vim.keymap.set('n', 'gD', vim.lsp.buf.declaration, opts)
  vim.keymap.set('n', 'gd', vim.lsp.buf.definition, opts)
  vim.keymap.set('n', 'K', function()
  vim.lsp.buf.hover({
    border = "rounded",
  })
  end, opts)
  vim.keymap.set('n', 'gi', vim.lsp.buf.implementation, opts)
  vim.keymap.set('n', '<C-k>', vim.lsp.buf.signature_help, opts)
  vim.keymap.set('n', '<leader>rn', vim.lsp.buf.rename, opts)
  vim.keymap.set('n', 'gr', vim.lsp.buf.references, opts)
  vim.keymap.set('n', '<leader>ca', vim.lsp.buf.code_action, opts)
end

-- Setup LSP servers
require'lspconfig'.clangd.setup({ on_attach = on_attach })
require'lspconfig'.rust_analyzer.setup({ on_attach = on_attach })
require'lspconfig'.pyright.setup({ on_attach = on_attach })
require'lspconfig'.gopls.setup({ on_attach = on_attach })

-- Show diagnostics in floating window
vim.keymap.set('n', '<leader>d', function()
  vim.diagnostic.open_float({ 
    scope = "cursor",
    border = "rounded",
    focusable = false,
  })
end, { desc = "Show diagnostic message" })

-- Autocompletion setup
local cmp = require('cmp')
local luasnip = require('luasnip')

cmp.setup({
  snippet = {
    expand = function(args)
      luasnip.lsp_expand(args.body)
    end,
  },
  mapping = cmp.mapping.preset.insert({
    ['<C-d>'] = cmp.mapping.scroll_docs(-4),
    ['<C-f>'] = cmp.mapping.scroll_docs(4),
    ['<C-Space>'] = cmp.mapping.complete(),
    ['<CR>'] = cmp.mapping.confirm({
      behavior = cmp.ConfirmBehavior.Replace,
      select = true,
    }),
    ['<Tab>'] = cmp.mapping(function(fallback)
      if cmp.visible() then
        cmp.select_next_item()
      elseif luasnip.expand_or_jumpable() then
        luasnip.expand_or_jump()
      else
        fallback()
      end
    end, { 'i', 's' }),
    ['<S-Tab>'] = cmp.mapping(function(fallback)
      if cmp.visible() then
        cmp.select_prev_item()
      elseif luasnip.jumpable(-1) then
        luasnip.jump(-1)
      else
        fallback()
      end
    end, { 'i', 's' }),
  }),
  sources = {
    { name = 'nvim_lsp' },
    { name = 'luasnip' },
    { name = 'buffer' },
    { name = 'path' },
  },
})

