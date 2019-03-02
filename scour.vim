so  /home/bhd-windows/.vim/homebrew/scour/fileNode.vim
so  /home/bhd-windows/.vim/homebrew/scour/dirNode.vim
so  /home/bhd-windows/.vim/homebrew/scour/helper.vim
so  /home/bhd-windows/.vim/homebrew/scour/prompt.vim
so  /home/bhd-windows/.vim/homebrew/scour/filter.vim
so  /home/bhd-windows/.vim/homebrew/scour/window.vim
so  /home/bhd-windows/.vim/homebrew/scour/menu.vim

let s:scour={}

function s:scour.new(path)
  let l:newScour = copy(self)
  let l:newScour.root = g:ScourDirNode.new(a:path)
  let l:newScour.prompt = g:ScourPrompt.new()
  let l:newScour.filter = g:ScourFilter.new()
  let l:newScour.window = g:ScourWindow.new()
  let l:newScour.menu = g:ScourMenu.new()

  cal l:newScour.setMode('dir')

  return l:newScour
endfu

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
  let self.window = g:ScourWindow.new()
  call self.window.openWindow()

  let l:lineIndex = 1
  let l:lineIndex = self.drawHeader(l:lineIndex)

  call self.drawAllChildNodes(2, l:lineIndex)
endf

fu s:scour.filterCWD()
  cal self.filter.setInputArr(g:scour.root.getPaths())
  cal self.window.open()
  " cal self.openWindow()

  call self.prompt.addUpdateFunction(self.window.clear)
  call self.prompt.addUpdateFunction(self.updateFromFilter)
endfu

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

fu s:scour.refresh()
endfu

fu s:scour.addRefreshFunction(func)
  if has_key(self, refreshFunctions)
    let self.refreshFunctions = []
  endif
  let self.refreshFunctions += [func]
endfu

fu s:scour.setMode(mode)
  let self.mode = 'dir'
endfu


let g:Scour = s:scour.new(getcwd())
cal g:Scour.menu.buildFromArray(g:Scour.root.getPaths())

nnoremap <leader>/ :call g:Scour.window.toggle()<CR>
" nnoremap <leader>/ :call g:scour.prompt.toggle()<CR>
