so  /home/bhd-windows/.vim/homebrew/scour/menuTree.vim
so  /home/bhd-windows/.vim/homebrew/scour/menuItem.vim

let s:menu = {}
let g:ScourMenu = s:menu

function s:menu.new(manager, dataSource, ...)
  let l:newMenu = copy(self)
  let l:newMenu.manager = a:manager
  let l:newMenu.ScourShelf = g:ScourShelf.new(a:manager, l:newMenu)
  let l:newMenu.ScourTray = g:ScourTray.new(a:manager, l:newMenu)
  let l:newMenu.header = []

  cal l:newMenu.updateDataSource(a:dataSource)
  cal l:newMenu.resetOptions()

  if exists('a:1')
    cal l:newMenu.setOptions(a:1)
  endif

  return l:newMenu
endfu

fu! s:menu.open()
  cal self.manager.updateWindows()
  if self.options.tray
    cal self.ScourTray.open()
    cal self.ScourTray.draw()
    cal self.manager.library.setHotkeys()
  endif
  if self.options.shelf
    cal self.ScourShelf.open()
    cal self.ScourShelf.draw()
    cal self.manager.library.setHotkeys()
  endif
endfu

fu! s:menu.close()
  cal self.ScourShelf.close()
  cal self.ScourTray.close()
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
  let self.options = {'indent': 1, 'fullPath': 0, 'shelf': 1, 'tray': 0}
endfu

fu! s:menu.setOptions(options)
  for l:key in keys(a:options)
    let self.options[l:key] = a:options[l:key]
  endfo
endfu

fu! s:menu.updateDataSource(dataSource)

  let self.dataSource = a:dataSource
  cal self.updateMenu()

endfu

fu! s:menu.updateMenu()
  if self.dataSource.type == 'tree'
    let self.dataSource.data.isOpen = 1
    let self.menuTree = self.buildFromNode(self.dataSource.data)
    let self.ScourShelf.items = self.collapseTreeToList(self.menuTree)
    let self.ScourTray.items = self.getListItems(self.menuTree)
  elseif self.dataSource.type == 'list'
    let self.menuTree = self.buildFromList(self.dataSource.data)
    let self.ScourShelf.items = self.collapseTreeToList(self.menuTree)
    let self.ScourTray.items = self.collapseTreeToList(self.menuTree)
  el
    echoerr 'Invalid dataSource'
  endif
endfu

fu! s:menu.buildFromNode(node)

  let l:menuTree = g:ScourMenuTree.new(a:node.path, self.manager)

  for l:child in keys(a:node.childNodes)
    if !has_key(l:menuTree, 'childNodes')
      let l:menuTree.childNodes = {}
    endif
    let l:childNode = a:node.childNodes[l:child]

    if l:childNode.isDir && l:childNode.isOpen
      let l:menuTree.childNodes[l:child] = self.buildFromNode(l:childNode)
    else
      let l:menuTree.childNodes[l:child] = g:ScourMenuTree.new(l:childNode.path, self.manager)
    endif
  endfo

  return l:menuTree

endfu

" Builds a menu from a set of given paths, for each path a menuItem is created
" with the relevant node
"
" Further, this includes items to represent one or many dirs which are parents
" of the existing nodes. If it represents multiple dirs, will create a
" 'collapsed' menuItem.
"
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

" First add the current tree, including checking if it can be collapsed, and
" if so, collapsing adding items from appropriate child
fu s:menu.collapseTreeToList(menuTree)

  if a:menuTree.options.collapsable && has_key(a:menuTree, 'childNodes') && len(keys(a:menuTree.childNodes)) == 1 && values(a:menuTree.childNodes)[0].node.isDir
    let l:menuTree = self.getCollapsedTree(a:menuTree)
    let l:displayStr = split(a:menuTree.path, '/')[-1] . split(l:menuTree.path, a:menuTree.path)[0]
    let l:items = [g:ScourMenuItem.new(l:menuTree, self, l:displayStr, {'collapsed': 1})]
  else
    let l:menuTree = a:menuTree
    let l:items = [g:ScourMenuItem.new(a:menuTree, self)]
  endif

  " Next, go through child nodes and add to item list
  if has_key(l:menuTree, 'childNodes')
    for l:relChild in keys(l:menuTree.childNodes)
      let l:childTree = l:menuTree.childNodes[l:relChild]
      let l:items += self.collapseTreeToList(l:childTree)
    endfo
  endif

  return l:items
endfu

fu s:menu.getListItems(menuTree)

  if !a:menuTree.options.collapsable
    let l:menuTree = a:menuTree
    let l:items = [g:ScourMenuItem.new(a:menuTree, self)]
  else
    let l:items = []
  endif

  " Next, go through child nodes and add to item list
  if has_key(l:menuTree, 'childNodes')
    for l:relChild in keys(l:menuTree.childNodes)
      let l:childTree = l:menuTree.childNodes[l:relChild]
      let l:items += self.getListItems(l:childTree)
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



fu s:menu.getCollapsedTree(menuTree)
  if a:menuTree.options.collapsable && has_key(a:menuTree, 'childNodes') && len(a:menuTree.childNodes) == 1 && values(a:menuTree.childNodes)[0].node.isDir
    return self.getCollapsedTree(values(a:menuTree.childNodes)[0])
  else
    return a:menuTree
  endif
endfu


" Is called when a parental stack is ready to be resolved into menu items. 
"
" This will pop items off the stack until the next is a parent of the passed
" childDir. Items will be added for each item popped as well as for each
" childPath included in the element.
"
fu! s:menu.resolveParentalStack(parentalStack, childDir)
  let l:results = {'items': [], 'parentalStack': a:parentalStack}

  for l:parent in reverse(a:parentalStack)
    let l:relPaths = split(chidlDir, l:parent.path)

    " If childDir isn't child of current parent, pop & add to items
      if a:childDir == l:relPath
        let l:node = self.manager.scour.root.getNodeFromPath(a:parentPath)
        let l:results.items += [{'type': 'dirNode', 'node': l:node}]

        " Add all related children
        for childPath in l:parent.children
          let l:node = self.manager.scour.root.getNodeFromPath(a:parentPath)
          if l:node.isDir
            let l:results.items += [{'type': 'dirNode', 'node': l:node}]
          el
            let l:results.items += [{'type': 'fileNode', 'node': l:node}]
          endif
        endfo

        let l:results.parentalStack = l:results.parentalStack[0:-2]
      el
        break
      endif

  endfo

  return l:results

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
      let l:displayStr = l:item.displayStr
      let l:indent = self.manager.library.getIndentFromPath(l:item.menuTree.path)
      if self.options.indent
        let self.displayArr += [l:indent . l:item.displayStr]
      el
        let self.displayArr += [l:item.displayStr]
      endif
    endfo

    1,$delete
    cal append(len(self.header), self.displayArr)
    $delete
    cal cursor(1, 1)
  endif
endfu

fu s:menu.drawFromArray(array)
  let l:array = self.manager.library.stringifyArray(a:array)
  if &ft == 'ScourShelf' || &ft == 'ScourTray'
    1,$delete
    cal append(1, a:array)
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

fu! s:menu.openFile(menuItem)
  let l:path = a:menuItem.node.getPath()
  cal self.manager.closeAllWindows()
  execute 'edit ' . l:path
endfu

fu! s:menu.selectCurrentLine()
  let l:line = line('.')
  let l:wind = &ft
  if l:wind == 'ScourShelf' || l:wind == 'ScourTray'
    cal self[l:wind].selectLine(l:line)
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
