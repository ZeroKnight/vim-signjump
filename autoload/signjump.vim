if exists('g:autoloaded_signjump') || &compatible
  finish
endif
let g:autoloaded_signjump = 1

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

function! s:match_name(list, val) abort
  let l:name = matchlist(a:val, '\vname\=(.+)')[1]
  return l:name =~# join(a:list, '\|')
endfunction

" Typical ':sign place' line:
" line=25  id=3007  name=FooSign
function! signjump#get_buffer_signs(buffer, names) abort
  " Ensure :sign place can be parsed in all locales
  let l:lang_save = v:lang
  if v:lang !=# 'C'
    silent language messages C
  endif

  let l:out =
    \ filter(
    \   split(execute('sign place group=* buffer='.a:buffer, 'silent'), '\n'),
    \   {idx, val ->
    \     val =~# '=' && (!empty(a:names) ? s:match_name(a:names, val) : 1)})
  call map(l:out, 'v:val[4:]') " Trim indent
  call sort(l:out, {a, b ->
    \ str2nr(matchlist(a, '\vline\=(\d+)')[1]) <
    \ str2nr(matchlist(b, '\vline\=(\d+)')[1]) ? -1 : 1 })

  if g:signjump.debug
    echom 'Got' len(l:out) 'signs for buffer' bufname(a:buffer) 'matching'
      \ string(a:names)
  endif
  if l:lang_save !=# 'C'
    execute 'silent language messages' l:lang_save
  endif
  return l:out
endfunction

function! signjump#get_sign_data(sign, item) abort
  return get(matchlist(a:sign, a:item.'\v\=(\w+)'), 1, "")
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

function! signjump#get_sign(line, offset, names, ...) abort
  let l:count = get(a:, 1, 1)
  let l:signs = signjump#get_buffer_signs(bufnr('%'), a:names)
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
    let l:group = signjump#get_sign_data(a:sign, 'group')
    let l:id = signjump#get_sign_data(a:sign, 'id')
    if l:group == ""
      execute 'sign jump ' l:id  'buffer=' . bufnr('%')
    else
      execute 'sign jump ' . l:id .  ' group=' . l:group . ' buffer=' . bufnr('%')
    endif
  endif

  if g:signjump.debug
    echom 'Jumping to sign:' string(a:sign) . ', from line' l:from
  endif
endfunction

" NOTE: These jump functions *must* return non-zero, otherwise @= will move the
" cursor to column 1 after evaluation for some reason.

function! signjump#next_sign(...) abort
  let l:names = get(a:, 1, [])
  let l:count = get(a:, 2, v:count1)
  let l:ln = line('.')
  let l:sign = signjump#get_sign(l:ln, '+', l:names, l:count)
  if !empty(l:sign)
    call signjump#jump_to_sign(l:sign)
    if signjump#get_sign_data(l:sign, 'line') < l:ln
      \ && stridx(&shortmess, 's')
      echoerr 'search hit BOTTOM, continuing at TOP'
    endif
  endif
  return 1
endfunction

function! signjump#prev_sign(...) abort
  let l:names = get(a:, 1, [])
  let l:count = get(a:, 2, v:count1)
  let l:ln = line('.')
  let l:sign = signjump#get_sign(l:ln, '-', l:names, l:count)
  if !empty(l:sign)
    call signjump#jump_to_sign(l:sign)
    if signjump#get_sign_data(l:sign, 'line') > l:ln
      \ && stridx(&shortmess, 's')
      echoerr 'search hit TOP, continuing at BOTTOM'
    endif
  endif
  return 1
endfunction

function! signjump#first_sign(...) abort
  let l:names = get(a:, 1, [])
  let l:signs = signjump#get_buffer_signs(bufnr('%'), l:names)
  if !empty(l:signs)
    call signjump#jump_to_sign(l:signs[0])
  endif
  return 1
endfunction

function! signjump#last_sign(...) abort
  let l:names = get(a:, 1, [])
  let l:signs = signjump#get_buffer_signs(bufnr('%'), l:names)
  if !empty(l:signs)
    call signjump#jump_to_sign(l:signs[-1])
  endif
  return 1
endfunction

function! signjump#create_map(map, action, names) abort
  if a:action !~? '\vnext|prev|first|last'
    echoerr expand('<sfile>') . ": action argument must be one of: " .
      \ "'next', 'prev', 'first' or 'last'"
    return
  endif
  execute 'nnoremap <silent>' a:map
    \ '@=signjump#'.tolower(a:action).'_sign('.string(a:names).', 1)<CR>'
  execute 'xnoremap <silent>' a:map
    \ '@=signjump#'.tolower(a:action).'_sign('.string(a:names).', 1)<CR>'
endfunction

" vim: et sts=2 sw=2
