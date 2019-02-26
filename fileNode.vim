let g:ScourFileNode={}

function g:ScourFileNode.new(path)
  let l:newScourFileNode = copy(self)
  let l:newScourFileNode.path = a:path
  let l:newScourFileNode.displayStr = split(a:path, '/')[-1]
  
  return l:newScourFileNode
endfu

function! g:ScourFileNode.getPath()
  return self.path
endfu

function! g:ScourFileNode.getPaths()
  return [self.path]
endfu

function g:ScourFileNode.renderToString(indLevel)
  let l:str = self.path . '\n'
  return l:str
endfu

function g:ScourFileNode.draw(indentLvl)
  let l:indent = g:ScourHelper.getIndent(a:indentLvl)
  cal append(0, l:indent . self.displayStr)
endfu

fu g:ScourFileNode.updateFilterTree(pathArr, filterTree)
  let l:filterTree = a:filterTree

  if !has_key(l:filterTree, 'node')
    let l:filterTree.node = self
  endif

  return l:filterTree
endfu
