fu! InitPrompt()
  call s:KeyLoop()
endf

fu! s:KeyLoop()
  let str = ""
  let keyLoop_cnt = 0
  let s:KeyInput=1

  wh s:KeyInput
    let keyLoop_cnt += 1

    let nr = getchar()
    if nr == 13
      call s:PromptReturn()
      let s:KeyInput=0
    elseif nr == 27
      let s:KeyInput=0
    elseif nr == "\<BS>"
      let str = strcharpart(str, 0, strlen(str)-1)
      call s:PromptUpdate(str)
    el
      let str = str . nr2char(nr)
      call s:PromptUpdate(str)
    endif
  endw
endf

let g:NERDTreeFZF=[]

fu! s:PromptUpdate(str)
  redraw
  echo a:str
  let dir = "~/homebrew/spark"
  " let dir = getcwd()
  let g:NERDTreeFZF = split(system('find ' . dir . ' -type f -not -path "*/node_modules/*" -a -not -path ".*" | fzf --filter="' . a:str . '"'), "\n")
  echo g:NERDTreeFZF
  call NERDTreeRender()
endf

fu! s:PromptReturn()
  redraw
  echo "Enter and stuff"
endf


fu! s:ToggleKeyLoop()
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
