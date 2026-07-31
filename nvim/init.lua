-- Leader key (must be before lazy)
vim.g.mapleader = " "
vim.g.maplocalleader = " "

-- Basic options
vim.opt.number = true
vim.opt.relativenumber = true
vim.opt.expandtab = true
vim.opt.shiftwidth = 4
vim.opt.tabstop = 4
vim.opt.softtabstop = 4
vim.opt.smartindent = true
vim.opt.wrap = false
vim.opt.cursorline = true
vim.opt.signcolumn = "yes"
vim.opt.termguicolors = true
vim.opt.scrolloff = 8
vim.opt.sidescrolloff = 8
vim.opt.ignorecase = true
vim.opt.smartcase = true
vim.opt.splitbelow = true
vim.opt.splitright = true
vim.opt.undofile = true
vim.opt.updatetime = 250
vim.opt.clipboard = "unnamedplus"
vim.opt.completeopt = { "menu", "menuone", "noselect" }

-- Bootstrap lazy.nvim
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.loop.fs_stat(lazypath) then
  vim.fn.system({
    "git", "clone", "--filter=blob:none",
    "https://github.com/folke/lazy.nvim.git",
    "--branch=stable", lazypath,
  })
end
vim.opt.rtp:prepend(lazypath)

require("lazy").setup({
  -- Colorscheme
  {
    "nickkadutskyi/jb.nvim",
    priority = 1000,
    config = function()
      require("jb").setup({
        theme = "dark",
      })
      vim.cmd.colorscheme("jb")
    end,
  },

  -- Treesitter
  {
    "nvim-treesitter/nvim-treesitter",
    branch = "master",
    build = ":TSUpdate",
    config = function()
      require("nvim-treesitter.configs").setup({
        ensure_installed = { "java", "groovy", "kotlin", "rust", "toml", "xml", "json", "yaml", "lua", "bash", "markdown" },
        auto_install = true,
        highlight = { enable = true },
        indent = { enable = true },
        incremental_selection = {
          enable = true,
          keymaps = {
            init_selection = "<C-space>",
            node_incremental = "<C-space>",
            scope_incremental = false,
            node_decremental = "<bs>",
          },
        },
      })
    end,
  },

  -- LSP (using vim.lsp.config for Neovim 0.11+)
  {
    "williamboman/mason.nvim",
    config = function()
      require("mason").setup()
    end,
  },
  {
    "williamboman/mason-lspconfig.nvim",
    dependencies = { "williamboman/mason.nvim" },
    config = function()
      require("mason-lspconfig").setup({
        ensure_installed = { "jdtls", "lua_ls", "gradle_ls" },
        -- rust_analyzer is intentionally NOT here: rustaceanvim manages its
        -- own rust-analyzer client/config, and we're using the rustup-managed
        -- rust-analyzer (not Mason's) so it stays version-matched to the
        -- active toolchain.
        handlers = {
          -- Don't auto-configure jdtls; we handle it via nvim-jdtls
          jdtls = function() end,
        },
      })
    end,
  },
  {
    "neovim/nvim-lspconfig",
    dependencies = {
      "williamboman/mason.nvim",
      "williamboman/mason-lspconfig.nvim",
    },
    config = function()
      -- LSP keymaps on attach
      vim.api.nvim_create_autocmd("LspAttach", {
        group = vim.api.nvim_create_augroup("UserLspConfig", {}),
        callback = function(ev)
          local opts = { buffer = ev.buf }
          vim.keymap.set("n", "gd", vim.lsp.buf.definition, opts)
          vim.keymap.set("n", "gD", vim.lsp.buf.declaration, opts)
          vim.keymap.set("n", "gi", vim.lsp.buf.implementation, opts)
          vim.keymap.set("n", "gr", vim.lsp.buf.references, opts)
          vim.keymap.set("n", "K", vim.lsp.buf.hover, opts)
          vim.keymap.set("n", "<leader>ca", vim.lsp.buf.code_action, opts)
          vim.keymap.set("n", "<leader>rn", vim.lsp.buf.rename, opts)
          vim.keymap.set("n", "<leader>f", function() vim.lsp.buf.format({ async = true }) end, opts)
          vim.keymap.set("n", "[d", vim.diagnostic.goto_prev, opts)
          vim.keymap.set("n", "]d", vim.diagnostic.goto_next, opts)
          vim.keymap.set("n", "<leader>d", vim.diagnostic.open_float, opts)

          -- Java-specific keymaps (test runner & debug via jdtls)
          if ev.data and vim.lsp.get_client_by_id(ev.data.client_id).name == "jdtls" then
            -- Run tests
            vim.keymap.set("n", "<leader>tm", function() require("jdtls").test_nearest_method() end,
              { buffer = ev.buf, desc = "Run test method" })
            vim.keymap.set("n", "<leader>tc", function() require("jdtls").test_class() end,
              { buffer = ev.buf, desc = "Run test class" })
            -- Debug tests
            vim.keymap.set("n", "<leader>dT", function() require("jdtls.dap").test_nearest_method() end,
              { buffer = ev.buf, desc = "Debug test method" })
            vim.keymap.set("n", "<leader>dC", function() require("jdtls.dap").test_class() end,
              { buffer = ev.buf, desc = "Debug test class" })
            -- Debug main class
            vim.keymap.set("n", "<leader>dm", function()
              require("jdtls.dap").setup_dap_main_class_configs()
              vim.defer_fn(function() require("dap").continue() end, 1000)
            end, { buffer = ev.buf, desc = "Debug main class" })
            -- Attach to remote JVM (e.g., Spring Boot with debug port)
            vim.keymap.set("n", "<leader>da", function()
              require("dap").run({
                type = "java",
                request = "attach",
                name = "Attach to remote JVM",
                hostName = "localhost",
                port = 5005,
              })
            end, { buffer = ev.buf, desc = "Attach debugger (port 5005)" })
            -- Debug with args (prompts for input)
            vim.keymap.set("n", "<leader>dA", function()
              local args = vim.fn.input("Program args: ")
              local vmArgs = vim.fn.input("VM args: ")
              require("jdtls.dap").setup_dap_main_class_configs()
              vim.defer_fn(function()
                local dap = require("dap")
                -- Find the last java config and add args
                local configs = dap.configurations.java
                if configs and #configs > 0 then
                  local config = vim.deepcopy(configs[#configs])
                  config.args = args ~= "" and args or nil
                  config.vmArgs = vmArgs ~= "" and vmArgs or nil
                  dap.run(config)
                end
              end, 1000)
            end, { buffer = ev.buf, desc = "Debug with args (prompted)" })
          end
        end,
      })

      -- Lua LS (for neovim config editing)
      vim.lsp.config("lua_ls", {
        settings = {
          Lua = {
            runtime = { version = "LuaJIT" },
            diagnostics = { globals = { "vim" } },
            workspace = { library = vim.api.nvim_get_runtime_file("", true), checkThirdParty = false },
            telemetry = { enable = false },
          },
        },
      })
      vim.lsp.enable("lua_ls")

      -- Gradle LS
      vim.lsp.config("gradle_ls", {})
      vim.lsp.enable("gradle_ls")
    end,
  },

  -- Java-specific LSP (nvim-jdtls for enhanced Java support)
  {
    "mfussenegger/nvim-jdtls",
    ft = "java",
    config = function()
      local mason_registry = require("mason-registry")
      local jdtls_pkg = mason_registry.get_package("jdtls")
      local jdtls_path = jdtls_pkg:get_install_path()
      local lombok_path = jdtls_path .. "/lombok.jar"

      -- Collect java-debug and java-test bundles for DAP support
      local bundles = {}
      local java_debug_path = mason_registry.get_package("java-debug-adapter"):get_install_path()
      vim.list_extend(bundles, vim.split(
        vim.fn.glob(java_debug_path .. "/extension/server/com.microsoft.java.debug.plugin-*.jar"), "\n"
      ))
      local java_test_path = mason_registry.get_package("java-test"):get_install_path()
      vim.list_extend(bundles, vim.split(
        vim.fn.glob(java_test_path .. "/extension/server/*.jar"), "\n"
      ))

      -- Override the auto-discovered jdtls config with our settings (including Lombok)
      vim.lsp.config("jdtls", {
        cmd = {
          jdtls_path .. "/bin/jdtls",
          "--java-executable", vim.fn.expand("~/.sdkman/candidates/java/21.0.8-tem/bin/java"),
          "--jvm-arg=-javaagent:" .. lombok_path,
          "--jvm-arg=-Xmx2g",
        },
        settings = {
          java = {
            signatureHelp = { enabled = true },
            contentProvider = { preferred = "fernflower" },
            completion = {
              favoriteStaticMembers = {
                "org.junit.jupiter.api.Assertions.*",
                "org.mockito.Mockito.*",
                "org.mockito.ArgumentMatchers.*",
                "org.assertj.core.api.Assertions.*",
                "java.util.Objects.requireNonNull",
                "java.util.Objects.requireNonNullElse",
              },
              filteredTypes = { "com.sun.*", "io.micrometer.shaded.*", "java.awt.*", "jdk.*" },
              importOrder = { "java", "javax", "com", "org" },
            },
            sources = {
              organizeImports = { starThreshold = 9999, staticStarThreshold = 9999 },
            },
            codeGeneration = {
              toString = { template = "${object.className}{${member.name()}=${member.value}, ${otherMembers}}" },
              useBlocks = true,
            },
            configuration = {
              runtimes = {
                { name = "JavaSE-11", path = vim.fn.expand("~/.sdkman/candidates/java/11.0.28-zulu") },
                { name = "JavaSE-17", path = vim.fn.expand("~/.sdkman/candidates/java/17.0.16-amzn") },
                { name = "JavaSE-21", path = vim.fn.expand("~/.sdkman/candidates/java/21.0.8-tem") },
              },
            },
          },
        },
        init_options = {
          bundles = bundles,
        },
      })
    end,
  },

  -- Debug Adapter Protocol
  {
    "mfussenegger/nvim-dap",
    dependencies = {
      "rcarriga/nvim-dap-ui",
      "nvim-neotest/nvim-nio",
    },
    keys = {
      { "<leader>db", function() require("dap").toggle_breakpoint() end, desc = "Toggle breakpoint" },
      { "<leader>dB", function() require("dap").set_breakpoint(vim.fn.input("Condition: ")) end, desc = "Conditional breakpoint" },
      { "<leader>dc", function() require("dap").continue() end, desc = "Continue/Start" },
      { "<leader>do", function() require("dap").step_over() end, desc = "Step over" },
      { "<leader>di", function() require("dap").step_into() end, desc = "Step into" },
      { "<leader>dO", function() require("dap").step_out() end, desc = "Step out" },
      { "<leader>dr", function() require("dap").repl.open() end, desc = "Open REPL" },
      { "<leader>dl", function() require("dap").run_last() end, desc = "Run last" },
      { "<leader>dt", function() require("dap").terminate() end, desc = "Terminate" },
      { "<leader>du", function() require("dapui").toggle() end, desc = "Toggle DAP UI" },
      { "<F5>", function() require("dap").continue() end, desc = "Continue/Start" },
      { "<F10>", function() require("dap").step_over() end, desc = "Step over" },
      { "<F11>", function() require("dap").step_into() end, desc = "Step into" },
      { "<F12>", function() require("dap").step_out() end, desc = "Step out" },
    },
    config = function()
      local dap = require("dap")
      local dapui = require("dapui")

      dapui.setup()

      -- Load .vscode/launch.json if present
      require("dap.ext.vscode").load_launchjs(nil, { java = { "java" } })

      -- Auto open/close DAP UI
      dap.listeners.after.event_initialized["dapui_config"] = function() dapui.open() end
      dap.listeners.before.event_terminated["dapui_config"] = function() dapui.close() end
      dap.listeners.before.event_exited["dapui_config"] = function() dapui.close() end

      -- Breakpoint signs
      vim.fn.sign_define("DapBreakpoint", { text = "●", texthl = "DiagnosticError" })
      vim.fn.sign_define("DapBreakpointCondition", { text = "◆", texthl = "DiagnosticWarn" })
      vim.fn.sign_define("DapStopped", { text = "▶", texthl = "DiagnosticOk", linehl = "DapStoppedLine" })
    end,
  },

  -- Java test runner and debug (uses nvim-jdtls + nvim-dap)
  {
    "rcasia/neotest-java",
    ft = "java",
    dependencies = {
      "nvim-neotest/neotest",
      "nvim-treesitter/nvim-treesitter",
    },
  },

  -- Rust-specific LSP/DAP/runnables (uses rustup-managed rust-analyzer +
  -- Mason-managed codelldb, wired into the same nvim-dap set up for Java)
  {
    "mrcjkb/rustaceanvim",
    version = "^6",
    lazy = false, -- rustaceanvim sets itself up on FileType rust internally
    ft = { "rust" },
    dependencies = { "mfussenegger/nvim-dap" },
    config = function()
      local mason_registry = require("mason-registry")

      -- Ensure codelldb is installed via Mason (same pattern as java-debug-adapter)
      if not mason_registry.is_installed("codelldb") then
        vim.notify("Installing codelldb via Mason...", vim.log.levels.INFO)
        mason_registry.get_package("codelldb"):install()
      end

      local codelldb_path = mason_registry.get_package("codelldb"):get_install_path()
      local codelldb_bin = codelldb_path .. "/extension/adapter/codelldb"
      local liblldb_path = codelldb_path .. "/extension/lldb/lib/liblldb.dylib"

      vim.g.rustaceanvim = {
        tools = {
          hover_actions = { auto_focus = true },
        },
        server = {
          -- Use the rustup-managed rust-analyzer so it stays version-matched
          -- to whatever toolchain `rustup default` points at.
          cmd = function()
            return { vim.fn.expand("~/.cargo/bin/rust-analyzer") }
          end,
          default_settings = {
            ["rust-analyzer"] = {
              cargo = { allFeatures = true, loadOutDirsFromCheck = true, runBuildScripts = true },
              checkOnSave = true,
              check = { command = "clippy" },
              procMacro = { enable = true },
            },
          },
          on_attach = function(_, bufnr)
            local opts = { buffer = bufnr }
            vim.keymap.set("n", "<leader>tm", function() vim.cmd.RustLsp("testables") end,
              vim.tbl_extend("force", opts, { desc = "Run test (rustaceanvim)" }))
            vim.keymap.set("n", "<leader>dm", function() vim.cmd.RustLsp({ "debuggables" }) end,
              vim.tbl_extend("force", opts, { desc = "Debug runnable (rustaceanvim)" }))
            vim.keymap.set("n", "<leader>dT", function() vim.cmd.RustLsp({ "debuggables", "last" }) end,
              vim.tbl_extend("force", opts, { desc = "Debug last runnable" }))
            vim.keymap.set("n", "<leader>ca", function() vim.cmd.RustLsp("codeAction") end,
              vim.tbl_extend("force", opts, { desc = "Code action (rust-analyzer grouped)" }))
            vim.keymap.set("n", "K", function() vim.cmd.RustLsp({ "hover", "actions" }) end,
              vim.tbl_extend("force", opts, { desc = "Hover actions" }))
            vim.keymap.set("n", "<leader>rM", function() vim.cmd.RustLsp("expandMacro") end,
              vim.tbl_extend("force", opts, { desc = "Expand macro" }))
          end,
        },
        dap = {
          adapter = require("rustaceanvim.config").get_codelldb_adapter(codelldb_bin, liblldb_path),
        },
      }
    end,
  },

  -- Cargo.toml dependency management (versions, completion, update checks)
  {
    "saecki/crates.nvim",
    event = { "BufRead Cargo.toml" },
    dependencies = { "hrsh7th/nvim-cmp" },
    config = function()
      require("crates").setup({
        completion = {
          cmp = { enabled = true },
        },
      })

      vim.api.nvim_create_autocmd("FileType", {
        pattern = "toml",
        callback = function(ev)
          if vim.fn.expand("%:t") ~= "Cargo.toml" then
            return
          end
          local crates = require("crates")
          local opts = { buffer = ev.buf }
          vim.keymap.set("n", "<leader>ct", crates.toggle, vim.tbl_extend("force", opts, { desc = "Crates: toggle info" }))
          vim.keymap.set("n", "<leader>cr", crates.reload, vim.tbl_extend("force", opts, { desc = "Crates: reload" }))
          vim.keymap.set("n", "<leader>cv", crates.show_versions_popup, vim.tbl_extend("force", opts, { desc = "Crates: show versions" }))
          vim.keymap.set("n", "<leader>cf", crates.show_features_popup, vim.tbl_extend("force", opts, { desc = "Crates: show features" }))
          vim.keymap.set("n", "<leader>cu", crates.update_crate, vim.tbl_extend("force", opts, { desc = "Crates: update crate" }))
          vim.keymap.set("n", "<leader>cU", crates.upgrade_crate, vim.tbl_extend("force", opts, { desc = "Crates: upgrade crate" }))
          vim.keymap.set("n", "<leader>cA", crates.upgrade_all_crates, vim.tbl_extend("force", opts, { desc = "Crates: upgrade all" }))
        end,
      })
    end,
  },

  -- Completion
  {
    "hrsh7th/nvim-cmp",
    event = "InsertEnter",
    dependencies = {
      "hrsh7th/cmp-nvim-lsp",
      "hrsh7th/cmp-buffer",
      "hrsh7th/cmp-path",
      "L3MON4D3/LuaSnip",
      "saadparwaiz1/cmp_luasnip",
      "rafamadriz/friendly-snippets",
    },
    config = function()
      local cmp = require("cmp")
      local luasnip = require("luasnip")
      require("luasnip.loaders.from_vscode").lazy_load()

      cmp.setup({
        snippet = {
          expand = function(args) luasnip.lsp_expand(args.body) end,
        },
        mapping = cmp.mapping.preset.insert({
          ["<C-n>"] = cmp.mapping.select_next_item(),
          ["<C-p>"] = cmp.mapping.select_prev_item(),
          ["<C-b>"] = cmp.mapping.scroll_docs(-4),
          ["<C-f>"] = cmp.mapping.scroll_docs(4),
          ["<C-Space>"] = cmp.mapping.complete(),
          ["<C-e>"] = cmp.mapping.abort(),
          ["<CR>"] = cmp.mapping.confirm({ select = true }),
          ["<Tab>"] = cmp.mapping(function(fallback)
            if cmp.visible() then
              cmp.select_next_item()
            elseif luasnip.expand_or_jumpable() then
              luasnip.expand_or_jump()
            else
              fallback()
            end
          end, { "i", "s" }),
          ["<S-Tab>"] = cmp.mapping(function(fallback)
            if cmp.visible() then
              cmp.select_prev_item()
            elseif luasnip.jumpable(-1) then
              luasnip.jump(-1)
            else
              fallback()
            end
          end, { "i", "s" }),
        }),
        sources = cmp.config.sources({
          { name = "nvim_lsp" },
          { name = "luasnip" },
        }, {
          { name = "buffer" },
          { name = "path" },
        }),
      })
    end,
  },

  -- Telescope (fuzzy finder)
  {
    "nvim-telescope/telescope.nvim",
    branch = "0.1.x",
    dependencies = {
      "nvim-lua/plenary.nvim",
      { "nvim-telescope/telescope-fzf-native.nvim", build = "make" },
    },
    config = function()
      local telescope = require("telescope")
      telescope.setup({
        defaults = {
          file_ignore_patterns = { "%.class", "build/", "%.gradle/", "node_modules/", ".git/" },
        },
      })
      telescope.load_extension("fzf")

      local builtin = require("telescope.builtin")
      vim.keymap.set("n", "<leader>ff", builtin.find_files, { desc = "Find files" })
      vim.keymap.set("n", "<leader>fg", builtin.live_grep, { desc = "Live grep" })
      vim.keymap.set("n", "<leader>fb", builtin.buffers, { desc = "Buffers" })
      vim.keymap.set("n", "<leader>fh", builtin.help_tags, { desc = "Help" })
      vim.keymap.set("n", "<leader>fs", builtin.lsp_document_symbols, { desc = "Document symbols" })
      vim.keymap.set("n", "<leader>fw", builtin.lsp_workspace_symbols, { desc = "Workspace symbols" })
      vim.keymap.set("n", "<leader>fd", builtin.diagnostics, { desc = "Diagnostics" })
      vim.keymap.set("n", "<leader>fr", builtin.oldfiles, { desc = "Recent files" })
    end,
  },

  -- File explorer
  {
    "nvim-neo-tree/neo-tree.nvim",
    branch = "v3.x",
    dependencies = {
      "nvim-lua/plenary.nvim",
      "nvim-tree/nvim-web-devicons",
      "MunifTanjim/nui.nvim",
    },
    config = function()
      require("neo-tree").setup({
        filesystem = {
          filtered_items = {
            hide_dotfiles = false,
            hide_by_name = { ".git", "build", ".gradle", "node_modules" },
          },
        },
      })
      vim.keymap.set("n", "<leader>e", ":Neotree toggle<CR>", { desc = "Toggle file explorer" })
    end,
  },

  -- Git
  {
    "lewis6991/gitsigns.nvim",
    config = function()
      require("gitsigns").setup({
        signs = {
          add = { text = "│" },
          change = { text = "│" },
          delete = { text = "_" },
          topdelete = { text = "‾" },
          changedelete = { text = "~" },
        },
        on_attach = function(bufnr)
          local gs = package.loaded.gitsigns
          local opts = { buffer = bufnr }
          vim.keymap.set("n", "]c", function() gs.nav_hunk("next") end, opts)
          vim.keymap.set("n", "[c", function() gs.nav_hunk("prev") end, opts)
          vim.keymap.set("n", "<leader>hs", gs.stage_hunk, opts)
          vim.keymap.set("n", "<leader>hr", gs.reset_hunk, opts)
          vim.keymap.set("n", "<leader>hp", gs.preview_hunk, opts)
          vim.keymap.set("n", "<leader>hb", function() gs.blame_line({ full = true }) end, opts)
          vim.keymap.set("n", "<leader>hB", gs.toggle_current_line_blame, opts)
        end,
      })
    end,
  },

  -- Status line
  {
    "nvim-tree/nvim-web-devicons",
    opts = {
      override = {
        java = { icon = "\u{e66d}", color = "#CC3E44", cterm_color = "167", name = "Java" },
      },
    },
  },

  {
    "nvim-lualine/lualine.nvim",
    dependencies = { "nvim-tree/nvim-web-devicons" },
    config = function()
      require("lualine").setup({
        options = { theme = "auto" },
        sections = {
          lualine_c = { { "filename", path = 1 } },
        },
      })
    end,
  },

  -- Autopairs
  {
    "windwp/nvim-autopairs",
    event = "InsertEnter",
    config = function()
      require("nvim-autopairs").setup()
    end,
  },

  -- Comment toggling
  {
    "numToStr/Comment.nvim",
    config = function()
      require("Comment").setup()
    end,
  },

  -- Indent guides
  {
    "lukas-reineke/indent-blankline.nvim",
    main = "ibl",
    config = function()
      require("ibl").setup()
    end,
  },

  -- Which-key (shows keybinding hints)
  {
    "folke/which-key.nvim",
    event = "VeryLazy",
    config = function()
      require("which-key").setup()
    end,
  },

  -- Database client
  {
    "kristijanhusak/vim-dadbod-ui",
    dependencies = {
      { "tpope/vim-dadbod", lazy = true },
      { "kristijanhusak/vim-dadbod-completion", ft = { "sql", "mysql", "plsql" }, lazy = true },
    },
    cmd = { "DBUI", "DBUIToggle", "DBUIAddConnection", "DBUIFindBuffer" },
    keys = {
      { "<leader>Dt", ":DBUIToggle<CR>", desc = "Toggle DB UI" },
      { "<leader>Da", ":DBUIAddConnection<CR>", desc = "Add DB connection" },
      { "<leader>Df", ":DBUIFindBuffer<CR>", desc = "Find DB buffer" },
    },
    init = function()
      vim.g.db_ui_use_nerd_fonts = 1
      vim.g.db_ui_show_database_icon = 1
      vim.g.db_ui_force_echo_notifications = 1
      vim.g.db_ui_winwidth = 40
      -- Explicit (matches the plugin default) so connections.json location
      -- never silently depends on an implicit default.
      vim.g.db_ui_save_location = vim.fn.expand("~/.local/share/db_ui")

      -- Auto-completion for SQL buffers
      vim.api.nvim_create_autocmd("FileType", {
        pattern = { "sql", "mysql", "plsql" },
        callback = function()
          require("cmp").setup.buffer({
            sources = {
              { name = "vim-dadbod-completion" },
              { name = "buffer" },
            },
          })
        end,
      })

      -- dbout result buffers start with the results collapsed into a single
      -- fold (see db_ui#dbout#foldexpr). The bundled ftplugin only auto-opens
      -- it the first time the filetype is set, so a same-buffer reload on a
      -- repeat query (silent edit!) leaves it collapsed again. Force folds
      -- open every time a dbout buffer is loaded/redisplayed, not just once.
      vim.api.nvim_create_autocmd({ "FileType", "BufWinEnter", "BufReadPost" }, {
        pattern = { "dbout", "*.dbout" },
        callback = function()
          if vim.bo.filetype == "dbout" then
            vim.cmd("silent! normal! zR")
          end
        end,
      })
    end,
  },

  -- Toggle terminal
  {
    "akinsho/toggleterm.nvim",
    version = "*",
    keys = {
      { "<C-`>", desc = "Toggle terminal" },
      { "<leader>gg", desc = "Lazygit" },
    },
    config = function()
      require("toggleterm").setup({
        open_mapping = "<C-`>",
        direction = "horizontal",
        size = 15,
        shade_terminals = true,
      })

      -- Lazygit in a floating terminal
      local Terminal = require("toggleterm.terminal").Terminal
      local lazygit = Terminal:new({ cmd = "lazygit", direction = "float", hidden = true })
      vim.keymap.set("n", "<leader>gg", function() lazygit:toggle() end, { desc = "Lazygit" })

      -- Easy escape from terminal mode
      vim.keymap.set("t", "<Esc><Esc>", "<C-\\><C-n>", { desc = "Exit terminal mode" })
    end,
  },
})

-- Additional keymaps
vim.keymap.set("n", "<leader>w", ":w<CR>", { desc = "Save" })
vim.keymap.set("n", "<leader>q", ":q<CR>", { desc = "Quit" })
vim.keymap.set("n", "<Esc>", ":noh<CR>", { desc = "Clear search highlight" })
vim.keymap.set("n", "<leader>x", ":bdelete<CR>", { desc = "Close buffer" })

-- Window navigation
vim.keymap.set("n", "<C-h>", "<C-w>h", { desc = "Move to left window" })
vim.keymap.set("n", "<C-j>", "<C-w>j", { desc = "Move to lower window" })
vim.keymap.set("n", "<C-k>", "<C-w>k", { desc = "Move to upper window" })
vim.keymap.set("n", "<C-l>", "<C-w>l", { desc = "Move to right window" })

-- Build commands
vim.keymap.set("n", "<leader>bb", ":TermExec cmd='./gradlew build'<CR>", { desc = "Gradle build" })
vim.keymap.set("n", "<leader>br", ":TermExec cmd='./gradlew bootRun'<CR>", { desc = "Gradle run" })
vim.keymap.set("n", "<leader>bR", ":TermExec cmd='./gradlew bootRun --debug-jvm'<CR>", { desc = "Gradle run (debug port 5005)" })
vim.keymap.set("n", "<leader>bt", ":TermExec cmd='./gradlew test'<CR>", { desc = "Gradle test" })
vim.keymap.set("n", "<leader>bc", ":TermExec cmd='./gradlew clean'<CR>", { desc = "Gradle clean" })
vim.keymap.set("n", "<leader>bp", ":TermExec cmd='./gradlew publishToMavenLocal'<CR>", { desc = "Gradle publishToMavenLocal" })

-- Run Gradle test for class/method under cursor
vim.keymap.set("n", "<leader>bT", function()
  -- Get the fully qualified class name from jdtls
  local clients = vim.lsp.get_clients({ name = "jdtls" })
  if #clients == 0 then
    vim.notify("jdtls not running", vim.log.levels.WARN)
    return
  end
  -- Use the current file path to derive the test class
  local filepath = vim.fn.expand("%:p")
  local test_class = filepath
    :gsub(".*/src/test/java/", "")
    :gsub(".*/src/main/java/", "")
    :gsub("%.java$", "")
    :gsub("/", ".")
  local cmd = string.format("./gradlew :test --tests \"%s\"", test_class)
  vim.cmd(string.format(":TermExec cmd='%s'", cmd))
end, { desc = "Gradle test current class" })

-- Cargo build commands (mirrors Gradle keymaps above; kept on a separate
-- <leader>r* prefix since <leader>b* is already fully claimed by Gradle)
vim.keymap.set("n", "<leader>rb", ":TermExec cmd='cargo build'<CR>", { desc = "Cargo build" })
vim.keymap.set("n", "<leader>rr", ":TermExec cmd='cargo run'<CR>", { desc = "Cargo run" })
vim.keymap.set("n", "<leader>rt", ":TermExec cmd='cargo test'<CR>", { desc = "Cargo test" })
vim.keymap.set("n", "<leader>rc", ":TermExec cmd='cargo clean'<CR>", { desc = "Cargo clean" })
vim.keymap.set("n", "<leader>rk", ":TermExec cmd='cargo clippy --all-targets --all-features'<CR>", { desc = "Cargo clippy" })
vim.keymap.set("n", "<leader>rf", ":TermExec cmd='cargo fmt'<CR>", { desc = "Cargo fmt" })

-- Move lines up/down in visual mode
vim.keymap.set("v", "J", ":m '>+1<CR>gv=gv", { desc = "Move line down" })
vim.keymap.set("v", "K", ":m '<-2<CR>gv=gv", { desc = "Move line up" })

-- Java-specific diagnostics formatting
vim.diagnostic.config({
  virtual_text = { spacing = 4, prefix = "●" },
  signs = true,
  underline = true,
  update_in_insert = false,
  severity_sort = true,
  float = { border = "rounded", source = true },
})
