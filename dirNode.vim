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

  for l:child in l:childPaths
    let self.childNodes += [g:ScourFileNode.new(child)]
  endfo
endf

let s:dir_one = ScourDirNode.new('/home/bhd-windows/.vim/homebrew/scour')
echo s:dir_one

