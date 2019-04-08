so  /home/bhd-windows/.vim/homebrew/scour/menuTree.vim
so  /home/bhd-windows/.vim/homebrew/scour/menuItem.vim

let s:menu = {}
let g:ScourMenu = s:menu

function s:menu.new(manager, dataSource, ...)
  let l:newMenu = copy(self)
  let l:newMenu.manager = a:manager
  let l:newMenu.header = []
  cal l:newMenu.updateDataSource(a:dataSource)
  cal l:newMenu.resetOptions()
  if exists('a:1')
    cal l:newMenu.setOptions(a:1)
  endif

  return l:newMenu
endfu


fu! s:menu.drawTree()
  if self.scour.window.isOpen('ScourShelf')
    echo 'is open'
  endif
endfu

fu! s:menu.buildTreeFromArray()
  let l:pathArr = sort(a:pathArr)
  let self.ScourTree.items = []

  for l:path in l:pathArr
    let l:node = self.scour.root.getNodeFromPath(l:path)
    let self.ScourTree.items += [l:node]
  endfo
endfu

fu! s:menu.resetOptions()
  let self.options = {'indent': 1, 'fullPath': 0}
endfu

fu! s:menu.setOptions(options)
  for l:key in keys(a:options)
    let self.options[l:key] = a:options[l:key]
  endfo
endfu

fu! s:menu.updateDataSource(dataSource)
  if a:dataSource.type == 'tree'
    let self.items = self.buildFromNode(a:dataSource.data)
  elseif a:dataSource.type == 'list'
    let self.menuTree = self.buildFromList(a:dataSource.data)
    let self.items = self.collapseTreeToList(self.menuTree)
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

fu! s:menu.getMenuPaths()
  let l:itemPaths = []
  for l:item in self.items
    if has_key(l:item.menuTree, 'path')
      let l:itemPaths += [l:item.menuTree.path]
      let l:itemPaths += [l:item.menuTree.options]
    else
      echoerr 'No "path" key found on menuItem'
    endif
  endfo
  return l:itemPaths
endfu

fu! s:menu.getMenuItems()
  let l:items = []
  for l:item in self.items
    if has_key(l:item, 'displayStr')
      let l:items += [l:item.displayStr]
    else
      " echo l:item
      echoerr 'No "displayStr" key found on menuItem'
    endif
  endfo
  return l:items
endfu
fu s:menu.buildFromList(pathArr)
  let l:pathArr = sort(a:pathArr)

  let l:menuTree = g:ScourMenuTree.new(self.manager.getRoot().path, self.manager)

  for l:path in l:pathArr
    let l:relPaths = split(join(split(l:path, l:menuTree.path), '/'), '/')

    if len(l:relPaths) > 0
      cal l:menuTree.addNodes(l:relPaths)
    endif

  endfo

  return l:menuTree

endfu

fu s:menu.collapseTreeToList(menuTree)
  let l:items = [a:menuTree]

  if has_key(a:menuTree, 'childNodes')

    for l:childNode in values(a:menuTree.childNodes)
      let l:items += self.collapseTreeToList(l:childNode[0])
      " echo l:childNode[0]
    endfo

  endif
  " echo a:menuTree.childNodes

  return l:items
endfu

fu! s:menu.buildFromFilter()
  let l:pathArr = sort(self.scour.root.getPaths(1))
  let self.items = []

  for l:path in l:pathArr
    let l:node = self.scour.root.getNodeFromPath(l:path)
    let self.items += [l:node]
  endfo
endfu

fu s:menu.getPaths()
  let l:paths = []
  for l:item in self.items
    let l:paths += [l:item.node.path]
  endfo
  return l:paths
endfu

fu s:menu.draw()
  if &ft == 'ScourShelf' || &ft == 'ScourTray'
    let self.displayArr = []
    let l:indent = ''

    for l:item in self.items
      let l:displayStr = l:item.node.getDisplayString()
      let l:indent = self.manager.library.getIndentFromPath(l:item.node.path)
      if self.options.indent
        let self.displayArr += [l:indent . l:item.node.getDisplayString(self.options)]
      el
        let self.displayArr += [l:item.node.getDisplayString(self.options)]
      endif
    endfo

    1,$delete
    cal append(len(self.header), self.displayArr)
    $delete
    cal cursor(1, 1)
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

fu! s:menu.openFile(menuItem)
  let l:path = a:menuItem.node.getPath()
  cal self.manager.closeAllWindows()
  execute 'edit ' . l:path
endfu

fu! s:menu.select()
  let l:menuIndex = line('.') - 1
  let self.selection = self.items[l:menuIndex]

  if self.selection.node.isDir
    let self.selection.node.isOpen = !self.selection.node.isOpen
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
