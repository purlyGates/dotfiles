return {
  {
    "MeanderingProgrammer/render-markdown.nvim",
    opts = {
      preset = "obsidian",
      completions = {
        blink = { enabled = true },
      },
    },
  },
  { "neovim/nvim-lspconfig", opts = { servers = { marksman = { enabled = false } } } },
  {
    "mfussenegger/nvim-lint",
    opts = {
      linters_by_ft = {
        markdown = {},
      },
    },
  },
  {
    "stevearc/conform.nvim",
    opts = {
      formatters_by_ft = {
        markdown = {},
      },
    },
  },
}
