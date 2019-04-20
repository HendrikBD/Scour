let s:prompt = {}
let g:ScourPrompt = s:prompt

function s:prompt.new(manager)
  let l:newPrompt = copy(self)
  let l:newPrompt.manager = a:manager
  let l:newPrompt.value = ''
  let l:newPrompt.keyInput = 0
  let l:newPrompt.updateFcns = []
  let l:newPrompt.updateStack = []

  return l:newPrompt
endfu

fu! s:prompt.startKeyLoop()
  let self.keyInput = 1
  let self.value = ''
  let self.updateStack = [{'value': self.value, 'init': 0}]
  cal self.nextUpdate()

  redraw!
  echo self.value

  wh self.keyInput

    let l:nr = getchar(0)

    if l:nr == 13
      call s:prompt.return()
      call self.stop()
      let self.value = ""
    elseif l:nr == 27 || nr == 3
      call self.stop()
    elseif l:nr is# "\<BS>"
      if len(self.value) > 0
        let self.value = strcharpart(self.value, 0, strlen(self.value)-1)
      el
        let self.value = ''
      endif
      cal self.pushUpdate(self.value)
      call self.draw()
    elseif l:nr != 0
      let self.value = self.value . nr2char(l:nr)
      cal self.pushUpdate(self.value)
      call self.draw()
    endif

  endw
endf

fu! s:prompt.pushUpdate(value)
  let self.updateStack += [{'value': a:value, 'init': 0}]
  cal self.manager.onPromptUpdate()
  cal self.nextUpdate()
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

fu! s:prompt.draw()
  redraw!
  echo self.value
endf

fu! s:prompt.nextUpdate()
  if len(self.updateStack) > 0
    if self.updateStack[0].init == 0
      cal g:Promise.new({resolve -> self.updateResolver(resolve, self.updateStack[0].value)}).then({-> self.nextUpdate()})
    endif
  endif
endf

fu! s:prompt.updateResolver(resolve, value)

  for l:UpdateFcn in self.updateFcns
    call l:UpdateFcn()
  endfo

  " redraw!
  " echo self.value

  let self.updateStack = self.updateStack[1:-1]
  cal a:resolve()

endf

fu! s:prompt.pruneUpdateStack()
  if len(self.updateStack) > 1
    let self.updateStack = [self.updateStack[0], self.updateStack[-1]]
  endif
endf

fu! s:prompt.addUpdateFunction(callback)
  let self.updateFcns += [a:callback]
endfu

fu! s:prompt.purgeUpdateFunction()
  let self.updateFcns = []
endfu

fu! s:prompt.return()
  redraw!
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

" let g:prompt1 = s:prompt.new()
" call s:prompt1.start()
