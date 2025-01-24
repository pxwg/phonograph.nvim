# *note.nvim*: Writing Notes With Neovim Everywhere

[中文](./readme/zh_cn.md)

## Introduction

The advantage of writing notes in Neovim lies in its speed and unparalleled customization. However, when it comes to reading web pages or papers (usually in PDF format), we lack an effective tool to quickly take notes in Neovim while reading. To achieve this functionality, at a minimum, we need to:

* Record the current reading state, including:

  * The URL and position of the current web page being read
  
  * The filename and position of the current PDF being read
  
* Restore the reading state when reopening Neovim

The purpose of this plugin is to achieve this functionality. Currently, it supports the `chrome` browser and the `skim` reader (as these are the two readers I use), and it relies on applescript in the MacOS environment. We hope to support more platforms and software in the future.
