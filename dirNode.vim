let g:ScourDirNode={}

function g:ScourDirNode.new(path)
  let l:newScourDirNode = copy(self)
  let l:newScourDirNode.path = a:path

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

  call setline(a:lineIndex, self.path)
  echo l:lineIndex

  let l:lineIndex += 1

  for childNode in self.childNodes
    let l:lineIndex = childNode.draw(0, l:lineIndex)
  endfo

  return l:lineIndex

endfu

let g:dir_one = ScourDirNode.new('/home/bhd-windows/.vim/homebrew/scour')
