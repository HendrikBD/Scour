so ./fileNode.vim
so ./dirNode.vim
so ./helper.vim
so ./window.vim

let g:Scour={}

function g:Scour.new(path)
  let l:newScour = copy(self)
  let l:newScour.root = g:ScourDirNode.new(a:path)
  
  return l:newScour
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

fu g:Scour.displayFromArray(filteredPaths)
  let self.window = g:Window.new()
  call self.window.openWindow()

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

call g:scour.displayFromArray(g:scour.root.getPaths())
" call g:scour.displayFromArray(['/home/bhd-windows/.vim/homebrew/scour/window.vim', '/home/bhd-windows/.vim/homebrew/scour/doc'])
