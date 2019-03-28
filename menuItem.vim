
let s:menuItem = {}
let g:ScourMenuItem = s:menuItem

function s:menuItem.new(menuTree)
  let l:newmenuItem = copy(self)
  let l:newmenuItem.menuTree = a:menuTree

  return l:newmenuItem
endfu
