if exists('g:autoloaded_signjump') || &compatible
  finish
endif
let g:autoloaded_signjump = 1

function! s:bound(idx, len) abort
  return min([max([0, a:idx]), a:len - 1])
endfunction

" Typical ':sign place' line:
" line=25  id=3007  name=FooSign
function! signjump#get_buffer_signs(buffer) abort
  " Ensure :sign place can be parsed in all locales
  let l:lang_save = v:lang
  if v:lang !=# 'C'
    silent language messages C
  endif

  let l:out =
    \ filter(
    \   split(execute('sign place buffer='.a:buffer, 'silent'), '\n'),
    \ "v:val =~# '='")
  call map(l:out, 'v:val[4:]') " Trim indent
  call sort(l:out, {a, b ->
    \ str2nr(matchlist(a, '\vline\=(\d+)')[1]) <
    \ str2nr(matchlist(b, '\vline\=(\d+)')[1]) ? -1 : 1 })

  if g:signjump.debug
    echom 'Got' len(l:out) 'signs for buffer' bufname(a:buffer)
  endif
  if l:lang_save !=# 'C'
    execute 'silent language messages' l:lang_save
  endif
  return l:out
endfunction

function! signjump#get_sign_data(sign, item) abort
  return matchlist(a:sign, a:item.'\v\=(\d+)')[1]
endfunction

function! signjump#get_sign(line, offset, ...) abort
  let l:count = a:0 ? a:1 : 1
  let l:signs = signjump#get_buffer_signs(bufnr('%'))
  if empty(l:signs)
    return []
  endif
  let l:index = match(l:signs, '\vline\=<'.a:line.'>')
  if l:index == -1
    if a:offset == '+'
      call filter(l:signs, {idx, val ->
        \ signjump#get_sign_data(val, 'line') > a:line})
    elseif a:offset == '-'
      call filter(l:signs, {idx, val ->
        \ signjump#get_sign_data(val, 'line') < a:line})
      let l:index = len(l:signs)
    endif
  endif
  let l:index = s:bound(eval('l:index'.a:offset.'l:count'), len(l:signs))
  return split(l:signs[l:index], '  ')
endfunction

function! signjump#jump_to_sign(sign) abort
  let l:from = line('.')
  if g:signjump.use_jumplist
    execute 'normal!' signjump#get_sign_data(a:sign, 'line') . 'G'
  else
    execute 'sign jump' signjump#get_sign_data(a:sign, 'id')
      \ 'buffer=' . bufnr('%')
  endif

  if g:signjump.debug
    echom 'Jumping to sign:' string(a:sign) . ', from line' l:from
  endif
endfunction

function! signjump#next_sign(...) abort
  let l:count = a:0 ? a:1 : 1
  let l:sign = signjump#get_sign(line('.'), '+', l:count)
  if !empty(l:sign)
    call signjump#jump_to_sign(l:sign)
  endif
endfunction

function! signjump#prev_sign(...) abort
  let l:count = a:0 ? a:1 : 1
  let l:sign = signjump#get_sign(line('.'), '-', l:count)
  if !empty(l:sign)
    call signjump#jump_to_sign(l:sign)
  endif
endfunction

function! signjump#first_sign() abort
  let l:signs = signjump#get_buffer_signs(bufnr('%'))
  if !empty(l:signs)
    call signjump#jump_to_sign(l:signs[0])
  endif
endfunction

function! signjump#last_sign() abort
  let l:signs = signjump#get_buffer_signs(bufnr('%'))
  if !empty(l:signs)
    call signjump#jump_to_sign(l:signs[-1])
  endif
endfunction

" vim: et sts=2 sw=2
