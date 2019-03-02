let s:filter = {}
let g:ScourFilter = s:filter

function s:filter.new()
  let l:newFilter = copy(self)
  let l:newFilter.inputList = []
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
  return self.fzf(self.inputList, a:term)
endfu

fu! s:filter.fzf(list, term)
  " let g:NERDTreeFZFIgnore = ['"*/node_modules/*"', '"*/\.*"']
  " let g:NERDTreeFZFIgnore = ['"*/node_modules/*"', '"*/\.git*"']
  "
"   " Go through ignore array and add to command
"   for i in g:NERDTreeFZFIgnore
"     let s:findCmd = s:findCmd . ' -not -path ' . i . ' -a'
"   endfo
"   let s:findCmd = s:findCmd[0:strlen(s:findCmd)-3]
"   let s:findCmd = s:findCmd . ' | fzf --filter="' . a:term . '"'

  let self.outputArr = split(system('xargs printf | fzf --filter="' . a:term . '"', shellescape(join(a:list, '\n'))), '\n')
  return self.outputArr
endfu


" let s:filter1 = s:filter.new()
"
" call s:filter1.setInputArr(['test', 'heyo'])
" echo s:filter1.update('est')
