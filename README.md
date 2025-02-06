# *note.nvim*: Take Notes Everywhere with Neovim

<p align="center"><a href="./readme/zh_cn.md">简体中文</a></p>

## Introduction

The advantage of writing notes in Neovim lies in its speed and unparalleled customization properties. However, if we expect to quickly use our most handy text editor—Neovim, in my case—to take notes while reading web pages or papers (which are usually in PDF format), we lack an effective tool to help us naturally achieve this goal. To accomplish this function, at least the following is needed:

* Record the current reading state, including:
  * The URL and position of the current web page being read
  * The filename and position of the current PDF being read
* Restore the reading state while reopening Neovim

The purpose of this plugin is to achieve this functionality. Currently, it supports the `chrome` browser and the `skim` reader (as these are the two readers I use), and it relies on (applescript) in the MacOS environment. We look forward to supporting more platforms and software in the future (see also [TODO](##TODO)).

## Installation

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

This note-taking plugin is still in development, and there are many features that need to be implemented. Here are some of the more important features:

* Automatically update the reading status database according to the current file format to ensure that the reading status can be correctly tracked when refactoring note files;

* Integrate with popular pickers such as [telescope.nvim](https://github.com/nvim-telescope/telescope.nvim) by writing corresponding image processing wrappers (currently implemented for telescope), so that we can use our most familiar plugins for note-taking instead of adapting to a new search window;

* Support more reading environments. The most desired feature is to implement playback record reproduction for mainstream video websites, so that we can quickly take notes while watching videos. More note-reading environments will correspond to more complex picker configurations. Currently, we use a circular linked list structure to store reading statuses. For the long-term maintenance of this project (mainly to portably support more reading environments), saving and processing the database will always be an important part of the updates;

* Support more platforms. Currently, only MacOS is supported, but I believe this plugin can be implemented on Linux and Windows.
