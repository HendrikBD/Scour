let g:ScourFileNode={}

function g:ScourFileNode.new(path)
  let l:newScourFileNode = copy(self)
  let l:newScourFileNode.path = a:path
  
  return l:newScourFileNode

endfu

function! g:ScourFileNode.getPath()
  return self.path
endfu

function g:ScourFileNode.renderToString(indLevel)
  let l:str = self.path . '\n'
  return l:str
endfu

function g:ScourFileNode.draw(indentLvl, lineIndex)
  call setline(a:lineIndex, self.path)
  echo a:lineIndex

  let l:lineIndex = a:lineIndex
  let l:lineIndex += 1
  return l:lineIndex
endfu
