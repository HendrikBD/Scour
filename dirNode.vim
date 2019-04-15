let s:dirNode = {}
let g:ScourDirNode = s:dirNode

function s:dirNode.new(path, manager, ...)
  let l:newScourDirNode = copy(self)
  let l:newScourDirNode.path = a:path
  let l:newScourDirNode.manager = a:manager
  let l:newScourDirNode.displayStr = split(a:path, '/')[-1] . '/'

  if exists('a:manager.scour.root')
    let l:newScourDirNode.searchStr = split(a:path, '/')[-1]
  el
    let l:newScourDirNode.searchStr = join(split(a:path, '/')[-2:-1], '/')
  endif

  if exists('a:1')
    let l:newScourDirNode.isRoot = 0
    let l:newScourDirNode.relPath = split(a:1, '/')[-1] . split(a:path, a:1)[-1]
    cal l:newScourDirNode.loadChildren(a:manager, a:1)
  else
    let l:newScourDirNode.isRoot = 1
    let l:newScourDirNode.relPath = split(a:path, '/')[-1]
    cal l:newScourDirNode.loadChildren(a:manager, l:newScourDirNode.path)
  endif

  let l:newScourDirNode.isOpen = 0
  let l:newScourDirNode.isDir = 1
  
  return l:newScourDirNode

endfu

function s:dirNode.loadChildren(manager, rootPath)
  let l:childPaths = split(globpath(self.path, '*'), '\n')

  let self.childNodes = {}

  for l:childPath in l:childPaths

    if isdirectory(l:childPath)
      let l:localPath = split(l:childPath, self.path . '/')[0]
      if !self.manager.isIgnoredDir(l:localPath)
        let self.childNodes[l:localPath] = g:ScourDirNode.new(l:childPath, a:manager, a:rootPath)
      endif
    el
      let self.childNodes[split(l:childPath, self.path . '/')[0]] = g:ScourFileNode.new(l:childPath, a:manager, a:rootPath)
    en

  endfo

endf


function s:dirNode.getPath()
  return self.path
endfu


fu s:dirNode.getPaths(allPaths)
  let l:paths = [self.path]
  if self.isOpen || a:allPaths
    let l:paths += self.getNestedPaths(a:allPaths)
  endif

  return l:paths
endfu

fu s:dirNode.getSearchStrings()
  let l:searchStr = [self.searchStr]
  let l:searchStr += self.getNestedPaths()

  return l:searchStr
endfu

fu s:dirNode.getNestedPaths(allPaths)
  let l:paths = []

  for i in items(self.childNodes)
    let l:paths += i[1].getPaths(a:allPaths)
  endfo

  return l:paths
endfu

fu s:dirNode.getDisplayString(...)
  if exists('a:1') && (self.manager.scour.root.path != self.path)
    if a:1.fullPath
      let l:displayStr =  self.manager.scour.root.displayStr . split(self.path, self.manager.scour.root.path . '/')[0]
      return l:displayStr
    endif
  endif

  return self.displayStr
endfu


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

fu s:dirNode.getNodeStruct()
  let l:structInfo = [{'path': self.path, 'isDir': self.isDir, 'isOpen': self.isOpen}]

  if has_key(self, 'childNodes')
    for l:child in keys(self.childNodes)
      let l:childNode = self.childNodes[l:child]
      if l:childNode.isDir
        let l:structInfo += l:childNode.getNodeStruct()
      else
        let l:structInfo += [{'path': l:childNode.path, 'isDir': l:childNode.isDir}]
      endif
    endfo
  endif

  return l:structInfo
endfu
