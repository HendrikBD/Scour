so ./fileNode.vim
so ./dirNode.vim
so ./helper.vim
so ./prompt.vim
so ./filter.vim
so ./window.vim

let g:Scour={}

function g:Scour.new(path)
  let l:newScour = copy(self)
  let l:newScour.root = g:ScourDirNode.new(a:path)
  let l:newScour.prompt = g:ScourPrompt.new()
  let l:newScour.filter = g:ScourFilter.new()

  " let l:newScour.prompt = g:ScourPrompt.new()
  " echo l:newScour.root.getPaths()
  " call l:newScour.prompt.addUpdateFunction(l:newScour.test)
  
  return l:newScour
endfu

function g:Scour.test()
  echo 'test'
endfu

function g:Scour.drawAllChildNodes(indentLvl, lineIndex)
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

fu g:Scour.drawHeader(lineIndex)
  let l:lineIndex = a:lineIndex

  return l:lineIndex
endfu

function g:Scour.displayCWD()
  let self.window = g:Window.new()
  call self.window.openWindow()

  let l:lineIndex = 1
  let l:lineIndex = self.drawHeader(l:lineIndex)

  call self.drawAllChildNodes(2, l:lineIndex)
endf

fu g:Scour.filterCWD()
  cal self.filter.setInputArr(g:scour.root.getPaths())
  cal self.openWindow()

  call self.prompt.addUpdateFunction(self.window.clear)
  call self.prompt.addUpdateFunction(self.updateFromFilter)
endfu

fu g:Scour.updateFromFilter()
  let l:filterArr = self.filter.update(self.prompt.value)
  if len(l:filterArr) >0
    cal self.displayFromArray(self.filter.update(self.prompt.value))
  endif
endfu

fu g:Scour.echoFilter()
  echo g:scour.filter.update(self.prompt.value)
endfu

fu g:Scour.openWindow()
  let self.window = g:Window.new()
  call self.window.openWindow()
endfu

fu g:Scour.displayFromArray(filteredPaths)
  " let self.window = g:Window.new()
  " call self.window.openWindow()

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

fu g:Scour.drawTree(tree, indentLvl)

  if has_key(a:tree, 'childNodes')
    for l:child in items(a:tree.childNodes)
      cal self.drawTree(l:child[1], a:indentLvl + 1)
    endfo
  endif

  call a:tree.node.draw(a:indentLvl)
endfu


let g:scour = g:Scour.new(getcwd())
call g:scour.filterCWD()

nnoremap <leader>/ :call g:scour.prompt.toggle()<CR>