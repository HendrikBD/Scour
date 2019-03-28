let s:menuTree = {}
let g:ScourMenuTree = s:menuTree

function s:menuTree.new(path, manager, ...)
  let l:newMenuTree = copy(self)
  let l:newMenuTree.path = a:path
  let l:newMenuTree.manager = a:manager
  let l:newMenuTree.node = l:newMenuTree.manager.getRoot().getNodeFromPath(a:path)

  if exists('a:1')
    let self.options = a:1
  el
    let self.options = {'collabsable': 1}
  endif

  return l:newMenuTree
endfu

function s:menuTree.addNode(path)
  if !has_key(self, 'childNodes')
    let self.childNodes = []
  endif
  let self.childNodes += [s:menuTree.new(a:path, self)]
endfu

" Will add nodes for all those that don't exist
"
function s:menuTree.addNodes(relPaths)
  if !has_key(self, 'childNodes')
    let self.childNodes = {}
  endif

  if !has_key(self.childNodes, a:relPaths[0])
    let l:childPath = self.path . '/' . a:relPaths[0]
    let self.childNodes[a:relPaths[0]] = [s:menuTree.new(l:childPath, self.manager)]

    if len(a:relPaths) > 1
      cal self.childNodes[a:relPaths[0]].addNodes(a:relPaths[1:-1])
    endif
  endif

endfu
