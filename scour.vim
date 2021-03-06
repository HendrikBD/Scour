so  /home/bhd-windows/.vim/homebrew/scour/manager.vim
so  /home/bhd-windows/.vim/homebrew/scour/shelf.vim
so  /home/bhd-windows/.vim/homebrew/scour/tray.vim
so  /home/bhd-windows/.vim/homebrew/scour/fileNode.vim
so  /home/bhd-windows/.vim/homebrew/scour/dirNode.vim
so  /home/bhd-windows/.vim/homebrew/scour/menu.vim
so  /home/bhd-windows/.vim/homebrew/scour/prompt.vim
so  /home/bhd-windows/.vim/homebrew/scour/filter.vim
so  /home/bhd-windows/.vim/homebrew/scour/lib/Promise.vim

let s:scour={}

function s:scour.new(root)
  let l:newScour = copy(self)
  let l:newScour.manager = g:ScourManager.new(l:newScour)
  let l:newScour.prompt = g:ScourPrompt.new(l:newScour.manager)
  let l:newScour.filter = g:ScourFilter.new(l:newScour.manager)

  let l:newScour.root = g:ScourDirNode.new(a:root, l:newScour.manager)
  let l:newScour.root.isOpen = 1

  let l:dataSource = {'type': 'tree', 'data': l:newScour.root}
  let l:newScour.menu = g:ScourMenu.new(l:newScour.manager, l:dataSource)

  return l:newScour
endfu


function s:scour.openCWD()

  " Initialize datasource
  cal self.manager.closeAllNodes(self.root)
  let self.root.isOpen = 1

  cal self.menu.resetOptions()
  let l:dataSource = {'type': 'tree', 'data': self.root}
  cal self.menu.updateDataSource(l:dataSource)

  cal self.menu.open()

endf

fu! s:scour.openAtFile()

  let l:relPaths = split(expand('%'), '/')[0:-2]

  if len(l:relPaths) == 0
    return self.openCWD()
  endif

  let l:relDirPath = join([self.root.path, join(l:relPaths, '/')], '/')
  let l:node = self.root.getNodeFromPath(l:relDirPath)
  cal self.manager.closeAllNodes(l:node)
  let l:node.isOpen = 1

  cal self.manager.openMode('dir', {})

  let l:dataSource = {'type': 'tree', 'data': l:node }
  let self.windows.ScourShelf.menu = g:ScourMenu.new(self.manager, l:dataSource)
  cal self.windows.ScourShelf.menu.setOptions({'indent': 0})

  cal self.windows.ScourShelf.draw()

endfu


function s:scour.filterCWD()

  " Must be able to open/close dirNodes while still showing filter results
  "
  "   -> can accomplish by closing all dirNodes, filtering from all paths
  "   then building from filtered paths and open nodes
  "
  "   (including collapsing nodes if lonely) then c

  cal self.manager.openAllNodes(self.root)

  " Get initial paths to filter
  "
  let l:paths = self.root.getPaths(0)
  cal self.menu.setOptions({'tray': 1})

  " " Add initial array of paths
  cal self.filter.setInputArr(l:paths)
  cal self.filter.buildSearchDict(l:paths)

  " " Add update function to update filter on each prompt update & start prompt
  cal self.prompt.addUpdateFunction(self.manager.updateFilter)
  " cal self.prompt.addUpdateFunction(self.manager.toTopFiltered)
  cal self.prompt.startKeyLoop()

  " Pass array to filter
  " Add functions to prompt:
  "   - Filter list by prompt value
  "   - Create datasource from output list
  "   - udpateDatsource
  "   - menu.draw (shelf and tray)
  " Start prompt
  " On update:
  "   - stop existing jobs
  "   - start all functions (as job)

endf

function s:scour.wait(ms)
  return g:Promise.new({resolve -> timer_start(a:ms, resolve)})
endf

function s:scour.openBuffHistory()
endf

function s:scour.drawAllChildNodes(indentLvl, lineIndex)
  let l:lineIndex = a:lineIndex
  let l:displayStr = ''

  let l:i = 0
  while l:i < a:indentLvl
    let l:displayStr = l:displayStr . '  '
    let l:i += 1
  endw
  let l:displayStr = l:displayStr . self.root.displayStr

  call setline(l:lineIndex, l:displayStr)
  let l:lineIndex += 1

  call self.root.drawChildNodes(a:indentLvl + 1, l:lineIndex)
endfu

fu s:scour.drawHeader(lineIndex)
  let l:lineIndex = a:lineIndex

  return l:lineIndex
endfu




function s:scour.displayCWD()
  call self.window.openWindow()

  let l:lineIndex = 1
  let l:lineIndex = self.drawHeader(l:lineIndex)

  call self.drawAllChildNodes(2, l:lineIndex)
endf


fu s:scour.updateFromFilter()
  let l:filterArr = self.filter.update(self.prompt.value)
  if len(l:filterArr) > 0
    cal self.displayFromArray(self.filter.update(self.prompt.value))
    cal cursor(1,1)
  endif
endfu

fu s:scour.echoFilter()
  echo g:scour.filter.update(self.prompt.value)
endfu

fu s:scour.displayFromArray(filteredPaths)
  " Building a temporary filter object that can be used to draw a filtered
  " directory tree
  let self.filterTree = {}
  let self.filterTree.root = {}

  for l:filteredPath in a:filteredPaths
    let l:subPath = split(l:filteredPath, self.root.getPath())

    if len(l:subPath) > 0
      let l:pathArr = split(l:subPath[0], '/')
      let self.filterTree.root = self.root.updateFilterTree(l:pathArr, self.filterTree.root)
    en
  endfo

  call self.drawTree(self.filterTree.root, 0)
endfu

fu s:scour.drawTree(tree, indentLvl)

  if has_key(a:tree, 'childNodes')
    for l:child in items(a:tree.childNodes)
      cal self.drawTree(l:child[1], a:indentLvl + 1)
    endfo
  endif

  call a:tree.node.draw(a:indentLvl)
endfu

fu s:scour.test()
  echo 'test'
endfu

fu s:scour.addRefreshFunction(func)
  if has_key(self, refreshFunctions)
    let self.refreshFunctions = []
  endif
  let self.refreshFunctions += [a:func]
endfu

fu s:scour.setMode(mode)
  let self.mode = 'dir'
endfu

fu s:scour.refresh()
endfu

fu! s:scour.open()
  if !(&ft == 'scour')
    let self.menu.prevWindow = win_getid()
    cal self.window.open('dir')
    cal self.menu.open()
    cal cursor(2, 1)
  endif
endfu

fu s:scour.close()
  if &ft == 'scour'
    cal self.window.close()
  endif
endfu

fu s:scour.toggle()
  if &ft == 'scour'
    cal self.close()
  el
    cal self.open()
  endif
endfu

fu s:scour.reset()
  cal l:newScour.menu.buildFromArray(l:newScour.root.getPaths(), l:newScour.root)
  cal self.window.open()
  cal self.menu.draw()
endfu

fu s:scour.filter()
  if !(&ft == 'scour')
    cal self.open()
  endif
  cal self.menu.filter()
endfu


let g:Scour = s:scour.new(getcwd())

nnoremap <silent> <leader>/ :cal g:Scour.filterCWD()<CR>
nnoremap <silent> <leader>f :cal g:Scour.openCWD()<CR>
" nnoremap <silent> <leader>/ :cal g:Scour.openCWD()<CR>
" nnoremap <silent> <leader>c :cal g:Scour.manager.closeAllWindows()<CR>
