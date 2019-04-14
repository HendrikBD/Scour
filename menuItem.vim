let s:menuItem = {}
let g:ScourMenuItem = s:menuItem

function s:menuItem.new(menuTree, menu, ...)
  let l:newMenuItem = copy(self)
  let l:newMenuItem.menuTree = a:menuTree
  let l:newMenuItem.menu = a:menu
  cal l:newMenuItem.resetOptions()

  if exists('a:1')
    let l:newMenuItem.displayStr = a:1
  else
    let l:newMenuItem.displayStr = split(a:menuTree.path, '/')[-1]
  endif
  if exists('a:2')
    cal l:newMenuItem.setOptions(a:2)
  endif

  return l:newMenuItem
endfu

fu! s:menuItem.resetOptions()
  let self.options = {'collapsed': 0}
endfu

fu! s:menuItem.setOptions(options)
  for l:key in keys(a:options)
    let self.options[l:key] = a:options[l:key]
  endfo
endfu
