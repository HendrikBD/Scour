let s:scourFileNode = {}
let g:ScourFileNode = s:scourFileNode

function s:scourFileNode.new(path, manager)
  let l:newScourFileNode = copy(self)
  let l:newScourFileNode.path = a:path
  let l:newScourFileNode.manager = a:manager
  let l:newScourFileNode.displayStr = split(a:path, '/')[-1]
  let l:newScourFileNode.searchStr = join(split(a:path, '/')[-2:-1], '/')

  let l:newScourFileNode.isDir = 0
  
  return l:newScourFileNode
endfu

function! s:scourFileNode.getPath()
  return self.path
endfu

" function! s:scourFileNode.getPaths(allPaths)
"   return [self.path]
" endfu

function! s:scourFileNode.getPaths(allPaths)
  return [self.path]
endfu

function s:scourFileNode.renderToString(indLevel)
  let l:str = self.path . '\n'
  return l:str
endfu

function s:scourFileNode.draw(indentLvl)
  let l:indent = g:ScourHelper.getIndent(a:indentLvl)
  cal append(51, l:indent . self.displayStr)
endfu

fu s:scourFileNode.updateFilterTree(pathArr, filterTree)
  let l:filterTree = a:filterTree

  if len(items(filterTree)) > 0
    let l:filterTree = self
  endif

  return l:filterTree
endfu

fu s:scourFileNode.getDisplayString(...)
  if exists('a:1')
    if a:1.fullPath
      let l:displayStr =  self.manager.scour.root.displayStr . split(self.path, self.manager.scour.root.path . '/')[0]
      return l:displayStr
    endif
  endif

  return self.displayStr
endfu

fu! s:scourFileNode.getSearchStrings()
  return [self.searchStr]
endfu
