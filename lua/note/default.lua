local M = {}

M.defalut_opts = {
  integration = {
    image = true,
  },
  -- mark = {
  --   order = { url.title, pdf.title, pdf.path, pdf.page },
  -- },
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
      border = {
        style = "single",
        text = {
          top = " Details ",
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
  },
}

return M
