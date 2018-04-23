" File:        signjump.vim
" Author:      Alex "ZeroKnight" George <http://www.dimensionzero.net>
" Version:     0.3
" URL:         https://github.com/ZeroKnight/vim-signjump
"
" Description: Jump to signs just like other object motions. A feature that is
" oddly absent from Vim's sign suite.

scriptencoding utf-8

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

function! s:opt(var, ...) abort
  let l:default = a:0 ? a:1 : 0
  return get(g:signjump, a:var, l:default)
endfunction

function! s:init_options() abort
  let g:signjump = {}
  call extend(g:signjump, {
    \ 'use_jumplist': 0,
    \ 'debug': 0,
  \ }, 'keep')
endfunction
call s:init_options()

" Typical ':sign place' line:
" line=25  id=3007  name=FooSign
function! s:get_buffer_signs(buffer) abort
  let l:out =
    \ filter(
    \   split(execute('sign place buffer='.a:buffer, 'silent'), '\n'),
    \ "v:val =~# '='")
  call map(l:out, 'v:val[4:]') " Trim indent
  call sort(l:out, {a, b ->
    \ str2nr(matchlist(a, '\vline\=(\d+)')[1]) <
    \ str2nr(matchlist(b, '\vline\=(\d+)')[1]) ? -1 : 1 })

  if s:opt('debug')
    echom 'Got' len(l:out) 'signs for buffer' bufname(a:buffer)
  endif
  return l:out
endfunction

function! s:get_sign_data(sign, item) abort
  return matchlist(a:sign, a:item.'\v\=(\d+)')[1]
endfunction

function! s:get_sign(line, offset, ...) abort
  let l:count = a:0 ? a:1 : 1
  let l:signs = s:get_buffer_signs(bufnr('%'))
  if empty(l:signs)
    return []
  endif
  let l:index = match(l:signs, '\vline\=<'.a:line.'>')
  if a:offset == '+'
    if l:index == -1
      for s in l:signs
        if s:get_sign_data(s, 'line') > a:line
          let l:index = index(l:signs, s) - 1
          break
        endif
      endfor
    endif
    let l:index += l:count
  elseif a:offset == '-'
    if l:index == -1
      for s in reverse(copy(l:signs))
        if s:get_sign_data(s, 'line') < a:line
          let l:index = index(l:signs, s) + 1
          break
        endif
      endfor
    endif
    let l:index -= l:count
  endif
  if l:index >= len(l:signs)
    let l:index = len(l:signs) - 1
  elseif l:index < 0
    let l:index = 0
  endif
  return split(l:signs[l:index], '  ', 0)
endfunction

function! s:jump_to_sign(sign) abort
  let l:from = line('.')
  if s:opt('use_jumplist')
    execute 'normal!' s:get_sign_data(a:sign, 'line') . 'G'
  else
    execute 'sign jump' s:get_sign_data(a:sign, 'id')
      \ 'buffer=' . bufnr('%')
  endif

  if s:opt('debug')
    echom 'Jumping to sign:' string(a:sign) . ', from line' l:from
  endif
endfunction

function! s:next_sign(...) abort
  let l:count = a:0 ? a:1 : 1
  let l:sign = s:get_sign(line('.'), '+', l:count)
  if !empty(l:sign)
    call s:jump_to_sign(l:sign)
  endif
endfunction

function! s:prev_sign(...) abort
  let l:count = a:0 ? a:1 : 1
  let l:sign = s:get_sign(line('.'), '-', l:count)
  if !empty(l:sign)
    call s:jump_to_sign(l:sign)
  endif
endfunction

function! s:first_sign() abort
  let l:signs = s:get_buffer_signs(bufnr('%'))
  if !empty(l:signs)
    call s:jump_to_sign(l:signs[0])
  endif
endfunction

function! s:last_sign() abort
  let l:signs = s:get_buffer_signs(bufnr('%'))
  if !empty(l:signs)
    call s:jump_to_sign(l:signs[-1])
  endif
endfunction

nnoremap <silent> <script> <Plug>SignJumpNextSign  :<C-U>call <SID>next_sign(v:count1)<CR>
nnoremap <silent> <script> <Plug>SignJumpPrevSign  :<C-U>call <SID>prev_sign(v:count1)<CR>
nnoremap <silent> <script> <Plug>SignJumpFirstSign :<C-U>call <SID>first_sign()<CR>
nnoremap <silent> <script> <Plug>SignJumpLastSign  :<C-U>call <SID>last_sign()<CR>

if s:opt('create_mappings')
  call s:map('n', ']s', '<Plug>SignJumpNextSign', 0)
  call s:map('n', '[s', '<Plug>SignJumpPrevSign', 0)
  call s:map('n', '[S', '<Plug>SignJumpFirstSign', 0)
  call s:map('n', ']S', '<Plug>SignJumpLastSign', 0)
endif

command! -bar -count SignJumpNext call s:next_sign(<count>)
command! -bar -count SignJumpPrev call s:prev_sign(<count>)
command! -bar SignJumpFirst       call s:first_sign()
command! -bar SignJumpLast        call s:last_sign()

" vim: et sts=2 sw=2
