let s:scourTray={}
let g:ScourTray=s:scourTray

function s:scourTray.new(manager)
  let l:newTray = copy(self)
  let l:newTray.manager = a:manager
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
  endif
endfu

fu! s:scourTray.close()
  if self.isOpen 
    let l:prevWindow = win_getid()
    cal win_gotoid(self.winId)
    if &ft="ScourTray"
      q
      cal win_gotoid(l:prevWindow)
    endif
  endif
endfu

fu! s:scourTray.draw()
  if self.isOpen
    cal win_gotoid(self.winId)
    cal self.menu.draw()
  endif
endfu
