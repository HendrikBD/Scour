so  /home/bhd-windows/.vim/homebrew/scour/library.vim


let s:scourManager={}
let g:ScourManager=s:scourManager

fu! s:scourManager.new(scour)
  let l:newManager = copy(self)
  let l:newManager.scour = a:scour
  let l:newManager.library = g:ScourLibrary.new(l:newManager)


  return l:newManager
endfu

fu! s:scourManager.initWindows(manager)
  let a:scour.windows = {'ScourShelf': g:ScourShelf.new(a:manager), 'ScourTray': g:ScourTray.new(a:manager)}
endfu

fu! s:scourManager.resetWindows()
  let self.scour.windows.ScourShelf.isOpen = 0
  let self.scour.windows.ScourShelf.winId = -1
  let self.scour.windows.ScourTray.isOpen = 0
  let self.scour.windows.ScourTray.winId = -1
endfu

fu! s:scourManager.updateWindows()
  cal self.resetWindows()
  let l:prevWindow = win_getid()

  let l:i = 1
  wh l:i <= winnr('$')
    let l:winId = win_getid(l:i)
    cal win_gotoid(l:winId)

    let l:i += 1
    let l:winType = &ft
    if l:winType == 'ScourShelf' || l:winType == 'ScourTray'
      let self.scour.windows[l:winType].isOpen = 1
      let self.scour.windows[l:winType].winId = l:winId
    endif
  endw
endfu

fu! s:scourManager.closeAllWindows()
  cal self.updateWindows()
  cal self.scour.windows.ScourShelf.close()
  cal self.scour.windows.ScourTray.close()
endfu


fu! s:scourManager.openMode(mode, options)
  cal self.updateWindows()

  if a:mode == 'dir'
    cal self.closeAllWindows()
    cal self.scour.windows.ScourShelf.open()
    " Build a menu, either cwd or built from a list of objects
    "   - if parent object isn't included in menu, build some parents
    " Load keybinds in that window
  elseif a:mode == 'selection'
    cal self.closeAllWindows()
    cal self.windows.ScourTray.open()
    cal self.windows.ScourShelf.open()
  el
    echoerr 'Invalid mode sent'
  endif
  cal self.updateWindows()
  redraw!
endfu


" let s:Manager = s:scourManager.new('test')
" cal s:Manager.openMode('selection', {})
