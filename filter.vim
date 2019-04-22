let s:filter = {}
let g:ScourFilter = s:filter

function s:filter.new(manager)
  let l:newFilter = copy(self)
  let l:newFilter.manager = a:manager
  let l:newFilter.inputList = []
  let l:newFilter.searchDictionary = {}

  let l:newFilter.outputArr = []
  let l:newFilter.filterTerm = ''
  
  return l:newFilter
endfu

fu! s:filter.setInputArr(arr)
  let self.inputList = a:arr
endfu

fu! s:filter.filterList(inputList, term)
  let self.inputList = a:inputList
  let self.filterTerm = a:term
  return self.fzf(self.inputList, self.filterTerm)
endfu

fu! s:filter.update(term)
  let self.filterTerm = a:term
  let l:searchList = self.getSearchList()
  let l:searchOutput = self.fzf(l:searchList, a:term)

  return self.getSearchPaths(l:searchOutput)
endfu

fu! s:filter.getSearchList()
  return keys(self.searchDictionary)
endfu

fu! s:filter.getSearchPaths(searchStrings)
  let l:paths = []
  for l:str in a:searchStrings
    let l:paths += self.searchDictionary[l:str]
  endfo
  return l:paths
endfu


fu! s:filter.buildSearchDict(paths)
  let l:root = self.manager.getRoot()
  let l:searchDict = {}
  for l:path in a:paths
    let l:searchStr = l:root.getNodeFromPath(l:path).searchStr
    if has_key(l:searchDict, l:searchStr)
      let l:searchDict[l:searchStr] += [l:path]
    else
      let l:searchDict[l:searchStr] = [l:path]
    endif
  endfo
  let self.searchDictionary = l:searchDict
endfu


fu! s:filter.fzf(list, term)
  let l:argString = shellescape(join(a:list, '\n'))
  let self.outputList = split(system('printf ' . l:argString . ' | fzf --filter="' . a:term . '"'), '\n')
  return self.outputList
endfu
