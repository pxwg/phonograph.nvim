# *note.nvim*: Take Notes Everywhere with Neovim

## Introduction

The advantage of taking notes in Neovim lies in its speed and unparalleled customization. However, if we want to quickly take notes using our favorite text editor—Neovim in my case—while reading web pages or papers (usually in PDF format), we lack an effective tool to help us achieve this goal naturally. To accomplish this, we need at least:

* Record the current reading state, including:
  * The URL and position of the current web page being read
  * The filename and position of the current PDF being read
* Restore the reading state while reopening Neovim

The purpose of this plugin is to achieve this functionality. Currently, it supports the `chrome` browser and the `skim` reader (as these are the two readers I use), and it relies on (applescript) in the MacOS environment. We look forward to supporting more platforms and software in the future.

## Installation

> lazy.nvim

```lua
return {
  "pxwg/note.nvim",
  dependencies = {
    "MunifTanjim/nui.nvim",
    { "3rd/image.nvim", lazy = true, build = true }, -- Optional image support in pdf preview
  branch = "feature", -- Optional. The latest (unstable) version would be updated in this branch
}
```
