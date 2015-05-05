let s:suite  = themis#suite('unite-circleci')
let s:assert = themis#helper('assert')

function! s:suite.foo_test() abort
  call s:assert.equals(1 + 2, 3)
endfunction
