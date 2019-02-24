so ./fileNode.vim
so ./dirNode.vim
so ./window.vim

let g:Scour={}

function g:Scour.new(path)
  let l:newScour = copy(self)
  let l:newScour.root = g:ScourDirNode.new(a:path)
  
  return l:newScour

endfu

function g:Scour.displayAllNodes()
  let self.window = g:Window.new()
  call self.window.openWindow()
  call self.root.draw(0, 0)
endfu

function g:Scour.displayCWD()
  call self.displayAllNodes()
endf

let g:scour = g:Scour.new(getcwd())
call g:scour.displayCWD()
