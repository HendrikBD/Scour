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

function g:ScourFileNode.renderToString(indLevel)
  let l:str = self.path . '\n'
  return l:str
endfu

function g:ScourFileNode.draw(indentLvl, lineIndex)
  let l:displayStr = ''

  let l:i = 0
  while l:i < a:indentLvl
    let l:displayStr = l:displayStr . '  '
    let l:i += 1
  endw
  let l:displayStr = l:displayStr . self.displayStr

  call setline(a:lineIndex, l:displayStr)

  let l:lineIndex = a:lineIndex
  let l:lineIndex += 1
  return l:lineIndex
endfu
