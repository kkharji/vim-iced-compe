if exists('g:loaded_vim_iced_compe')
  finish
endif
let g:loaded_vim_iced_compe = 1

function! s:get_metadata() abort
  return { 'priority': 1000, 'dup': 1, 'filetypes': ['clojure'] }
endfunction

function! s:datermine(context) abort
  let [l:_, l:keyword_pattern_offset, l:__] = matchstrpos(a:context.before_line, '[[:alnum:]!$&*\-_=+:<>./?]\+$')
  if l:keyword_pattern_offset > 0
    return {
    \   'keyword_pattern_offset': l:keyword_pattern_offset
    \ }
  end
  return {}
endfunction

function! s:complete(context) abort
  if !iced#repl#is_connected()
    return
  endif

  if !iced#nrepl#check_session_validity(v:false)
    return
  endif

  call iced#complete#candidates(a:args.input, { candidates ->
  \   a:args.callback({
  \     'items': candidates
  \   })
  \ })
endfunction

let s:source = {
\   'get_metadata': function('s:get_metadata'),
\   'datermine': function('s:datermine'),
\   'complete': function('s:complete'),
\ }

call compe#source#vim_bridge#register('iced', s:source)

let &cpoptions= s:save_cpo
unlet s:save_cpo
