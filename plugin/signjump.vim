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

" Typical ':sign place' line:
" line=25  id=3007  name=FooSign
function! s:get_signs(buffer) abort
  redir => l:out
    silent execute 'sign place buffer=' . a:buffer
  redir END
  let l:out = filter(split(l:out, '\n', 0), "v:val =~# '='")
  call map(l:out, 'v:val[4:]') " Trim indent
  return l:out
endfunction

" TODO: need to sort by lines; then get the id of the desired line and feed to
" :sign jump
function! s:next_sign(buffer) abort
  let l:signs = getbufvar(a:buffer, 'signjump_signs', [])
  if empty(l:signs)
    return
  endif
  let l:last = getbufvar(a:buffer, 'signjump_last_jump', -1)
  let l:sign = split(l:signs[l:last+1], '  ', 0)

  execute 'sign jump'
    \ substitute(l:sign[1], 'id=\(\d\+\)', '\=submatch(1)', '')
    \ 'file=' . bufname(a:buffer)
  call setbufvar(a:buffer, 'signjump_last_jump', l:last + 1)
  echom 'Jumping to sign:' string(l:sign)
endfunction

function! s:prev_sign(buffer) abort
  let l:signs = getbufvar(a:buffer, 'signjump_signs', [])
  if empty(l:signs)
    return
  endif
  let l:last = getbufvar(a:buffer, 'signjump_last_jump', -1)
  let l:sign = split(l:signs[l:last-1], '  ', 0)

  execute 'sign jump'
    \ substitute(l:sign[1], 'id=\(\d\+\)', '\=submatch(1)', '')
    \ 'file=' . bufname(a:buffer)
  call setbufvar(a:buffer, 'signjump_last_jump', l:last - 1)
  echom 'Jumping to sign:' string(l:sign)
endfunction

" XXX: For testing
nnoremap ]s :call <SID>next_sign(expand('%'))<CR>
nnoremap [s :call <SID>prev_sign(expand('%'))<CR>

augroup SignJumpAutoCmds
  autocmd!

  autocmd BufEnter * call setbufvar(bufnr('%'), 'signjump_signs', s:get_signs(bufnr('%')))
augroup END

" vim: et sts=2 sw=2
