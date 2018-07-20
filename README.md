vim-signjump
============

Jump to signs just like other object motions. A feature that is oddly absent from Vim.

Jump Around
-----------

Most plugins that make use of the sign column supply mappings or commands that
jump to their respective signs. This plugin aims to provide the same behavior as
a generic motion that works in any file with signs.

Usage
-----

Using SignJump is simple. By default, the plugin defines mappings for jumping to
the next, previous, first or last sign with mappings akin to Tim Pope's
[Unimpaired][1] plugin. Use `]s` to jump to the next sign, and `[s` to jump to
the previous sign. An optional count can be given to jump *n* signs at a time.
Likewise, capital `S` variants jump to the first and last signs in the buffer.

Jumps are relative to the cursor position. If there is no sign in the jump
direction, or no signs in the current buffer at all, the cursor will not move.

In addition, there are supplementary commands that offer the same functionality.
See `:h signjump-commands` for details.

Installation
------------

No special steps are required for installation. Refer to your plugin manager's
documentation for detailed and specific setup and plugin installation
instructions. Or, if you prefer to do things the hard way, you can manually
install SignJump by adding its directories to your `~/.vim` directory.

### Using Vim-Plug or Vundle

Using [Vim-Plug](https://github.com/junegunn/vim-plug):

```vim
Plug 'ZeroKnight/vim-signjump'
```

Run `:PlugInstall` in Vim.

Using [Vundle](https://github.com/VundleVim/Vundle.vim):

```vim
Plugin 'ZeroKnight/vim-signjump'
```

Run `:PluginInstall` in Vim.

### Using [Pathogen](https://github.com/tpope/vim-pathogen)

```bash
cd ~/.vim/bundle
git clone git://github.com/ZeroKnight/vim-signjump.git
```

Run `:Helptags` in Vim.

### Using Vim or Neovim packages

Vim, as of version 7.4.1486, and [Neovim][2] have native package management that
doesn't require any third-party plugins.

The default package path depends on whether you are using Vim or Neovim, so be
sure to use the appropriate path. You may need to create it first, if it does
not exist.

```bash
cd ~/.vim                    # Vim 8.0
cd ~/.local/share/nvim/site  # Neovim
```

Create the package directory. (Neo)Vim will look for packages under the 'pack'
directory. Each **package** can contain one *or more* **plugins**. Here, we
assume you'll put your plugins installed via `git` in a package called
'git-plugins', but you can name this whatever you'd like.

```bash
mkdir -p pack/git-plugins/start
```

Clone the repository.

```bash
git clone https://github.com/ZeroKnight/vim-signjump pack/git-plugins/start/vim-signjump
```

You'll need to generate tags for the help file in order to view it with `:help`.
You can do this manually, or add the following to the **end** of your
vimrc/init.vim:

```vim
" Load packages now so that they are in 'runtimepath', otherwise helptags won't
" be able to find them.
packloadall

" Quietly generate tags for help files.
silent! helptags ALL
```

Configuration
-------------

See `:h signjump-configuration` for options.

Background
----------

SignJump is my first Vim plugin. I was inspired to write it by this [Vi & Vim
Stack Exchange question][3].

I thought that it was very peculiar that Vim doesn't have a user-friendly way
to jump to signs. The closest thing would be `:sign jump ...`, but having to supply
a specific ID and buffer/file name is hardly user-friendly, and there's no
mapping equivalent.

I hope that you find this plugin useful, and appreciate its simplicity and
light weight. I wrote this plugin with the vision that it be one of those
"must have missing features" type plugins that anyone would want in their Vim
configuration.

Acknowledgements
----------------

* [Andreas Louv](https://github.com/andlrc) - Early code review.
* [Luc Hermitte](https://github.com/LucHermitte) - Insightful early code review
    and suggestions; drove several refactors. Answered my neophyte questions.
    Thank you!

[1]: https://github.com/tpope/vim-unimpaired
[2]: https://github.com/neovim/neovim
[3]: https://vi.stackexchange.com/q/15846/1452
