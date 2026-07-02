return {
  "epwalsh/obsidian.nvim",
  version = "*", -- recommended, use latest release instead of latest commit
  lazy = true,
  ft = "markdown",
  -- Replace the above line with this if you only want to load obsidian.nvim for markdown files in your vault:
  -- event = {
  --   -- If you want to use the home shortcut '~' here you need to call 'vim.fn.expand'.
  --   -- E.g. "BufReadPre " .. vim.fn.expand "~" .. "/my-vault/*.md"
  --   -- refer to `:h file-pattern` for more examples
  --   "BufReadPre path/to/my-vault/*.md",
  --   "BufNewFile path/to/my-vault/*.md",
  -- },
  dependencies = {
    -- Required.
    "nvim-lua/plenary.nvim",
    -- see below for full list of optional dependencies 👇
  },
  opts = {
    ui = {
      enabled = false,
    },
    workspaces = {
      {
        name = "2nd Brain",
        path = "/mnt/c/Users/aeidl/git/personal/obsidian/My 2nd Brain",
        overrides = {
          daily_notes = {
            folder = "/mnt/c/Users/aeidl/git/personal/obsidian/My 2nd Brain/05-Journal",
            date_format = "%Y/%m/%Y-%m-%d",
            template = "/mnt/c/Users/aeidl/git/personal/obsidian/My 2nd Brain/Templates/Daily Note",
          },
          templates = {
            folder = "/mnt/c/Users/aeidl/git/personal/obsidian/My 2nd Brain/Templates/",
          },
        },
      },
      {
        name = "work",
        path = "/mnt/c/Users/aeidl/git/emmi/kb-cpi",
      },
    },
    picker = {
      name = "telescope.nvim",
    },

    -- see below for full list of options 👇
  },
}
