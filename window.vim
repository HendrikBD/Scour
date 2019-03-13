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

" let s:Window = g:ScourWindow.new()
" cal s:Window.open('dir')
