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

function! signjump#get_sign(line, ...) abort
  let l:signs = getbufvar(bufnr('%'), 'signjump_signs', [])
  if empty(l:signs)
    return []
  endif
  let a:offset = get(a:, 1, '')
  let l:index = match(l:signs, 'line=\<'.a:line.'\>')
  if a:offset == '+'
    if l:index == -1
      for s in l:signs
        if signjump#get_sign_data(s, 'line') > a:line
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
        if signjump#get_sign_data(s, 'line') < a:line
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

function! signjump#next_sign() abort
  let l:sign = signjump#get_sign(line('.'), '+')
  if empty(l:sign)
    return
  endif
  call signjump#jump_to_sign(l:sign)
endfunction

function! signjump#prev_sign() abort
  let l:sign = signjump#get_sign(line('.'), '-')
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
