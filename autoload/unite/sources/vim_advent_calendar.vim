scriptencoding utf-8

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
\ 'default_action': {'uri': 'open'}
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
	  let desc = matchstr(substitute(dom.value(), '\n', '', 'g'), '^\s*\zs.\+\ze\s*$')
      if desc !~ '【'
        continue
      endif
      let uri = dom.find('a').attr['href']
      call add(s:cache, {
      \ 'word':   desc,
      \ 'kind':   'uri',
      \ 'source': 'vim_advent_calendar',
      \ 'action__path': uri
      \})
      unlet item
    endfor
  endif

  return s:cache
endfunction

" action
let s:action_table = {}

let s:action_table.open = {
\   'description': 'open selected entry of vim-advent-calendar in browser'
\}

let s:source.action_table.uri = s:action_table

function! s:action_table.open.func(candidate)
  call openbrowser#open(a:candidate.action__path)
endfunction
