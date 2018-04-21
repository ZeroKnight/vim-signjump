" File:        signjump.vim
" Author:      Alex "ZeroKnight" George <http://www.dimensionzero.net>
" Version:     0.1
" URL:         https://github.com/ZeroKnight/vim-signjump
"
" Description: Jump to signs just like other text objects. A feature that is
" oddly absent from Vim's sign suite.

scriptencoding utf-8

if exists('g:loaded_signjump') || !has('signs') || &compatible || v:version < 700
  finish
endif
let g:loaded_signjump = 1

" Idea credit Tim Pope (tpope)
function! s:map(mode, lhs, rhs, re, ...) abort
  let l:re = a:re ? 'nore' : ''
  let l:flags = (a:0 ? a:1 : '') . (a:rhs =~# '^<Plug>' ? '' : '<script>')
  if !hasmapto(a:rhs, a:mode) && maparg(a:lhs, a:mode) ==# ''
    execute a:mode.l:re.'map' l:flags a:lhs a:rhs
  endif
endfunction

function! s:default_opt(var, default) abort
  if !exists('g:signjump_' . a:var)
    execute 'let g:signjump_' . a:var '=' a:default
  endif
endfunction

function! s:init_options() abort
  let l:options = [
    \ ['use_jumplist', 0],
    \ ['debug', 0],
  \ ]
  for [opt, val] in l:options
    call s:default_opt(opt, val)
  endfor
endfunction
call s:init_options()

" Typical ':sign place' line:
" line=25  id=3007  name=FooSign
function! s:get_buffer_signs(buffer) abort
  redir => l:out
    silent execute 'sign place buffer=' . a:buffer
  redir END
  let l:out = filter(split(l:out, '\n', 0), "v:val =~# '='")
  call map(l:out, 'v:val[4:]') " Trim indent
  call sort(l:out, {a, b ->
    \ str2nr(matchlist(a, 'line=\(\d\+\)')[1]) <
    \ str2nr(matchlist(b, 'line=\(\d\+\)')[1]) ? -1 : 1 })

  if signjump#opt('debug')
    echom 'Got' len(l:out) 'signs for buffer' bufname(a:buffer)
  endif
  return l:out
endfunction

function! s:update_signs(buffer) abort
  call setbufvar(a:buffer, 'signjump_signs', s:get_buffer_signs(a:buffer))
endfunction

nnoremap <silent> <script> <Plug>SignJumpNextSign  :call signjump#next_sign()<CR>
nnoremap <silent> <script> <Plug>SignJumpPrevSign  :call signjump#prev_sign()<CR>
nnoremap <silent> <script> <Plug>SignJumpFirstSign :call signjump#first_sign()<CR>
nnoremap <silent> <script> <Plug>SignJumpLastSign  :call signjump#last_sign()<CR>

call s:map('n', ']s', '<Plug>SignJumpNextSign', 0)
call s:map('n', '[s', '<Plug>SignJumpPrevSign', 0)
call s:map('n', ']S', '<Plug>SignJumpLastSign', 0)

command! -bar SignJumpRefresh call signjump#update_signs(bufnr('%'))
command! -bar SignJumpNext    call signjump#next_sign()
command! -bar SignJumpPrev    call signjump#prev_sign()
command! -bar SignJumpFirst   call signjump#first_sign()
command! -bar SignJumpLast    call signjump#last_sign()

augroup SignJumpAutoCmds
  autocmd!

  " Update after a delay to ensure all plugins modifying signs have done so
  autocmd BufEnter,BufReadPost,BufWritePost,
    \ShellCmdPost,FileChangedShellPost,
    \CursorHold,CursorHoldI
    \ * call timer_start(250, {tid -> s:update_signs(bufnr('%'))})
augroup END

" vim: et sts=2 sw=2
