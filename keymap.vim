let s:keyMap = {}
let g:ScourKeyMap = s:keyMap

fu! s:keyMap.new(scour)
  let l:newKeyMap = copy(self)
  let l:newKeyMap.scour = a:scour
  cal l:newKeyMap.setKeyMap(l:newKeyMap.getDefaultDirMap())

  return l:newKeyMap
endfu

fu! s:keyMap.getDefaultDirMap()
  " let l:map = {'13': g:Scour.menu.select, '27': g:Scour.close}
endfu

fu! s:keyMap.setKeyMap(map)
  let self.map = a:map
endfu
