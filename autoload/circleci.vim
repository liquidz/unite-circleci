let s:save_cpo = &cpo
set cpo&vim

let s:V = vital#of('circleci')
let s:Http = s:V.import('Web.HTTP')
let s:Json = s:V.import('Web.JSON')

""
" @var
" CircleCI access token.
"
" Set CIRCLECI_TOKEN environmental variable
" if you don't want to set vim variable.
"
if !exists('g:circleci#token') && exists('$CIRCLECI_TOKEN')
  let g:circleci#token = $CIRCLECI_TOKEN
endif

""
" @var
" Limit count of CircleCI's recent build.
" Default value is 30, and maximum value is 100.
"
if !exists('g:circleci#recent_build_limit')
  let g:circleci#recent_build_limit = 30
endif

""
" Return CircleCI's recent builds
"
function! circleci#get_recent_builds() abort
  let resp = s:Http.get('https://circleci.com/api/v1/recent-builds',
      \ {'circle-token' : g:circleci#token,
      \  'limit': g:circleci#recent_build_limit},
      \ {'Accept': 'application/json' })
  return (resp.status !=# 200 ? [] : s:Json.decode(resp.content))
endfunction

let &cpo = s:save_cpo
unlet s:save_cpo
