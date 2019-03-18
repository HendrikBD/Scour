let s:dirNode = {}
let g:ScourDirNode = s:dirNode

function s:dirNode.new(path)
  let l:newScourDirNode = copy(self)
  let l:newScourDirNode.path = a:path
  let l:newScourDirNode.displayStr = split(a:path, '/')[-1] . '/'

  let l:newScourDirNode.isOpen = 0
  let l:newScourDirNode.isDir = 1

  cal l:newScourDirNode.loadChildren()
  
  return l:newScourDirNode

endfu

function s:dirNode.loadChildren()
  let l:childPaths = split(globpath(self.path, '*'), '\n')

  let self.childNodes = {}

  for l:childPath in l:childPaths
    if isdirectory(l:childPath)
      let self.childNodes[split(l:childPath, self.path . '/')[0]] = g:ScourDirNode.new(l:childPath)
    el
      let self.childNodes[split(l:childPath, self.path . '/')[0]] = g:ScourFileNode.new(l:childPath)
    en
  endfo
endf


function s:dirNode.getPath()
  return self.path
endfu

" fu s:dirNode.getPaths()
"   let l:paths = [self.path]
"   let l:paths += self.getNestedPaths()
"
"   return l:paths
" endfu
"
" fu s:dirNode.getNestedPaths()
"   let l:paths = []
"
"   for i in items(self.childNodes)
"     let l:paths += i[1].getPaths()
"   endfo
"
"   return l:paths
" endfu

fu s:dirNode.getPaths(allPaths)
  let l:paths = [self.path]
  if self.isOpen || a:allPaths
    let l:paths += self.getNestedPaths(a:allPaths)
  endif

  return l:paths
endfu

fu s:dirNode.getNestedPaths(allPaths)
  let l:paths = []

  for i in items(self.childNodes)
    let l:paths += i[1].getPaths(a:allPaths)
  endfo

  return l:paths
endfu

fu s:dirNode.getDisplayString()
  if self == g:Scour.root
    return self.displayStr
  el
    let l:indent = g:ScourHelper.getIndent(len(split(split(self.path, g:Scour.root.path)[0], '/')))
    return l:indent . self.displayStr
  endif
endfu

" function s:dirNode.drawSelected(paths)
"   let l:paths = []
"   for l:path in a:paths
"     let l:paths += split(l:path, self.root.path)
"   endfo
" endf


fu s:dirNode.updateFilterTree(pathArr, filterTree)
  let l:filterTree = a:filterTree

  if len(items(filterTree)) > 0
    let l:filterTree = self
  endif

  if !has_key(l:filterTree, 'childNodes') && len(a:pathArr) > 0
    let l:filterTree.childNodes = {}
  endif

  if len(a:pathArr) > 0
    if !has_key(l:filterTree.childNodes, a:pathArr[0])
      let l:filterTree.childNodes[a:pathArr[0]] = {}
    endif

    let l:filterTree.childNodes[a:pathArr[0]]  = self.childNodes[a:pathArr[0]].updateFilterTree(a:pathArr[1:], l:filterTree.childNodes[a:pathArr[0]])
  endif

  return l:filterTree
endfu

fu s:dirNode.getNodeFromPath(path)
  if a:path == self.path
    return self
  el
    let l:childPath = split(split(a:path, self.path)[0], '/')[0]
    if has_key(self.childNodes, l:childPath)
      if isdirectory(self.path . '/' . l:childPath)
        return self.childNodes[l:childPath].getNodeFromPath(a:path)
      el
        return self.childNodes[split(l:childPath, self.path)[0]]
      endif
    el
      echoerr "Error: No node found with path: " . split(l:childPath, self.path)[0]
    endif

  endif
endfu
