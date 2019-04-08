
let s:menuItem = {}
let g:ScourMenuItem = s:menuItem

function s:menuItem.new(menuTree, ...)
  let l:newMenuItem = copy(self)
  let l:newMenuItem.menuTree = a:menuTree

  if exists('a:1')
    let l:newMenuItem.displayStr = a:1
  else
    let l:newMenuItem.displayStr = split(a:menuTree.path, '/')[-1]
  endif

  return l:newMenuItem
endfu
