let s:scourLibrary={}
let g:ScourLibrary=s:scourLibrary

fu! s:scourLibrary.new(manager)
  let l:newLibrary = copy(self)
  let l:newLibrary.manager = a:manager

  return l:newLibrary
endfu

" FUNCTION: s:Creator._setCommonBufOptions() {{{1
function! s:scourLibrary.setBufOptions()

    " Options for a non-file/control buffer.
    setlocal bufhidden=hide
    setlocal buftype=nofile
    setlocal noswapfile

    " Options for controlling buffer/window appearance.
    setlocal foldcolumn=0
    setlocal foldmethod=manual
    setlocal nobuflisted
    setlocal nofoldenable
    setlocal nolist
    setlocal nospell
    setlocal nowrap

    iabc <buffer>

endfunction

" Return an indent based on a passed indent level
"
fu s:scourLibrary.getIndent(indentLvl)
  let l:indent = ''
  let l:i = 0
  while l:i < a:indentLvl
    let l:indent = l:indent . '  '
    let l:i += 1
  endw
  return l:indent
endf


" Splices the path to find the appropriate index for a given path
"
fu s:scourLibrary.getIndentFromPath(path)
  let l:padding = 2

  let l:root = self.manager.scour.root
  if l:root.path == a:path
    return self.getIndent(l:padding)
  endif

  let l:relPath = split(a:path, l:root.path)[0]
  if l:relPath == a:path
    return self.getIndent(l:padding)
  endif

  let l:indentLvl = len(split(l:relPath, '/'))
  return self.getIndent(l:indentLvl + l:padding)
endf


fu s:scourLibrary.setHotkeys()
  nnoremap <silent> <buffer> <CR> :cal g:Scour.manager.select()<CR>
  nnoremap <silent> <buffer> <Esc> :cal g:Scour.manager.closeAllWindows()<CR>
endfu

fu s:scourLibrary.stringifyArray(array)
  let l:stringified = []

  for l:item in a:array
    let l:stringified += self.stringifyObject(l:item)
  endfo

  return l:stringified
endfu

fu s:scourLibrary.stringifyObject(obj)
  let l:itemType = type(a:obj)
  let l:stringified = []

  if l:itemType == 0
    let l:stringified += ['' . a:obj]
  elseif l:itemType == 1
    let l:stringified += [a:obj]
  elseif l:itemType == 2
    let l:stringified += ['func()']
  elseif l:itemType == 3
    for l:item in a:obj
      let l:stringified += ['[']
      let l:stringified += self.stringifyObject(l:item)
      let l:stringified += ['],']
    endfo
  elseif l:itemType == 4
    for l:key in keys(a:obj)
      let l:stringified += [l:key . ' {']
      let l:stringified += self.stringifyObject(a:obj[l:key])
      let l:stringified += ['}']
    endfo
  elseif l:itemType == 6
    let l:stringified += ['true']
  endif

  return l:stringified

endfu


fu s:scourLibrary.getIgnoredDirs()
  let l:ignoreDirs = ['.git', 'node_modules']
  return l:ignoreDirs
endfu
