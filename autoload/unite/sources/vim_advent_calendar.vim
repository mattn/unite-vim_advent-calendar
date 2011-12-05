" define source
function! unite#sources#vim_advent_calendar#define()
  return s:source
endfunction

" cache
let s:cache = []
function! unite#sources#vim_advent_calendar#refresh()
  let s:cache = []
endfunction

" source
let s:source = {
\ 'name': 'vim_advent_calendar',
\ 'action_table': {},
\ 'default_action': {'uri': 'show'}
\}
function! s:source.gather_candidates(args, context)
  let should_refresh = a:context.is_redraw
  if should_refresh
    call unite#sources#vim_advent_calendar#refresh()
  endif

  if empty(s:cache)
    let dom = xml#parseURL('http://atnd.org/comments/21925.rss')
    for item in dom.childNode('channel').childNodes('item')
      let dom = html#parse('<div>' . item.childNode('description').value() . '</div>')
      let url = dom.find('a').attr['href']
      let desc = dom.value()
	  let desc = substitute(desc, '\n', '', 'g')
	  let desc = matchstr(desc, '^\s*\zs.\+\ze\s*$')
      for entry in entries
        call add(s:cache, {
        \ 'word':   desc,
        \ 'kind':   'uri',
        \ 'source': 'vim_advent_calendar',
        \ 'action__path': url
        \})
      endfor
      unlet item
    endfor
  endif

  return s:cache
endfunction

" action
let s:action_table = {}

let s:action_table.show = {
\   'description': 'open selected entry of vim-advent-calendar in browser'
\}

let s:source.action_table.uri = s:action_table

function! s:action_table.show.func(candidate)
  call openbrowser#open(a:candidate.action__path)
endfunction

function! s:get_vim_advent_calendar()
  return ret
endfunction
