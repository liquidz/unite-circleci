let s:save_cpo = &cpo
set cpo&vim

let s:source = {
    \ 'name'          : 'circleci/build',
    \ 'default_kind'  : 'word',
    \ 'default_action': 'yank',
    \ 'syntax'        : 'uniteSource__CircleCI_Build',
    \ 'hooks'         : {},
    \ }

function! s:source.gather_candidates(args, context) abort " {{{
  if len(a:args) !=# 3
    throw 'circleci/build requires 3 arguments(username, project, build_num)'
  endif

  let username  = a:args[0]
  let project   = a:args[1]
  let build_num = a:args[2]

  let detail = circleci#get_build_details(
      \ username, project, build_num)

  return map(g:circleci#build_detail_keys, '{
      \ "word": v:val . ": " . detail[v:val],
      \ }')
endfunction " }}}

function! s:source.hooks.on_syntax(args, context) abort " {{{
  syntax match uniteSource__CircleCI_Build_Key /\v.+: /
        \ contained containedin=uniteSource__CircleCI_Build
  highlight default link uniteSource__CircleCI_Build_Key Identifier
endfunction " }}}

function! unite#sources#circleci_build#define() abort
  return s:source
endfunction

let &cpo = s:save_cpo
unlet s:save_cpo

