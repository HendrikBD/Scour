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
  if !self.isOpen 
    vert topleft vnew
    vertical resize 40
    cal self.manager.library.setBufOptions()
    setlocal filetype=ScourShelf
  endif
endfu

fu! s:scourShelf.close()
  if self.isOpen 
    let l:prevWindow = win_getid()
    cal win_gotoid(self.winId)
    if &ft=="ScourShelf"
      q
      cal win_gotoid(l:prevWindow)
    endif
  endif
endfu

fu! s:scourShelf.draw()
  if self.isOpen
    cal win_gotoid(self.winId)
    cal self.menu.draw()
  endif
endfu

fu! s:scourShelf.initMenu(dataSource, type)
  let self.menu = self.manager.buildMenu(a:dataSource, a:type)
  cal self.draw()
  cal self.manager.library.setHotkeys(a:type)
endfu

fu! s:scourShelf.updateFromFilter()
  let l:filtered = self.manager.filterAll()
  cal self.menu.updateDataSource({'type': 'list', 'data': l:filtered})
  cal self.draw()
endfu
