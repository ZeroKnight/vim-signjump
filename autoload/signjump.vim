scriptencoding utf-8

if exists('g:autoloaded_signjump') || !has('signs')
  finish
endif
let g:autoloaded_signjump = 1

function! signjump#opt(var) abort
  execute 'return g:signjump_' . a:var
endfunction

function! signjump#get_sign_data(sign, item) abort
  return matchlist(a:sign, a:item.'=\(\d\+\)')[1]
endfunction

function! signjump#get_sign(line, offset, ...) abort
  let l:count = a:0 ? a:1 : 1
  let l:signs = getbufvar(bufnr('%'), 'signjump_signs', [])
  if empty(l:signs)
    return []
  endif
  let l:index = match(l:signs, 'line=\<'.a:line.'\>')
  if a:offset == '+'
    if l:index == -1
      for s in l:signs
        if signjump#get_sign_data(s, 'line') > a:line
          let l:index = index(l:signs, s) - 1
          break
        endif
      endfor
    endif
    let l:index += l:count
  elseif a:offset == '-'
    if l:index == -1
      for s in reverse(copy(l:signs))
        if signjump#get_sign_data(s, 'line') < a:line
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

function! signjump#jump_to_sign(sign) abort
  let l:from = line('.')
  if signjump#opt('use_jumplist')
    execute 'normal' signjump#get_sign_data(a:sign, 'line') . 'G'
  else
    execute 'sign jump' signjump#get_sign_data(a:sign, 'id')
      \ 'buffer=' . bufnr('%')
  endif

  if signjump#opt('debug')
    echom 'Jumping to sign:' string(a:sign) . ', from line' l:from
  endif
endfunction

function! signjump#next_sign(...) abort
  let l:count = a:0 ? a:1 : 1
  let l:sign = signjump#get_sign(line('.'), '+', l:count)
  if empty(l:sign)
    return
  endif
  call signjump#jump_to_sign(l:sign)
endfunction

function! signjump#prev_sign(...) abort
  let l:count = a:0 ? a:1 : 1
  let l:sign = signjump#get_sign(line('.'), '-', l:count)
  if empty(l:sign)
    return
  endif
  call signjump#jump_to_sign(l:sign)
endfunction

function! signjump#first_sign() abort
  let l:signs = getbufvar(bufnr('%'), 'signjump_signs', [])
  call signjump#jump_to_sign(l:signs[0])
endfunction

function! signjump#last_sign() abort
  let l:signs = getbufvar(bufnr('%'), 'signjump_signs', [])
  call signjump#jump_to_sign(l:signs[-1])
endfunction
