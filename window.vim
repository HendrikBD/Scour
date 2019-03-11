let s:window={}
let g:ScourWindow=s:window

function s:window.new()
  let l:newWindow = copy(self)
  
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

    setlocal filetype=scour
endfunction

function s:window.open()
  if &ft != 'scour'
    vert topleft vnew
    vertical resize 40
    call self.setBufOptions()
  endif
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
