let g:ScourDirNode={}

function g:ScourDirNode.new(path)
  let l:newScourDirNode = copy(self)
  let l:newScourDirNode.path = a:path
  let l:newScourDirNode.displayStr = split(a:path, '/')[-1] . '/'

  cal l:newScourDirNode.loadChildren()
  
  return l:newScourDirNode

endfu

function g:ScourDirNode.getPath()
  return self.path
endfu

function g:ScourDirNode.loadChildren()
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


fu g:ScourDirNode.getPaths()
  let l:paths = [self.path]
  let l:paths += self.getNestedPaths()

  return l:paths
endfu

fu g:ScourDirNode.getNestedPaths()
  let l:paths = []

  for i in items(self.childNodes)
    let l:paths += i[1].getPaths()
  endfo

  return l:paths
endfu

function g:ScourDirNode.drawSelected(paths)
  let l:paths = []
  for l:path in a:paths
    let l:paths += split(l:path, self.root.path)
  endfo
endf

function g:ScourDirNode.draw(indentLvl)
  let l:indent = g:ScourHelper.getIndent(a:indentLvl)
  cal append(0, l:indent . self.displayStr)
endf

function g:ScourDirNode.drawChildNodes(indentLvl, lineIndex)
  let l:lineIndex = a:lineIndex

  for l:childNode in items(self.childNodes)
    let l:lineIndex = l:childNode[1].draw(a:indentLvl, l:lineIndex)
  endfo

  return l:lineIndex
endfu


fu g:ScourDirNode.updateFilterTree(pathArr, filterTree)
  let l:filterTree = a:filterTree
  " echo a:pathArr

  if !has_key(l:filterTree, 'node')
    let l:filterTree.node = self
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
