so ./fileNode.vim
so ./dirNode.vim
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

fu g:Scour.displayFiltered(filteredPaths)
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

  " echo self.filterTree.childNodes

endfu


let g:scour = g:Scour.new(getcwd())

call g:scour.displayFiltered(g:scour.root.getPaths())

echo g:scour.filterTree.root.childNodes

" echo items(g:scour.root.childNodes)
" for s:i in items(g:scour.root.childNodes)
"   echo s:i[0]
" endfo

" echo items(g:scour.root.childNodes)
" for s:i in items(g:scour.root.childNodes)
"   echo s:i[0]
" endfo

" echo g:scour.root.getPaths()
" call g:scour.displayFiltered(g:scour.root.getPaths())

" for s:i in items(g:scour.filterTree.root.childNodes)
"   echo s:i[0]
" endfo

" g:scour.getAllPaths
" call g:scour.displayCWD()
" call g:scour.displayFiltered(g:scour.root.getPaths())
