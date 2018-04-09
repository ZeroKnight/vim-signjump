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

let s:signs = []
let s:last_jump = -1

function! s:get_signs(filename) abort
  redir => l:out
    silent execute 'sign place'
  redir END
  let l:out = split(l:out, '\n', 0)
  call remove(l:out, 0) " Remove command output header

  let l:start = index(l:out, 'Signs for '.a:filename.':')
  let l:next_file = match(l:out, 'Signs for ', l:start + 1)
  let l:end = l:next_file > -1 ? l:next_file - 1 : -1
  let s:signs = (l:start > -1 ? l:out[l:start+1:l:end] : [])
endfunction

function! s:next_sign(filename) abort
  let l:sign = split(s:signs[s:last_jump+1], '  ', 0)
  execute 'sign jump' substitute(l:sign[1], 'id=\(\d\+\)', '\=submatch(1)', '') 'file='.a:filename
  let s:last_jump = s:last_jump + 1
endfunction

" XXX: For testing
nnoremap ]s :call <SID>next_sign(expand('%'))<CR>
call s:get_signs(expand('%'))

" vim: et sts=2 sw=2
