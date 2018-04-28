" File:        signjump.vim
" Author:      Alex "ZeroKnight" George <http://www.dimensionzero.net>
" Version:     0.4
" URL:         https://github.com/ZeroKnight/vim-signjump
"
" Description: Jump to signs just like other object motions. A feature that is
" oddly absent from Vim's sign suite.

if exists('g:loaded_signjump') || !has('signs') || &compatible || v:version < 700
  finish
endif
let g:loaded_signjump = 1

" Idea credit Tim Pope (tpope)
function! s:map(mode, lhs, rhs, re, ...) abort
  let l:re = a:re ? 'nore' : ''
  let l:flags = (a:0 ? a:1 : '') . (a:rhs =~# '\m^<Plug>' ? '' : '<script>')
  if !hasmapto(a:rhs, a:mode) && maparg(a:lhs, a:mode) ==# ''
    execute a:mode.l:re.'map' l:flags a:lhs a:rhs
  endif
endfunction

function! s:init_options() abort
  if !exists('g:signjump')
    let g:signjump = {}
  endif
  call extend(g:signjump, {
    \ 'map_next_sign':      ']s',
    \ 'map_prev_sign':      '[s',
    \ 'map_first_sign':     '[S',
    \ 'map_last_sign':      ']S',
    \ 'use_jumplist':       0,
    \ 'debug':              0,
  \ }, 'keep')
endfunction
call s:init_options()

nnoremap <silent> <script> <Plug>SignJumpNextSign  :<C-U>call signjump#next_sign(v:count1)<CR>
nnoremap <silent> <script> <Plug>SignJumpPrevSign  :<C-U>call signjump#prev_sign(v:count1)<CR>
nnoremap <silent> <script> <Plug>SignJumpFirstSign :<C-U>call signjump#first_sign()<CR>
nnoremap <silent> <script> <Plug>SignJumpLastSign  :<C-U>call signjump#last_sign()<CR>

if get(g:signjump, 'create_mappings', 1)
  call s:map('n', g:signjump.map_next_sign, '<Plug>SignJumpNextSign', 0)
  call s:map('n', g:signjump.map_prev_sign, '<Plug>SignJumpPrevSign', 0)
  call s:map('n', g:signjump.map_first_sign, '<Plug>SignJumpFirstSign', 0)
  call s:map('n', g:signjump.map_last_sign, '<Plug>SignJumpLastSign', 0)
endif

command! -bar -count SignJumpNext call signjump#next_sign(<count>)
command! -bar -count SignJumpPrev call signjump#prev_sign(<count>)
command! -bar SignJumpFirst       call signjump#first_sign()
command! -bar SignJumpLast        call signjump#last_sign()

" vim: et sts=2 sw=2
