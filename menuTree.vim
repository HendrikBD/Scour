let s:menuTree = {}
let g:ScourMenuTree = s:menuTree

function s:menuTree.new(path, manager, ...)
  let l:newMenuTree = copy(self)
  let l:newMenuTree.path = a:path
  let l:newMenuTree.manager = a:manager
  let l:newMenuTree.node = l:newMenuTree.manager.getRoot().getNodeFromPath(a:path)

  if exists('a:1')
    let l:newMenuTree.options = a:1
  el
    let l:newMenuTree.options = {'collapsable': 0}
  endif

  return l:newMenuTree
endfu

function s:menuTree.addNode(path)
  if !has_key(self, 'childNodes')
    let self.childNodes = []
  endif
  let self.childNodes += [s:menuTree.new(a:path, self)]
endfu

function s:menuTree.getTreeStruct()
  let l:obj = {'path': self.path, 'options': self.options, 'isDir': self.node.isDir}
  if self.node.isDir
    let l:obj.isOpen = self.node.isOpen
  endif
  let l:paths = [l:obj]
  if has_key(self, 'childNodes')
    for l:child in keys(self.childNodes)
      let l:paths += self.childNodes[l:child].getTreeStruct()
    endfo
  endif
  return l:paths
endfu

" Will add nodes for all those that don't exist
"
function s:menuTree.addNodes(relPaths)
  if !has_key(self, 'childNodes')
    let self.childNodes = {}
  endif

  let l:treeOptions = self.getOptions(a:relPaths)

  if !has_key(self.childNodes, a:relPaths[0])

    let l:childPath = self.path . '/' . a:relPaths[0]
    let self.childNodes[a:relPaths[0]] = s:menuTree.new(l:childPath, self.manager, l:treeOptions)

  elseif !l:treeOptions.collapsable && self.childNodes[a:relPaths[0]].options.collapsable
    let self.childNodes[a:relPaths[0]].options.collapsable = 1
  endif

  if self.childNodes[a:relPaths[0]].options.collapsable
  endif

  if len(a:relPaths) > 1
    cal self.childNodes[a:relPaths[0]].addNodes(a:relPaths[1:-1])
  endif

endfu

function s:menuTree.getOptions(relPaths)
  if len(a:relPaths) == 1
    return {'collapsable': 0}
  else
    return {'collapsable': 1}
  endif
endfu
