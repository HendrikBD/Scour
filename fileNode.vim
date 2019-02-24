let g:ScourFileNode={}

function g:ScourFileNode.new(path)
  let l:newScourFileNode = copy(self)
  let l:newScourFileNode.path = a:path
  
  return l:newScourFileNode

endfu

function g:ScourFileNode.getPath()
  echo self.path
endfu


let s:file_one = ScourFileNode.new('/home/bhd-windows/.vim/homebrew/scour')

" call s:file_one.getPath()
