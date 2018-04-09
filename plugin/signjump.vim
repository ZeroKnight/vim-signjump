" File:        signjump.vim
" Author:      Alex "ZeroKnight" George <http://www.dimensionzero.net>
" Version:     0.1
" URL:         https://github.com/ZeroKnight/vim-signjump
"
" Description: Jump to signs just like other text objects. A feature that is
" oddly absent from Vim's sign suite.

scriptencoding utf-8

if exists('g:loaded_signjump') || !has('signs') || &compatible
  finish
endif
let g:loaded_signjump = 1

" vim: et sts=2 sw=2
