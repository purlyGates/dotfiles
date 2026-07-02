return {
  {
    "saghen/blink.compat",
    lazy = true,
    version = "*",
  },
  {
    "saghen/blink.cmp",
    opts = {
      keymap = {
        ["<Tab>"] = { "accept", "fallback" },
        ["<CR>"] = { "fallback" },
      },
      sources = {
        default = { "obsidian", "obsidian_new", "obsidian_tags", "lsp", "path", "snippets", "buffer" },
        providers = {
          obsidian = {
            name = "obsidian",
            module = "blink.compat.source",
            opts = { name = "obsidian" },
          },
          obsidian_new = {
            name = "obsidian_new",
            module = "blink.compat.source",
            opts = { name = "obsidian_new" },
          },
          obsidian_tags = {
            name = "obsidian_tags",
            module = "blink.compat.source",
            opts = { name = "obsidian_tags" },
          },
        },
      },
    },
  },
}
