
" so  /home/bhd-windows/.vim/homebrew/scour/fileNode.vim
" so  /home/bhd-windows/.vim/homebrew/scour/dirNode.vim
" so  /home/bhd-windows/.vim/homebrew/scour/window.vim

let s:menu = {}
let g:ScourMenu = s:menu

function s:menu.new()
  let l:newMenu = copy(self)
  let l:newMenu.items = []
  
  return l:newMenu
endfu

fu s:menu.buildFromArray(pathArr)

  let l:pathArr = sort(a:pathArr)
  let self.items = []
  let self.lineMap = {}

  for l:path in l:pathArr
    let l:node = g:Scour.root.getNodeFromPath(l:path)
    let self.items += [l:node]
  endfo

endfu

fu s:menu.draw()
  let l:displayArr = []
  " let l:indent = ''

  for l:item in self.items
    let l:displayStr = l:item.getDisplayString()
    let l:indent = g:ScourHelper.getIndent(2)
    let l:displayArr += [l:indent . l:item.getDisplayString()]
  endfo
  cal append(1, l:displayArr)
endfu

" function s:menu.select(line)
" endfu
