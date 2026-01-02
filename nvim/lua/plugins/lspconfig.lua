-- Register ty server (not yet in nvim-lspconfig)
local configs = require("lspconfig.configs")
if not configs.ty then
  configs.ty = {
    default_config = {
      cmd = { "ty", "server" },
      filetypes = { "python" },
      root_dir = require("lspconfig.util").root_pattern("pyproject.toml", "ty.toml", ".git"),
      single_file_support = true,
    },
  }
end

return {
  {
    "neovim/nvim-lspconfig",
    opts = {
      codelens = {
        enabled = false,
      },
      autoformat = true,
      servers = {
        eslint = {
          enabled = false,
        },
        ruff = {
          enabled = true,
          autostart = true,
          init_options = {
            settings = {
              fixAll = true,
            },
          },
          capabilities = {
            general = {
              -- positionEncodings = { "utf-8", "utf-16", "utf-32" }  <--- this is the default
              positionEncodings = { "utf-16" },
            },
          },
        },
        ty = {
          enabled = true,
          autostart = true,
        },
        basedpyright = { enabled = false, autostart = false },
        pyright = { enabled = false, autostart = false },
        pylsp = {
          enabled = false,
          autostart = false,
          settings = {
            pylsp = {
              plugins = {
                -- Disable formatting (ruff handles this)
                black = { enabled = false },
                autopep8 = { enabled = false },
                yapf = { enabled = false },
                -- Disable linting (ruff handles this)
                pylint = { enabled = false },
                pyflakes = { enabled = false },
                pycodestyle = { enabled = false },
                mccabe = { enabled = false },
                -- Disable type checking (ty handles this now)
                pylsp_mypy = { enabled = false },
                -- Keep completion and navigation features
                jedi_completion = { enabled = true, fuzzy = true },
                jedi_definition = { enabled = true },
                jedi_references = { enabled = true },
                jedi_hover = { enabled = true },
                jedi_signature_help = { enabled = true },
                -- Disable import sorting (ruff handles this)
                pyls_isort = { enabled = false },
                rope_completion = { enabled = false },
              },
            },
          },
        },
      },
    },
  },
}
