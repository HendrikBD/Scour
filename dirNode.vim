let g:ScourDirNode={}

function g:ScourDirNode.new(path)
  let l:newScourDirNode = copy(self)
  let l:newScourDirNode.path = a:path
  let l:newScourDirNode.displayStr = split(a:path, '/')[-1]

  cal l:newScourDirNode.loadChildren()
  
  return l:newScourDirNode

endfu

function g:ScourDirNode.getPath()
  echo self.path
endfu

function g:ScourDirNode.loadChildren()
  let l:childPaths = split(globpath(self.path, '*'), '\n')

  let self.childNodes = []

  for l:childPath in l:childPaths
    if isdirectory(l:childPath)
      let self.childNodes += [g:ScourDirNode.new(childPath)]
    el
      let self.childNodes += [g:ScourFileNode.new(childPath)]
    en
  endfo
endf


function g:ScourDirNode.draw(indentLvl, lineIndex)

  let l:lineIndex = a:lineIndex
  let l:displayStr = ''

  let l:i = 0
  while l:i < a:indentLvl
    let l:displayStr = l:displayStr . '  '
    let l:i += 1
  endw
  let l:displayStr = l:displayStr . self.displayStr

  call setline(a:lineIndex, l:displayStr)

  let l:lineIndex += 1

  for childNode in self.childNodes
    let l:lineIndex = childNode.draw(a:indentLvl + 1, l:lineIndex)
  endfo

  return l:lineIndex

endfu
