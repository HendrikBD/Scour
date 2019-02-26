let s:prompt = {}
let g:ScourPrompt = s:prompt

function s:prompt.new()
  let l:newPrompt = copy(self)
  let l:newPrompt.value = ''
  let l:newPrompt.keyInput = 0
  let l:newPrompt.updateFcns = []

  return l:newPrompt
endfu

fu! s:prompt.startKeyLoop()
  echo self.value
  wh self.keyInput

    let l:nr = getchar()

    if nr == 13
      call s:prompt.return()
      call self.stop()
    elseif nr == 27 || nr == 3
      call self.stop()
    elseif nr == "\<BS>"
      let self.value = strcharpart(self.value, 0, strlen(self.value)-1)
      call self.update()
    el
      let self.value = self.value . nr2char(l:nr)
      call self.update()
    endif

  endw
endf

fu! s:prompt.start()
  let self.keyInput=1
  call self.startKeyLoop()
endf

fu! s:prompt.stop()
  let self.keyInput=0
endf

fu! s:prompt.reset()
  let self.value = ''
  call self.update()
endf

fu! s:prompt.toggle()
  let self.keyInput=!self.keyInput
  if self.keyInput
    call self.startKeyLoop()
  endif
endf

fu! s:prompt.update()
  redraw
  echo self.value

  for l:UpdateFcn in self.updateFcns
    call l:UpdateFcn()
  endfo
endf

fu! s:prompt.addUpdateFunction(callback)
  let self.updateFcns += [a:callback]
endfu

fu! s:prompt.return()
  redraw
  echo "Enter and stuff"
endf


fu! s:FilterDirectory(term, dir)
  let g:NERDTreeFZF = split(system('find ' . a:dir . ' -type f -not -path "*/node_modules/*" -a -not -path "*/.*" | fzf --filter="' . a:term . '"'), "\n")
endf


fu! FZFCheck(params)
  let file = a:params.path.str()
  let fileIgnore = (index(g:NERDTreeFZF, file) == -1) && !a:params.path.isDirectory

  " if fileIgnore
  "   echo "Ignore this file"
  "   echo file
  "   echo index(g:NERDTreeFZF, file)
  " endif

  return fileIgnore
endf


call NERDTreeAddPathFilter('FZFCheck')
" call s:KeyLoop()
call InitPrompt()
