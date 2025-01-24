# *note.nvim*: 随时使用 Neovim 编写笔记

## 介绍

在 Noevim 编写笔记的优势在于速度与无与伦比的自定义属性。然而，如果我们期待在阅读网页或阅读论文 (这通常是 PDF) 格式时快速利用我们最趁手的文本编辑器——对于我而言是 neovim ——进行快速的笔记撰写时，我们缺乏一个有效的工具帮助我们自然地达成这一目标。要完成这个功能，至少需要

* 记录当前阅读的状态，包括
  * 当前阅读网页的 url 以及阅读的位置
  * 当前阅读 PDF 的文件名以及阅读的位置
* 再次打开 neovim 时可以恢复当时的阅读状态

这个插件的目的就是实现这个功能。目前可以实现对`chorme` 浏览器以及 `skim` 阅读器的支持 (因为这是本人使用的两款阅读器)，在 MacOS 环境使用 (applescript) 依赖。期待之后可以实现更多平台、更多软件的使用。

## 安装

> lazy.nvim
```lua
return {
  "pxwg/note.nvim",
  dependencies = {
    "MunifTanjim/nui.nvim",
    { "3rd/image.nvim", lazy = true, build = true }, -- Optional image support in pdf preview  },
  branch = "feature", -- Optional. The latest (unstable) version would be updated in this branch
}
```
