
let s:menu = {}
let g:ScourMenu = s:menu

function s:menu.new(manager, dataSource)
  let l:newMenu = copy(self)
  let l:newMenu.manager = a:manager
  let l:newMenu.header = []
  cal l:newMenu.updateDataSource(a:dataSource)

  return l:newMenu
endfu

fu s:menu.buildFromArray(pathArr, root)
fu! s:menu.updateDataSource(dataSource)
  if a:dataSource.type == 'tree'
    let self.items = self.buildFromNode(a:dataSource.data)
  elseif a:dataSource.type == 'list'
    " echo a:dataSource.data
    " cal self.buildFromList(a:dataSource.data)
    " echo self.items
  el
    echoerr 'Invalid dataSource'
  endif
  " cal self.updateLineMap()
endfu

fu! s:menu.buildFromNode(node)
  if a:node.isDir
    let l:item = {'type': 'dirNode', 'node': a:node}
  el
    let l:item = {'type': 'fileNode', 'node': a:node}
  endif

  let l:items = [l:item]

  if a:node.isDir && a:node.isOpen
    for l:child in values(a:node.childNodes)
      let l:items += self.buildFromNode(l:child)
    endfo
  endif

  return l:items
endfu
  let l:pathArr = sort(a:pathArr)
  let self.items = []
  let self.lineMap = {}

  for l:path in l:pathArr
    let l:node = a:root.getNodeFromPath(l:path)
    let self.items += [l:node]
  endfo

endfu

fu! s:menu.buildFromFilter()
  let l:pathArr = sort(self.scour.root.getPaths(1))
  let self.items = []

  for l:path in l:pathArr
    let l:node = self.scour.root.getNodeFromPath(l:path)
    let self.items += [l:node]
  endfo
endfu

fu s:menu.open()
  cal self.draw()
  cal self.keymap.setKeyMap()
  let self.scourWindow = win_getid()
endfu

fu s:menu.draw()
  if &ft == 'scour'
    let self.displayArr = []
    let l:indent = ''

    for l:item in self.items
      let l:displayStr = l:item.getDisplayString()
      let l:indent = g:ScourHelper.getIndent(2)
      let self.displayArr += [l:indent . l:item.getDisplayString()]
    endfo

    1,$delete
    cal append(1, self.displayArr)
  endif
endfu

fu! s:menu.filterCWD()
  cal self.filter.setInputArr(self.scour.root.getPaths(1))

  cal self.prompt.purgeUpdateFunction()
  cal self.prompt.addUpdateFunction(self.scour.window.clear)
  cal self.prompt.addUpdateFunction(self.updateFromFilter)

  cal self.prompt.start()
endfu

" fu s:scour.update()
" endfu

fu! s:menu.openFile(line)
  cal win_gotoid(self.prevWindow)
  let l:path = self.items[a:line].getPath()
  execute 'edit ' . l:path
  cal win_gotoid(self.scourWindow)
  q
endfu

fu! s:menu.select()
  let self.selection = line('.') - 2 " 1 comes from offset TODO: change to variable (dependent on header)

  if self.items[self.selection].isDir
    cal self.toggleDir(self.selection)
  el
    cal self.openFile(self.selection)
  endif
endfu

" Toggle directory at given line
fu! s:menu.toggleDir(index)
  let self.items[a:index].isOpen = !self.items[a:index].isOpen
  let l:lineBck = line('.')
  cal self.buildFromArray(self.scour.root.getPaths(0), self.scour.root)
  cal self.draw()
  cal cursor(l:lineBck, 1)
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

fu! s:menu.filter()
  " cal self.prompt.startKeyLoop()
endfu

fu s:menu.updateFromFilter()
  let l:filterArr = self.filter.update(self.prompt.value)
  if len(l:filterArr) > 0
    cal self.buildFromArray(self.filter.update(self.prompt.value), self.scour.root)
    cal self.draw()
    " cal self.displayFromArray(self.filter.update(self.prompt.value))
    cal cursor(1,1)
  endif
endfu



" fu! s:menu.watchKeys()
"   let l:done = 0
"
"   while !l:done
"       redraw!
"       " call self._echoPrompt()
"
"       let l:key = getchar()
"       let l:done = self.handleKeypress(l:key)
"   endwhile
" endfu
"
" fu! s:menu.handleKeypress(key)
"   if a:key == 106
"       call self.cursorUp()
"   elseif a:key == 107
"       call self.cursorDown()
"   elseif a:key == 27
"       q
"       return 1
"   elseif a:key == 13 "enter
"     let self.selection = line('.') - 2 " 1 comes from offset TODO: change to variable (dependent on header)
"     q
"     cal self.openFile(self.selection)
"     return 1
"   elseif a:key == 47
"     " g:Scour.ui.pushFcn(g:Scour.keymap.getFcn('Esc'))
"     "
"     " Tell ui which key was pressed & line number
"   "   return 1
"   " elseif a:key == "\r" || a:key == "\n" "enter and ctrl-j
"   "   g:Scour.ui.pushFcn(g:Scour.keymap.getFcn('Enter'))
"   "   return 1
"   else
"       " let index = self._nextIndexFor(a:key)
"       " if index != -1
"       "     let self.selection = index
"       "     if len(self._allIndexesFor(a:key)) == 1
"       "         return 1
"       "     endif
"       " endif
"   endif
" endfu
