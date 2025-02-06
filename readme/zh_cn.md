# *note.nvim*: 随时使用 Neovim 编写笔记

## 介绍

在 Noevim 编写笔记的优势在于速度与无与伦比的自定义属性。然而，如果我们期待在阅读网页或阅读论文 (这通常是 PDF) 格式时快速利用我们最趁手的文本编辑器——对于我而言是 neovim ——进行快速的笔记撰写时，我们缺乏一个有效的工具帮助我们自然地达成这一目标。要完成这个功能，至少需要

* 记录当前阅读的状态，包括
  * 当前阅读网页的 url 以及阅读的位置
  * 当前阅读 PDF 的文件名以及阅读的位置
* 再次打开 neovim 时可以恢复当时的阅读状态

这个插件的目的就是实现这个功能。目前可以实现对`chorme` 浏览器以及 `skim` 阅读器的支持 (因为这是本人使用的两款阅读器)，在 MacOS 环境使用 (基于 applescript)。期待之后可以实现更多平台、更多软件的使用 (见[TODO](#todo))。

## 安装

> lazy.nvim
```lua
return {
  "pxwg/note.nvim",
  dependencies = {
    "MunifTanjim/nui.nvim",
    { "3rd/image.nvim", lazy = true, build = true }, -- Optional image support in pdf preview
    branch = "feature", -- Optional. The latest (unstable) version would be updated in this branch
    opts = {
      -- default options
      integration = {
        image = true, -- optional image support in pdf preview, requires `3rd/image.nvim`
      },
      -- ui is fully customizable based on nui.nvim
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
    },
  },
}
```

## TODO

目前本笔记插件还处于开发状态，还有大量没有实现的功能亟需完善。这里列出一些我认为比较重要的功能：

* 自动跟随当前文件格式更新阅读状态数据库，保证在重构笔记文件时能够正确地跟踪阅读状态；

* 与[telescope.nvim](https://github.com/nvim-telescope/telescope.nvim) 等主流的 picker 联合使用，编写相应的图像处理封装 (目前已经为 telescope 实现)，使得我们可以将自己最熟悉的插件用于笔记撰写，而不是适应一个新的查找窗口；

* 支持更多的阅读环境。目前最想要的是实现对于主流视频网站的观看记录复现，这样我们可以在看视频时也能够快速地记录笔记。更多的笔记阅读环境将对应更为复杂的 picker 等配置，目前我们使用类似环形链表的结构储存阅读状态。为了本项目的长期维护 (主要是 portable 地适用更多的阅读环境)，对于数据库的保存与处理将会始终是更新的重要组成部分；

* 支持更多的平台。目前只支持 MacOS，但是我相信这个插件可以在 Linux 以及 Windows 上实现。
