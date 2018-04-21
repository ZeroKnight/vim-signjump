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
the next, previous, first or last sign akin to Tim Pope's [Unimpaired][1]
plugin. Use `]s` to jump to the next sign, and `[s` to jump to the previous
sign. An optional count can be given to jump *n* signs at a time. Likewise,
capital `S` variants jump to the first and last signs in the buffer.

Jumps are relative to the cursor position. If there is no sign in the jump
direction, or no signs in the current buffer at all, the cursor will not move.

In addition, there are supplementary commands that offer the same functionality.
See `:h signjump-commands` for details.

Installation
------------

Use a plugin manager of your choice, or manually add to your `~/.vim` directory.

Configuration
-------------

See `:h signjump-configuration` for options.

Acknowledgements & Misc
-----------------------

SignJump is my first Vim plugin. I was inspired to write it by this [Vi & Vim
Stack Exchange question][2].

I thought that it was very peculiar that Vim doesn't have a user-friendly way
to jump to signs. The closest thing would be sign-jump, but having to supply
a specific ID and buffer/file name is hardly user friendly, and there's no
mapping equivalent.

I hope that you find this plugin useful, and appreciate its simplicity and
light weight. I wrote this plugin with the vision that it be one of those
"must have missing features" type plugins that anyone would want in their Vim
configuration.

[1]: https://github.com/tpope/vim-unimpaired
[2]: https://vi.stackexchange.com/q/15846/1452
