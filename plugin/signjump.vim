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

function! s:opt(var) abort
  execute 'return g:signjump_' . a:var
endfunction

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

  if s:opt('debug')
    echom 'Got' len(l:out) 'signs for buffer' bufname(a:buffer)
  endif
  return l:out
endfunction

function! s:update_signs(buffer) abort
  call setbufvar(a:buffer, 'signjump_signs', s:get_buffer_signs(a:buffer))
endfunction

function! s:get_sign_data(sign, item) abort
  return matchlist(a:sign, a:item.'=\(\d\+\)')[1]
endfunction

function! s:get_sign(line, ...) abort
  let l:buf = bufnr('%')
  let l:signs = getbufvar(l:buf, 'signjump_signs', [])
  if empty(l:signs)
    return []
  endif
  let a:offset = get(a:, 1, '')
  let l:index = match(l:signs, 'line=\<'.a:line.'\>')
  if a:offset == '+'
    if l:index == -1
      for s in l:signs
        if s:get_sign_data(s, 'line') > a:line
          let l:index = index(l:signs, s)
          break
        endif
      endfor
    else
      let l:index += 1
    endif
  elseif a:offset == '-'
    if l:index == -1
      for s in reverse(copy(l:signs))
        if s:get_sign_data(s, 'line') < a:line
          let l:index = index(l:signs, s)
          break
        endif
      endfor
    else
      let l:index -= 1
    endif
  endif
  if l:index >= len(l:signs) || l:index == -1
    return []
  endif
  return split(l:signs[l:index], '  ', 0)
endfunction

function! s:jump_to_sign(sign) abort
  let l:from = line('.')
  if s:opt('use_jumplist')
    execute 'normal' s:get_sign_data(a:sign, 'line') . 'G'
  else
    execute 'sign jump' s:get_sign_data(a:sign, 'id') 'buffer=' . bufnr('%')
  endif

  if s:opt('debug')
    echom 'Jumping to sign:' string(a:sign) . ', from line' l:from
  endif
endfunction

function! s:next_sign() abort
  let l:sign = s:get_sign(line('.'), '+')
  if empty(l:sign)
    return
  endif
  call s:jump_to_sign(l:sign)
endfunction

function! s:prev_sign() abort
  let l:sign = s:get_sign(line('.'), '-')
  if empty(l:sign)
    return
  endif
  call s:jump_to_sign(l:sign)
endfunction

nnoremap <silent> <script> <Plug>SignJumpNextSign :call <SID>next_sign()<CR>
nnoremap <silent> <script> <Plug>SignJumpPrevSign :call <SID>prev_sign()<CR>
call s:map('n', ']s', '<Plug>SignJumpNextSign', 0)
call s:map('n', '[s', '<Plug>SignJumpPrevSign', 0)

augroup SignJumpAutoCmds
  autocmd!

  " Update after a delay to ensure all plugins modifying signs have done so
  autocmd BufEnter,BufReadPost,BufWritePost,
    \ShellCmdPost,FileChangedShellPost,
    \CursorHold,CursorHoldI
    \ * call timer_start(250, {tid -> s:update_signs(bufnr('%'))})
augroup END

command! -bar SignJumpRefresh call <SID>update_signs(bufnr('%'))

" vim: et sts=2 sw=2
