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
    let entries = s:get_vim_advent_calendar()
    for entry in entries
      call add(s:cache, {
      \ 'word':   entry['title'],
      \ 'kind':   'uri',
      \ 'source': 'vim_advent_calendar',
      \ 'action__path': entry['url']
      \})
    endfor
    call reverse(s:cache)
  endif

  return s:cache
endfunction

" action
let s:action_table = {}

let s:action_table.show = {
\   'description': 'show selected entry of vim-advent-calendar in a buffer'
\}

let s:source.action_table.uri = s:action_table

function! s:action_table.show.func(candidate)
  call openbrowser#open(a:candidate.action__path)
endfunction

function! s:get_vim_advent_calendar_body(url)
  let content = http#get(a:url).content
  let content = matchstr(content, '\zs<body[^>]\+>.*</body>\ze')
  return content
endfunction

function! s:get_vim_advent_calendar()
  let dom = xml#parseURL('http://atnd.org/comments/21925.rss')
  let ret = []
  for item in dom.childNode('channel').childNodes('item')
    let dom = html#parse('<div>' . item.childNode('description').value() . '</div>')
    let url = dom.find('a').attr['href']
    let desc = dom.value()
	let desc = substitute(desc, '\n', '', 'g')
	let desc = matchstr(desc, '^\s*\zs.\+\ze\s*$')
    call add(ret, {'url':url, 'title':desc})
    unlet item
  endfor
  return reverse(ret)
endfunction

function! s:render(dom, pre)
  let dom = a:dom
  if type(dom) == 0 || type(dom) == 1 || type(dom) == 5
    let html = html#decodeEntityReference(dom)
    let html = substitute(html, '\r', '', 'g')
    if a:pre == 0
      let html = substitute(html, '\n\+\s*', '', 'g')
    endif
    let html = substitute(html, '\t', '  ', 'g')
    return html
  elseif type(dom) == 3
    let html = ''
    for d in dom
      let html .= s:render(d, a:pre)
      unlet d
    endfor
    return html
  elseif type(dom) == 4
    if empty(dom)
      return ""
    endif
    if dom.name != 'script' && dom.name != 'style' && dom.name != 'head'
      let html = s:render(dom.child, a:pre || dom.name == 'pre')
      if dom.name =~ '^h[1-6]$' || dom.name == 'br' || dom.name == 'dt' || dom.name == 'dl' || dom.name == 'li' || dom.name == 'p'
        let html = "\n".html."\n"
      endif
      if dom.name == 'pre' || dom.name == 'blockquote'
        let html = "\n  ".substitute(html, "\n", "\n  ", 'g')."\n"
      endif
      return html
    endif
    return ''
  endif
endfunction
