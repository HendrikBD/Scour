" FUNCTION: s:Creator._setCommonBufOptions() {{{1
function! s:setBufOptions()

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

    if g:NERDTreeShowLineNumbers
      setlocal nu
    else
        setlocal nonu
        if v:version >= 703
            setlocal nornu
        endif
    endif

    iabc <buffer>

    if g:NERDTreeHighlightCursorline
        setlocal cursorline
    endif

    " call self._setupStatusline()
    " call self._bindMappings()

    " setlocal filetype=nerdtree
endfunction

cal s:setBufOptions()




" " FUNCTION: s:Creator._setCommonBufOptions() {{{1
" function! s:Creator._setCommonBufOptions()
"
"     " Options for a non-file/control buffer.
"     setlocal bufhidden=hide
"     setlocal buftype=nofile
"     setlocal noswapfile
"
"     " Options for controlling buffer/window appearance.
"     setlocal foldcolumn=0
"     setlocal foldmethod=manual
"     setlocal nobuflisted
"     setlocal nofoldenable
"     setlocal nolist
"     setlocal nospell
"     setlocal nowrap
"
"     if g:NERDTreeShowLineNumbers
"         setlocal nu
"     else
"         setlocal nonu
"         if v:version >= 703
"             setlocal nornu
"         endif
"     endif
"
"     iabc <buffer>
"
"     if g:NERDTreeHighlightCursorline
"         setlocal cursorline
"     endif
"
"     call self._setupStatusline()
"     call self._bindMappings()
"
"     setlocal filetype=nerdtree
" endfunction
