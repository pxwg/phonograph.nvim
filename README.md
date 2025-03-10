# 🎶*phonograph.nvim*: Echoes of Flowing Text

> <p align="center"><a href="./readme/zh_cn.md">简体中文</a></p>

## Introduction 📖

We often need to take notes while reading papers or websites, and these notes can sometimes be handwritten or electronic. Handwritten notes can easily facilitate annotations. Annotations refer to a mode of association between the text being read and the text being recorded.

When we transcribe these handwritten notes, or poetically speaking—"flowing text"—into reusable, easily searchable electronic documents, and even make them part of a personal wiki, we need to achieve the electronic documentation of annotations from paper or web reading. This involves using editor features to reconstruct the relationship between the original text and the notes. To rebuild this relationship, it is necessary to achieve:

* Recording the current reading state, which currently includes:
  * The URL of the current web page being read and the reading position
  * The filename of the current PDF being read and the reading position
  The reading state is reflected in the text as folded bookmarks, marking the relationship between annotations and the web page being read.

* Restoring the reading state when reopening Neovim, possible methods include:
  * Querying the reading state externally and opening it
  * Directly opening the reading state through folded bookmarks

The purpose of this plugin is to achieve the above functionality. Currently, it supports the `chrome` browser and `skim` reader (as these are the two readers I use) on MacOS (based on AppleScript). I look forward to supporting more platforms and software in the future (see [TODO](#todo)).

## Installation 📦

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

## TODO 🤔

This note-taking plugin is still under development, and there are many features that need to be completed. Here are some features I consider important:

* Use an SQLite database instead of a self-built database to better achieve data IO (⭐very important! Finished with [sqlite.lua](https://github.com/kkharji/sqlite.lua) in main branch, may have some bugs ✅);

* Add [snacks.image](./https://github.com/folke/snacks.nvim/blob/main/docs/image.md) support for the best image display experience ❌; 

* Add unit tests ❌, add specific types ❌;

* Automatically update the reading state database following the current file format to ensure that the reading state can be correctly tracked when restructuring note files (tracking reading state deletion: ✅; tracking reading state restructuring: ✅);

* Integrate with mainstream pickers like [telescope.nvim](https://github.com/nvim-telescope/telescope.nvim) and write corresponding image processing wrappers (currently implemented for telescope but not yet wrapped❌), allowing us to use our most familiar plugins for note-taking instead of adapting to a new search window;

* Support more reading environments. Currently, the most desired feature is to reproduce viewing records for mainstream video sites, so we can quickly take notes while watching videos. More note-taking environments will correspond to more complex picker configurations. We currently use a circular linked list-like structure to store reading states. For the long-term maintenance of this project (mainly to portably apply to more reading environments), saving and processing the database will always be an important part of updates;

* Support more platforms. Currently, only MacOS is supported, but I believe this plugin can be implemented on Linux and Windows.
