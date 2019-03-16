so  /home/bhd-windows/.vim/homebrew/scour/shelf.vim
so  /home/bhd-windows/.vim/homebrew/scour/tray.vim


let s:scourManager={}
let g:ScourManager=s:scourManager

fu! s:scourManager.new(scour)
  let l:newScour = copy(self)
  let l:newScour.scour = a:scour
  cal l:newScour.initWindows(self)

  return l:newScour
endfu

fu! s:scourManager.initWindows(manager)
  let self.windows = {'ScourShelf': g:ScourShelf.new(a:manager), 'ScourTray': g:ScourTray.new(a:manager)}
endfu

fu! s:scourManager.resetWindows()
  let self.windows.ScourShelf.isOpen = 0
  let self.windows.ScourShelf.winId = -1
  let self.windows.ScourTray.isOpen = 0
  let self.windows.ScourTray.winId = -1
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
    if l:winType == 'ScourShelf' || l:winType == 'ScourDrawer' || l:winType == 'ScourTray'
      let self.windows[l:winType].isOpen = 1
      let self.windows[l:winType].winId = l:winId
    endif
  endw
endfu

fu! s:scourManager.closeAll()
  cal self.windows.ScourShelf.close()
  cal self.windows.ScourTray.close()
endfu


fu! s:scourManager.openMode(mode)
  let l:windows = self.updateWindows()

  if a:mode == 'dir'
    cal self.closeAll()
    cal self.windows.ScourShelf.open()
  elseif a:mode == 'selection'
    cal self.closeAll()
    cal self.windows.ScourTray.open()
    cal self.windows.ScourShelf.open()
  el
    echoerr 'Invalid mode sent'
  endif
  redraw!
endfu

" FUNCTION: s:Creator._setCommonBufOptions() {{{1
function! s:scourManager.setBufOptions()

    " Options for a non-file/control buffer.
    setlocal bufhidden=hide
    setlocal buftype=nofile
    setlocal noswapfile

    " Options for controlling buffer/window appearance.
    setlocal foldcolumn=0
    setlocal foldmethod=manual
    setlocal nobuflisted
    setlocal nofoldenable
    setlocal nolist
    setlocal nospell
    setlocal nowrap

    iabc <buffer>

endfunction


let s:Manager = s:scourManager.new('test')
cal s:Manager.closeAll()
cal s:Manager.openMode('selection')
