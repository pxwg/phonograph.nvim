# 🎶*phonograph.nvim*: 流动文字的回音

## 介绍 📖

我们在阅读论文的过程中常常需要记录相应的笔记，这些笔记有时候是手写的、有时候是电子的。手写笔记可以很方便地实现批注。所谓批注，即一种被阅读文本与记录文本的关联模式。

当我们将这些手写的笔记，或者诗意地说——“流动的文字”——转写成可以复用、方便查询的电子文档，乃至成为个人 wiki 的一部分时，我们需要实现论文 or 网页阅读“批注”的电子文档化，即利用编辑器特性重建原文与笔记的相互关系。为了重建这种关系，需要实现

* 当前阅读状态的记录，目前包括
  * 当前阅读网页的 url 以及阅读的位置 
  * 当前阅读 PDF 的文件名以及阅读的位置 
  * 当前观看视频的时间戳
  阅读状态以折叠书签的形式在文本中体现，以标记旁批与阅读网页的相互关系。

* 再次打开 neovim 时可以恢复当时的阅读状态，可能的方式包括
  * 外部查询阅读状态并打开
  * 直接通过折叠书签打开阅读状态

这个插件的目的就是实现上述功能。目前可以实现对`chorme` 浏览器以及 `skim` 阅读器的支持 (因为这是本人使用的两款阅读器)，在 MacOS 环境使用 (基于 applescript)。期待之后可以实现更多平台、更多软件的使用 (见[TODO](#todo))。

## 安装 🛠

<details>
<summary>lazy.nvim</summary>

```lua
return {
  "pxwg/phonograph.nvim",
  dependencies = {
    { "MunifTanjim/nui.nvim" },
    { "kkharji/sqlite.lua" },
    { "3rd/image.nvim", lazy = true, build = true }, -- Optional image support in pdf preview
    opts = {
      -- default options
      integration = {
        image = true, -- optional image support in pdf preview, requires `3rd/image.nvim` and it's dependencies
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

</details>

## 命令 🔧

| 命令 | 描述 |
| --- | --- |
| `:PhonographInsertPdf` | 在光标位置插入 PDF 阅读状态。捕获当前 PDF 页面并创建可折叠书签。 |
| `:PhonographInsertUrl` | 在光标位置插入 URL 阅读状态。捕获当前网页并创建可折叠书签。 |
| `:PhonographOpen` | 打开与当前光标位置关联的阅读状态（PDF 或 URL）。 |
| `:PhonographMouseOpen` | 打开鼠标点击位置的阅读状态。适用于用鼠标快速打开书签。 |
| `:PhonographEdit` | 使用当前阅读状态更新光标位置的现有书签。 |
| `:PhonographReview` | 打开所有已保存阅读状态的 UI 界面，允许在 PDF 和 URL 之间进行选择和导航。 |

## TODO 🤔

目前本笔记插件还处于开发状态，还有大量没有实现的功能亟需完善。这里列出一些我认为比较重要的功能：

* 使用 sqlite 数据库代替自建数据库，更好地实现数据读写 (⭐非常重要！已经完成✅)；

* 集成 [snacks.image](./https://github.com/folke/snacks.nvim/blob/main/docs/image.md) 以获得最佳的图片显示效果 (⭐非常重要！❌)；

* 添加单元测试❌，添加特定的类型❌；

* 自动跟随当前文件格式更新阅读状态数据库，保证在重构笔记文件时能够正确地跟踪阅读状态 (跟踪阅读状态的删除：✅；跟踪阅读状态的重构：✅)；

* 与[telescope.nvim](https://github.com/nvim-telescope/telescope.nvim) 等主流的 picker 联合使用，编写相应的图像处理封装 (目前已经为 telescope 实现，但还没有封装❌)，使得我们可以将自己最熟悉的插件用于笔记撰写，而不是适应一个新的查找窗口；

* 支持更多的阅读环境。目前最想要的是实现对于主流视频网站的观看记录复现，这样我们可以在看视频时也能够快速地记录笔记。更多的笔记阅读环境将对应更为复杂的 picker 等配置，目前我们使用类似环形链表的结构储存阅读状态。为了本项目的长期维护 (主要是 portable 地适用更多的阅读环境)，对于数据库的保存与处理将会始终是更新的重要组成部分；

* 支持更多的平台。目前只支持 MacOS，但是我相信这个插件可以在 Linux 以及 Windows 上实现。
