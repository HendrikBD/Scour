let s:scourTray={}
let g:ScourTray=s:scourTray

function s:scourTray.new(manager, menu)
  let l:newTray = copy(self)
  let l:newTray.manager = a:manager
  let l:newTray.menu = a:menu
  let l:newTray.isOpen = 0
  let l:newTray.winId = -1
  " let l:newTray.menu = g:ScourMenu.new()
  
  return l:newTray
endfu

fu! s:scourTray.open()
  if !self.isOpen
    botright new
    resize 15
    cal self.manager.library.setBufOptions()
    setlocal filetype=ScourTray
    let self.isOpen = 1
    let self.winId = win_getid()
  endif
endfu

fu! s:scourTray.close()
  if self.isOpen 
    let l:prevWindow = win_getid()
    cal win_gotoid(self.winId)
    if &ft=="ScourTray"
      q
      cal win_gotoid(l:prevWindow)
    endif
  endif
endfu

fu! s:scourTray.selectLine(line)
  let l:item = self.items[a:line - 1]
  cal self.manager.closeAllWindows()
  exec 'e ' . l:item.menuTree.path
endfu

fu! s:scourTray.draw()
  if self.isOpen
    cal win_gotoid(self.winId)
    1,$delete
    cal self.drawItems()
    1delete
    cal cursor(1, 1)
  endif
endfu

fu! s:scourTray.drawItems()
  let l:items = self.getDispalyArray()
  cal self.manager.drawFromArray(l:items, 1)
endfu

fu! s:scourTray.getDispalyArray()
  let l:displayArr = []
  for l:item in self.items
    let l:displayArr += [l:item.menuTree.node.relPath]
  endfo
  return l:displayArr
endfu

fu! s:scourTray.initMenu(dataSource, type)
  let self.menu = self.manager.buildMenu(a:dataSource, a:type)
  cal self.draw()
  cal self.manager.library.setHotkeys(a:type)
endfu
