let s:scourShelf={}
let g:ScourShelf=s:scourShelf

function s:scourShelf.new(manager)
  let l:newShelf = copy(self)
  let l:newShelf.manager = a:manager
  let l:newShelf.isOpen = 0
  let l:newShelf.winId = -1
  
  return l:newShelf
endfu

fu! s:scourShelf.open()
  vert topleft vnew
  vertical resize 40
  cal self.manager.setBufOptions()
  setlocal filetype=ScourShelf
endfu

fu! s:scourShelf.close()
  if self.isOpen 
    let l:prevWindow = win_getid()
    cal win_gotoid(self.winId)
    if &ft="ScourShelf"
      q
      cal win_gotoid(l:prevWindow)
    endif
  endif
endfu
