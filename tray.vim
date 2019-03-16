let s:scourTray={}
let g:ScourTray=s:scourTray

function s:scourTray.new(manager)
  let l:newTray = copy(self)
  let l:newTray.manager = a:manager
  let l:newTray.isOpen = 0
  
  return l:newTray
endfu

fu! s:scourTray.open()
  botright new
  resize 20
  " cal s:Window.setBufOptions()
  setlocal filetype=ScourTray
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
