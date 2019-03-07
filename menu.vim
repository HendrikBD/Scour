
let s:menu = {}
let g:ScourMenu = s:menu

function s:menu.new(scour)
  let l:newMenu = copy(self)
  let l:newMenu.items = []
  let l:newMenu.scour = a:scour
  let l:newMenu.keymap = g:ScourKeyMap.new(a:scour)
  let l:newMenu.prompt = g:ScourPrompt.new()
  
  return l:newMenu
endfu

fu s:menu.buildFromArray(pathArr, root)

  let l:pathArr = sort(a:pathArr)
  let self.items = []
  let self.lineMap = {}

  for l:path in l:pathArr
    let l:node = a:root.getNodeFromPath(l:path)
    let self.items += [l:node]
  endfo

endfu

fu s:menu.open()
  cal self.draw()
  cal self.watchKeys()
endfu

fu s:menu.draw()
  let self.displayArr = []
  let l:indent = ''

  for l:item in self.items
    let l:displayStr = l:item.getDisplayString()
    let l:indent = g:ScourHelper.getIndent(2)
    let self.displayArr += [l:indent . l:item.getDisplayString()]
  endfo
  if &ft == 'scour'
    cal append(1, self.displayArr)
  endif
endfu

" fu s:scour.update()
" endfu

fu! s:menu.watchKeys()
  let l:done = 0

  while !l:done
      redraw!
      " call self._echoPrompt()

      let l:key = getchar()
      let l:done = self.handleKeypress(l:key)
  endwhile
endfu

fu! s:menu.openFile(line)
  q
  cal win_gotoid(self.prevWindow)
  " cal winrestview(self.prevWindow)
  let l:path = self.items[a:line].getPath()
  execute 'edit ' . l:path
endfu

fu! s:menu.handleKeypress(key)
  if a:key == 106
      call self.cursorUp()
  elseif a:key == 107
      call self.cursorDown()
  elseif a:key == 27
      return 1
  elseif a:key == 13 "enter
    let self.selection = line('.') - 2 " 1 comes from offset TODO: change to variable (dependent on header)
    cal self.openFile(self.selection)
    return 1
  elseif a:key == 47
    " g:Scour.ui.pushFcn(g:Scour.keymap.getFcn('Esc'))
    "
    " Tell ui which key was pressed & line number
  "   return 1
  " elseif a:key == "\r" || a:key == "\n" "enter and ctrl-j
  "   g:Scour.ui.pushFcn(g:Scour.keymap.getFcn('Enter'))
  "   return 1
  else
      " let index = self._nextIndexFor(a:key)
      " if index != -1
      "     let self.selection = index
      "     if len(self._allIndexesFor(a:key)) == 1
      "         return 1
      "     endif
      " endif
  endif
endfu

function s:menu.select(line)
endfu

fu! s:menu.cursorUp()
  let l:newLineNum = line('.') + 1
  cal cursor(l:newLineNum, 1)
endfu

fu! s:menu.cursorDown()
  let l:newLineNum = line('.') - 1
  if l:newLineNum > 0
    cal cursor(l:newLineNum, 1)
  endif
endfu
