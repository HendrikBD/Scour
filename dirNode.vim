let g:ScourDirNode={}

function g:ScourDirNode.new(path)
  let l:newScourDirNode = copy(self)
  let l:newScourDirNode.path = a:path
  let l:newScourDirNode.displayStr = split(a:path, '/')[-1] . '/'

  cal l:newScourDirNode.loadChildren()
  
  return l:newScourDirNode

endfu

function g:ScourDirNode.getPath()
  echo self.path
endfu

function g:ScourDirNode.loadChildren()
  let l:childPaths = split(globpath(self.path, '*'), '\n')

  let self.childNodes = {}

  for l:childPath in l:childPaths
    if isdirectory(l:childPath)
      let self.childNodes[split(l:childPath, self.path)[0] . '/'] = g:ScourDirNode.new(l:childPath)
    el
      let self.childNodes[split(l:childPath, self.path)[0]] = g:ScourFileNode.new(l:childPath)
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


function g:ScourDirNode.draw(indentLvl, lineIndex)

  let l:lineIndex = a:lineIndex
  let l:displayStr = ''

  let l:i = 0
  while l:i < a:indentLvl
    let l:displayStr = l:displayStr . '  '
    let l:i += 1
  endw
  let l:displayStr = l:displayStr . self.displayStr . '/'

  call setline(a:lineIndex, l:displayStr)
  let l:lineIndex += 1

  return self.drawChildNodes(a:indentLvl + 1, l:lineIndex)
endfu

function g:ScourDirNode.drawChildNodes(indentLvl, lineIndex)
  let l:lineIndex = a:lineIndex

  for childNode in self.childNodes
    let l:lineIndex = childNode.draw(a:indentLvl, l:lineIndex)
  endfo

  return l:lineIndex
endfu

let s:dir = ScourDirNode.new(getcwd())
echo s:dir.getNestedPaths()
