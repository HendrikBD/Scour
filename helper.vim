
let s:helper = {}
let g:ScourHelper=s:helper

fu s:helper.getIndent(indentLvl)
  let l:indent = ''
  let l:i = 0
  while l:i < a:indentLvl
    let l:indent = l:indent . '  '
    let l:i += 1
  endw
  return l:indent
endf
