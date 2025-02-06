local M = {}
M.opts = {}

function M.setup(user_opts)
  local default_opts = {
    integration = {
      image = true,
    },
    ui = {
      selection = {
        border = {
          style = "single",
          text = {
            top = " Selection ",
            top_align = "center",
          },
        },
        size = {
          width = "100%",
          height = "100%",
        },
        buf_options = {
          modifiable = true,
          readonly = false,
        },
        win_options = {
          winblend = 0,
          winhighlight = "Normal:TelescopeNormal,FloatBorder:TelescopeBorder,FloatTitle:TelescopePromptTitle",
        },
      },
      preview = {
        style = "single",
        text = {
          top = " Detail ",
          top_align = "center",
        },
      },
      size = {
        width = "100%",
        height = "100%",
      },
      buf_options = {
        modifiable = true,
        readonly = false,
      },
      win_options = {
        winblend = 0,
        winhighlight = "Normal:TelescopeNormal,FloatBorder:TelescopeBorder,FloatTitle:TelescopePreviewTitle",
      },
    },
  }

  M.opts = vim.tbl_deep_extend("force", default_opts, user_opts or {})

  print(vim.inspect(M.opts.ui.selection.border))

  require("note.keymaps")
  require("note.autocmd")
end

return M
