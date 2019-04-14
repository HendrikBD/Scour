let s:scourShelf={}
let g:ScourShelf=s:scourShelf

function s:scourShelf.new(manager, menu)
  let l:newShelf = copy(self)
  let l:newShelf.manager = a:manager
  let l:newShelf.menu = a:menu
  let l:newShelf.isOpen = 0
  let l:newShelf.winId = -1

  let l:newShelf.header = ['Scour', 'A directory browser or something', '']
  
  return l:newShelf
endfu

fu! s:scourShelf.open()
  if !self.isOpen 
    vert topleft vnew
    vertical resize 40
    cal self.manager.library.setBufOptions()
    setlocal filetype=ScourShelf
  endif
  let self.isOpen = 1
  let self.winId = win_getid()
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

fu! s:scourShelf.select(line)
  " Check line map to find menuItem
  " if dir
  "   if collapasble, set all menuTrees to collapsable = 0
  "   if closed open (if open close)
  "   redraw menu (both windows if applicable)
  " if not dir, open file
endfu

fu! s:scourShelf.draw()
  if self.isOpen
    1,$delete
    cal win_gotoid(self.winId)
    cal self.drawHeader()
    cal self.drawItems()
    1delete
  endif
endfu

fu! s:scourShelf.drawHeader()
  cal self.manager.drawFromArray(self.header)
endfu

fu! s:scourShelf.updateLineMap()
endfu

fu! s:scourShelf.drawItems()
  let l:items = self.getDispalyArray()
  cal self.manager.drawFromArray(l:items, len(self.header) + 1)
endfu

fu! s:scourShelf.getDispalyArray()
  let l:displayArr = []
  for l:item in self.items
    let l:indent = self.manager.library.getIndentFromPath(l:item.menuTree.path)
    let l:displayArr += [l:indent . l:item.displayStr]
  endfo
  return l:displayArr
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
