return require('lazy').setup({
    {
        'MeanderingProgrammer/render-markdown.nvim',
        opts = {},
        dependencies = { 'nvim-treesitter/nvim-treesitter', 'echasnovski/mini.icons' }, -- if you use the mini.nvim suite
    },
    {
        "epwalsh/obsidian.nvim",
        version = "*",
        lazy = true,
        ft = "markdown",
        dependencies = {
            "nvim-lua/plenary.nvim",
            "hrsh7th/nvim-cmp",
        }
    },
    {
        'nvim-telescope/telescope.nvim',
        tag = '0.1.8',
        dependencies = { 'nvim-lua/plenary.nvim' }
    },
    {
        'nvim-telescope/telescope-media-files.nvim',
        dependencies = { 'nvim-lua/plenary.nvim', 'nvim-lua/popup.nvim', 'nvim-telescope/telescope.nvim' },
        -- config = function()
        --     require("telescope").load_extension("media_files")
        -- end
    },
    {
        'stevearc/oil.nvim',
        opts = {},
        -- Optional dependencies
        dependencies = { { "echasnovski/mini.icons", opts = {} } },
    },
    {
        "kylechui/nvim-surround",
        version = "*", -- Use for stability; omit to use `main` branch for the latest features
        event = "VeryLazy",
        config = function()
            require("nvim-surround").setup({
                -- Configuration here, or leave empty to use defaults
            })
        end
    },

    { 'nvim-treesitter/nvim-treesitter', build = ':TSUpdate' },

    --  'nvim-treesitter/playground',
    'ThePrimeagen/harpoon',
    'mbbill/undotree',
    'tpope/vim-fugitive',
    'simrat39/rust-tools.nvim',

    {
        'VonHeikemen/lsp-zero.nvim',
        branch = 'v2.x',
        dependencies = {
            -- LSP Support
            { 'neovim/nvim-lspconfig' },             -- Required
            { 'williamboman/mason.nvim' },           -- Optional
            { 'williamboman/mason-lspconfig.nvim' }, -- Optional

            -- Autocompletion
            { 'hrsh7th/nvim-cmp' },     -- Required
            { 'hrsh7th/cmp-nvim-lsp' }, -- Required
            {
                'L3MON4D3/LuaSnip',
                version = "v2.*",
                build = "make install_jsregexp"
            }, -- Required
        }
    },



    {
        "iamcco/markdown-preview.nvim",
        build = function() vim.fn["mkdp#util#install"]() end,
    },

    'vim-pandoc/vim-pandoc',

    'vim-pandoc/vim-pandoc-syntax',

    'christoomey/vim-tmux-navigator',

    {
        "echasnovski/mini.comment",
        event = "VeryLazy",
        dependencies = { 'JoosepAlviste/nvim-ts-context-commentstring' },
        opts = {
            options = {
                custom_commentstring = function()
                    return require("ts_context_commentstring.internal").calculate_commentstring() or vim.bo
                        .commentstring
                end,
            },
        },
    },

    -- -- Error Reporting
    -- {
    --     'folke/trouble.nvim',
    --     opts = {},
    --     cmd = "Trouble",
    --     keys = {
    --         {
    --             "<leader>tt",
    --             "<cmd>Trouble diagnostics toggle<cr>",
    --             desc = "Diagnostics (Trouble)"
    --         }
    --     }
    -- },

    -- ColorScheme
    'folke/tokyonight.nvim',

    'nmac427/guess-indent.nvim',

    'stevearc/conform.nvim',

    -- Debugger
    {
        'mfussenegger/nvim-dap',
        dependencies = {
            "rcarriga/nvim-dap-ui",
            "theHamsta/nvim-dap-virtual-text",
            "nvim-neotest/nvim-nio",
            "williamboman/mason.nvim",
            "jay-babu/mason-nvim-dap.nvim",
        },
    }
})
