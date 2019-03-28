so  /home/bhd-windows/.vim/homebrew/scour/library.vim

let s:scourManager={}
let g:ScourManager=s:scourManager

fu! s:scourManager.new(scour)
  let l:newManager = copy(self)
  let l:newManager.scour = a:scour
  let l:newManager.library = g:ScourLibrary.new(l:newManager)
  cal l:newManager.initWindows(l:newManager)

  return l:newManager
endfu

fu! s:scourManager.initWindows(manager)
  let a:manager.scour.windows = {'ScourShelf': g:ScourShelf.new(a:manager), 'ScourTray': g:ScourTray.new(a:manager)}
endfu

fu! s:scourManager.resetWindows()
  let self.scour.windows.ScourShelf.isOpen = 0
  let self.scour.windows.ScourShelf.winId = -1
  let self.scour.windows.ScourTray.isOpen = 0
  let self.scour.windows.ScourTray.winId = -1
endfu

fu! s:scourManager.updateWindows()
  cal self.resetWindows()
  let l:prevWindow = win_getid()

  let l:i = 1
  wh l:i <= winnr('$')
    let l:winId = win_getid(l:i)
    cal win_gotoid(l:winId)

    let l:i += 1
    let l:winType = &ft
    if l:winType == 'ScourShelf' || l:winType == 'ScourTray'
      let self.scour.windows[l:winType].isOpen = 1
      let self.scour.windows[l:winType].winId = l:winId
    endif
  endw

  cal win_gotoid(l:prevWindow)
endfu

fu! s:scourManager.closeAllWindows()
  cal self.updateWindows()
  cal self.scour.windows.ScourShelf.close()
  cal self.scour.windows.ScourTray.close()
  cal self.updateWindows()
endfu


fu! s:scourManager.openMode(mode, options)
  cal self.updateWindows()

  if a:mode == 'dir'
    if self.scour.windows.ScourTray.isOpen
      self.scour.windows.ScourTray.close()
    endif
    cal self.scour.windows.ScourShelf.open()
  elseif a:mode == 'selection'
    if self.scour.windows.ScourTray.isOpen || self.scour.windows.ScourShelf.isOpen
      cal self.closeAllWindows()
    endif
    cal self.scour.windows.ScourTray.open()
    cal self.scour.windows.ScourShelf.open()
  el
    echoerr 'Invalid mode sent'
  endif
  cal self.updateWindows()
  redraw!
endfu

fu! s:scourManager.closeAllNodes(node)
  if a:node.isDir
    let a:node.isOpen = 0
    for l:childNode in values(a:node.childNodes)
        cal self.closeAllNodes(l:childNode)
    endfo
  endif
endfu

fu! s:scourManager.openAllNodes(node)

  if a:node.isDir
    let a:node.isOpen = 1
    for l:childNode in values(a:node.childNodes)
        cal self.openAllNodes(l:childNode)
    endfo
  endif

endfu

fu! s:scourManager.buildMenu(dataSource, type)
  if a:type == 'dir'
    let l:newMenu = g:ScourMenu.new(self, a:dataSource, {'indent': 1, 'fullPath': 0})
  elseif a:type == 'selection'
    let l:newMenu = g:ScourMenu.new(self, a:dataSource, {'indent': 0, 'fullPath': 1})
  el
    echoerr 'Invalid menu type passed to manager!'
  endif

  return l:newMenu
endfu

fu! s:scourManager.initPrompt()
  cal self.scour.prompt.start()
endfu

fu! s:scourManager.isIgnoredDir(dir)
  return index(self.library.getIgnoredDirs(), a:dir) >= 0
endfu


fu! s:scourManager.select()
  let l:line = line('.')
  let l:winId = win_getid()
  cal self.updateWindows()

  if l:winId == self.scour.windows.ScourShelf.winId
    cal self.scour.windows.ScourShelf.menu.select()
  elseif l:winId == self.scour.windows.ScourTray.winId
    cal self.scour.windows.ScourTray.menu.select()
  end
endfu

fu! s:scourManager.filterAll()
  return self.fzf(self.scour.root.getPaths(1), self.scour.prompt.value)
endfu

fu! s:scourManager.fzf(list, term)
  let self.outputArr = split(system('xargs printf | fzf --filter="' . a:term . '"', shellescape(join(a:list, '\n'))), '\n')
  return self.outputArr
endfu

fu! s:scourManager.isRoot(path)
  return self.scour.root.path == a:path
endfu

fu! s:scourManager.getRoot()
  return self.scour.root
endfu

" let s:Manager = s:scourManager.new('test')
" cal s:Manager.openMode('selection', {})
