let s:save_cpo = &cpo
set cpo&vim

let s:source = {
    \ 'name'          : 'circleci',
    \ 'default_action': 'show_details',
    \ 'syntax'        : 'uniteSource__CircleCI',
    \ 'hooks'         : {},
    \ 'action_table'  : {},
    \ }

function! s:generate_word(build) abort " {{{
  let name    = a:build.reponame
  let status  = printf('[%s]', a:build.status)
  let status  = printf('%-10s', status)
  let number  = printf('#%-3s', a:build.build_num)
  let subject = a:build.subject
  if len(subject) > 20
    let subject = subject[:17] . '...'
  endif
  let subject = printf('(%s)', subject)

  let words = [
      \ status,
      \ number ,
      \ name,
      \ subject,
      \ ]
  return join(words, ' ')
endfunction " }}}

function! s:source.gather_candidates(args, context) abort " {{{
  let builds = circleci#get_recent_builds()
  return map(builds, '{
      \ "word": s:generate_word(v:val),
      \ "build": v:val,
      \ }')
endfunction " }}}

function! s:source.hooks.on_syntax(args, context) abort " {{{
  ":retried, :canceled, :infrastructure_fail, :timedout, :not_run, :running, :failed, :queued, :scheduled, :not_running, :no_tests, :fixed, :success
  syntax match uniteSource__CircleCI_Success_Status /\v\[success\]/
        \ contained containedin=uniteSource__CircleCI
  syntax match uniteSource__CircleCI_Failed_Status /\v\[failed\]/
        \ contained containedin=uniteSource__CircleCI
  syntax match uniteSource__CircleCI_Fixed_Status /\v\[fixed\]/
        \ contained containedin=uniteSource__CircleCI
  syntax match uniteSource__CircleCI_Canceled_Status /\v\[canceled\]/
        \ contained containedin=uniteSource__CircleCI
  syntax match uniteSource__CircleCI_NoTest_Status /\v\[no_tests\]/
        \ contained containedin=uniteSource__CircleCI
  syntax match uniteSource__CircleCI_Number /\v#[0-9]+/
        \ contained containedin=uniteSource__CircleCI
  syntax match uniteSource__CircleCI_Subject /\v\(.+\)/
        \ contained containedin=uniteSource__CircleCI

  highlight default link uniteSource__CircleCI_Success_Status  Statement
  highlight default link uniteSource__CircleCI_Failed_Status   QFError
  highlight default link uniteSource__CircleCI_Fixed_Status    QFWarning
  highlight default link uniteSource__CircleCI_Canceled_Status QFInfo
  highlight default link uniteSource__CircleCI_NoTest_Status   QFInfo
  highlight default link uniteSource__CircleCI_Number          Identifier
  highlight default link uniteSource__CircleCI_Subject         Comment
endfunction " }}}

let s:source.action_table.open_browser = {
      \ 'description' : 'open build url',
      \ 'is_invalidate_cache' : 1,
      \ 'is_quit' : 0,
      \ }
function! s:source.action_table.open_browser.func(candidate)
  let url = a:candidate.build.build_url
  call openbrowser#open(url)
endfunction

let s:source.action_table.show_details = {
      \ 'description' : 'show build details',
      \ }
function! s:source.action_table.show_details.func(candidate)
  let user = a:candidate.build.username
  let repo = a:candidate.build.reponame
  let num  = a:candidate.build.build_num
  execute join(['Unite circleci/build', user, repo, num], ':')
endfunction

function! unite#sources#circleci#define() abort
  return s:source
endfunction

let &cpo = s:save_cpo
unlet s:save_cpo

