" File:        signjump.vim
" Author:      Alex "ZeroKnight" George <http://www.dimensionzero.net>
" Version:     0.5.1
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
    \ 'wrap':               1,
    \ 'debug':              0,
  \ }, 'keep')
endfunction
call s:init_options()

" FIXME: The @= method interprets a count in the mapping as a repeat, and ends
" up calling the function n times with a count of n.
" For now, since repeating has the same end result, we can get away with just
" using it as-is. A proper solution to disable the repeat or underlying cause of
" needing @= would be great.
nnoremap <silent> <Plug>SignJumpNextSign    :<C-U>call signjump#next_sign(v:count1)<CR>
nnoremap <silent> <Plug>SignJumpPrevSign    :<C-U>call signjump#prev_sign(v:count1)<CR>
noremap  <silent> <Plug>SignJumpFirstSign   @=signjump#first_sign()<CR>
noremap  <silent> <Plug>SignJumpLastSign    @=signjump#last_sign()<CR>
noremap  <silent> <Plug>SignJumpSelNextSign @=signjump#next_sign()<CR>
noremap  <silent> <Plug>SignJumpSelPrevSign @=signjump#prev_sign()<CR>

if get(g:signjump, 'create_mappings', 1)
  call s:map('n', g:signjump.map_next_sign,  '<Plug>SignJumpNextSign', 0)
  call s:map('n', g:signjump.map_prev_sign,  '<Plug>SignJumpPrevSign', 0)
  call s:map('n', g:signjump.map_first_sign, '<Plug>SignJumpFirstSign', 0)
  call s:map('n', g:signjump.map_last_sign,  '<Plug>SignJumpLastSign', 0)
  call s:map('x', g:signjump.map_first_sign, '<Plug>SignJumpFirstSign', 0)
  call s:map('x', g:signjump.map_last_sign,  '<Plug>SignJumpLastSign', 0)
  call s:map('x', g:signjump.map_next_sign,  '<Plug>SignJumpSelNextSign', 0)
  call s:map('x', g:signjump.map_prev_sign,  '<Plug>SignJumpSelPrevSign', 0)
endif

command! -bar -count=1 SignJumpNext call signjump#next_sign(<count>)
command! -bar -count=1 SignJumpPrev call signjump#prev_sign(<count>)
command! -bar SignJumpFirst         call signjump#first_sign()
command! -bar SignJumpLast          call signjump#last_sign()

" vim: et sts=2 sw=2
