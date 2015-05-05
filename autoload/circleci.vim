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

function! s:call_api(path, param) abort
  let url = 'https://circleci.com/api/v1' . a:path
  let param = copy(a:param)
  let param['circle-token'] = g:circleci#token

  return s:Http.get(url, param, {'Accept': 'application/json' })
endfunction

""
" Return CircleCI's recent builds
"
function! circleci#get_recent_builds() abort
  let resp = s:call_api('/recent-builds', {
      \ 'limit': g:circleci#recent_build_limit,
      \ })
  return (resp.status !=# 200 ? [] : s:Json.decode(resp.content))
endfunction

let &cpo = s:save_cpo
unlet s:save_cpo
