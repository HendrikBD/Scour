let s:window={}
let g:ScourWindow=s:window

function s:window.new()
  let l:newWindow = copy(self)
  let l:dirOpen = 0
  let l:dirMenuOpen = 0
  let l:trayOpen = 0
  
  return l:newWindow
endfu

" FUNCTION: s:Creator._setCommonBufOptions() {{{1
function! s:window.setBufOptions()

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

function s:window.open(type)
  vert topleft vnew
  vertical resize 40
  call self.setBufOptions()
  setlocal filetype=scour
  " if !self.isWindowType('scour')
  "   if a:type == 'dir' && !self.isWindowType(a:type)
  "     vert topleft vnew
  "     vertical resize 40
  "     call self.setBufOptions()
  "     setlocal filetype=scour.dir
  "   endif
  " endif
endfu

function s:window.close()
  if &ft == 'scour'
    close
  endif
endfu

function s:window.toggle()
  if &ft == 'scour'
    close
  el
    cal self.open()
  endif
endfu

function s:window.clear()
  if &ft == 'scour'
    1,$delete
  endif
endfu

function s:window.isWindowType(type)
  let l:fileTypes = split(&ft, '\.')
  return index(l:fileTypes, a:type) > -1
endfu

fu! s:window.openMode(mode)
  cal self.updateWindows()

  if a:mode == 'dir'
    if self.windows.ScourTray.isOpen
      cal self.closeWindow('ScourTray')
    endif
  elseif a:mode == 'selection'
  elseif a:mode == 'tray'
  el
    echoerr 'Invalid mode sent'
  endif
endfu

fu! s:window.openShelf()
  vert topleft vnew
  vertical resize 40
  cal s:Window.setBufOptions()
  setlocal filetype=ScourShelf
endfu

fu! s:window.openDrawer()
  new
  resize 15
  cal s:Window.setBufOptions()
  setlocal filetype=ScourDrawer
endfu

fu! s:window.openTray()
  botright new
  resize 20
  cal s:Window.setBufOptions()
  setlocal filetype=ScourTray
endfu

fu! s:window.closeWindow(window)
  if self.windows[a:window].isOpen
    let l:prevWindow = winnr()
    cal win_gotoid(self.windows[a:window].id)
    q
    cal win_gotoid(l:prevWindow)
  endif
endfu

" Sets window to default
"
fu! s:window.resetWindows()
  let self.windows = {'ScourShelf': {'isOpen': 0}, 'ScourDrawer': {'isOpen': 0}, 'ScourTray': {'isOpen': 0}}
endfu

" Gets all scour windows currently open
" loops through all windows and checks filetypes
"
fu! s:window.updateWindows()
  let l:prevWindow = win_getid()
  cal self.resetWindows()

  let l:i = 1
  wh l:i <= winnr('$')
    let l:winId = win_getid(l:i)
    cal win_gotoid(l:winId)

    let l:i += 1
    let l:winType = &ft
    if l:winType == 'ScourShelf' || l:winType == 'ScourDrawer' || l:winType == 'ScourTray'
      let self.windows[l:winType] = {'isOpen': 1, 'id': l:winId}
    endif
  endw

endfu
