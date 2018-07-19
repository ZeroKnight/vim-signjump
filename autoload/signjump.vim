if exists('g:autoloaded_signjump') || &compatible
  finish
endif
let g:autoloaded_signjump = 1

function! s:err(msg) abort
  redraw | echohl Error | echom a:msg | echohl None
endfunction

" Given an index and the length of a List, return the index bounded by the range
" [0, length)
function! s:bound(idx, len) abort
  return min([max([0, a:idx]), a:len - 1])
endfunction

function! s:should_wrap() abort
  let l:wrap = g:signjump.wrap
  if l:wrap > 0
    return l:wrap == 2 ? 1 : &wrapscan
  else
    return 0
  endif
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

function! s:nearest_sign_idx(signs, line, direction) abort
  if a:direction ==# '+'
    let l:idx = -1
    for l:s in a:signs
      if signjump#get_sign_data(l:s, 'line') > a:line
        break
      endif
      let l:idx += 1
    endfor
  elseif a:direction ==# '-'
    let l:idx = len(a:signs)
    for l:s in reverse(copy(a:signs))
      if signjump#get_sign_data(l:s, 'line') < a:line
        break
      endif
      let l:idx -= 1
    endfor
  endif
  return l:idx
endfunction

function! signjump#get_sign(line, offset, ...) abort
  let l:count = a:0 ? a:1 : 1
  let l:signs = signjump#get_buffer_signs(bufnr('%'))
  if empty(l:signs)
    return []
  endif
  let l:index = match(l:signs, '\vline\=<'.a:line.'>')
  if l:index == -1
    let l:index = s:nearest_sign_idx(l:signs, a:line, a:offset)
  endif
  let l:delta = eval('l:index'.a:offset.'l:count')
  if s:should_wrap()
    let l:index = l:delta % len(l:signs)
  else
    let l:index = s:bound(l:delta, len(l:signs))
  endif
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
  let l:ln = line('.')
  let l:sign = signjump#get_sign(l:ln, '+', l:count)
  if !empty(l:sign)
    call signjump#jump_to_sign(l:sign)
    if signjump#get_sign_data(l:sign, 'line') < l:ln
      \ && stridx(&shortmess, 's')
      call s:err('search hit BOTTOM, continuing at TOP')
    endif
  endif
endfunction

function! signjump#prev_sign(...) abort
  let l:count = a:0 ? a:1 : 1
  let l:ln = line('.')
  let l:sign = signjump#get_sign(l:ln, '-', l:count)
  if !empty(l:sign)
    call signjump#jump_to_sign(l:sign)
    if signjump#get_sign_data(l:sign, 'line') > l:ln
      \ && stridx(&shortmess, 's')
      call s:err('search hit TOP, continuing at BOTTOM')
    endif
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
