if exists('g:loaded_vim_iced_compe')
  finish
endif
let g:loaded_vim_iced_compe = 1

function! s:get_metadata() abort
  return { 'priority': 1000, 'dup': 1, 'filetypes': ['clojure'] }
endfunction

function! s:datermine(context) abort
  let l:offset = compe#pattern#get_offset(a:context, '[[:alnum:]!$&*\-_=+:<>./?]\+$')
  if l:offset > 0
    return {
    \   'keyword_pattern_offset': l:offset,
    \   'trigger_character_offset': index(['/'], a:context.before_char) >= 0 ? a:context.col : -1
    \ }
  end
  return {}
endfunction

function! s:complete(args) abort
  if !iced#repl#is_connected()
    return a:args.abort()
  endif

  if !iced#nrepl#check_session_validity(v:false)
    return a:args.abort()
  endif

  call iced#complete#candidates(a:args.input, { candidates ->
  \   a:args.callback({
  \     'items': candidates
  \   })
  \ })
endfunction

function! s:documentation(args) abort
  let l:completed_item = a:args.completed_item
  if empty(get(l:completed_item, 'info', ''))
    return a:args.abort()
  endif
  call a:args.callback(split(l:completed_item.info, "\n", v:true))
endfunction

let s:source = {
\   'get_metadata': function('s:get_metadata'),
\   'datermine': function('s:datermine'),
\   'complete': function('s:complete'),
\   'documentation': function('s:documentation')
\ }

call compe#register_source('iced', s:source)
