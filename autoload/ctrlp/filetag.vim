" =============================================================================
" File:          autoload/ctrlp/filetag.vim
" Description:   Filetag extension
" Author:        
" =============================================================================

" Init {{{1
if exists('g:loaded_ctrlp_filetag') && g:loaded_ctrlp_filetag
	fini
en
let g:loaded_ctrlp_filetag = 1
let s:filetag_name = "FTags"

let s:filetag_allfiles = []
let s:filetag_ftag = ""

cal add(g:ctrlp_ext_vars, {
	\ 'init': 'ctrlp#filetag#init()',
	\ 'accept': 'ctrlp#acceptfile',
	\ 'lname': 'filetags',
	\ 'sname': 'filetag',
	\ 'type': 'path',
	\ })

let s:id = g:ctrlp_builtins + len(g:ctrlp_ext_vars)
" Utilities {{{1
fu! s:syntax()
	if !ctrlp#nosy()
		cal ctrlp#hicheck('CtrlPTabExtra', 'Comment')
		sy match CtrlPTabExtra '\zs\t.*\ze$'
	en
endf

function! s:unique(in)
  let sorted = sort(a:in)
  if len(sorted) < 2
    return sorted
  endif
  let last = remove(sorted, 0)
  let result = [last]
  for item in sorted
    if item != last
      call add(result, item)
      let last = item
    endif
  endfor
  return result
endfunction

fu! s:getfiles(tagfile)
  execute 'cd ' . fnamemodify(a:tagfile, ':h')
  " let result = map(readfile(a:tagfile), 'fnamemodify(matchstr(v:val, ''^[^!\t][^\t]*\t\zs[^\t]\+''), '':p:~'')')
  let result = map(readfile(a:tagfile), 'fnamemodify(matchstr(v:val, ''^[^!\t][^\t]*\t\zs[^\t]\+''), '':p:.'')')
  cd -
  return filter(result, 'v:val =~ ''[^/\\ ]$''')
endfunction

fu! s:tags2file(tagfiles)
  if !len(a:tagfiles)
    return ""
  endif
  echo 'Creating filetag...'
	let tagfiles = sort(filter(a:tagfiles, 'count(a:tagfiles, v:val) == 1'))
	for each in tagfiles
		let allfiles = s:getfiles(each)
		cal extend(s:filetag_allfiles, allfiles)
	endfo
  let s:filetag_allfiles = s:unique(s:filetag_allfiles)

  call writefile(s:filetag_allfiles, s:filetag_ftag)
  return s:filetag_ftag
endfunction

fu! s:check_and_create_filetag()
	let filetag_path = ""
	if exists('g:prj_dir')
		let filetag_path = g:prj_dir
	endif
	let ftag = fnamemodify(filetag_path, ":p").s:filetag_name
	if s:filetag_ftag == ftag | retu | en
	let s:filetag_allfiles = []
	let s:filetag_ftag = ftag
	if filereadable(s:filetag_ftag) | retu | en

	let tfs = tagfiles()
	let tagfiles = tfs != [] ? filter(map(tfs, 'fnamemodify(v:val, ":p")'),
		\ 'filereadable(v:val)') : []
	if empty(tagfiles)
		let s:filetag_ftag = ""
		return
	endif

	call inputsave()
	let select = input('Exits Tag, Create filelist?[y/n]')
	call inputrestore()
	if select == 'y'
		let s:filetag_ftag = s:tags2file(tagfiles)
	else
		let s:filetag_ftag = ""
	endif
endf
" Public {{{1
fu! ctrlp#filetag#init()
	call s:check_and_create_filetag()
	if empty(s:filetag_ftag) | retu [] | en

	if empty(s:filetag_allfiles)
		let s:filetag_allfiles = ctrlp#utils#readfile(s:filetag_ftag)
	endif
	cal s:syntax()
	retu s:filetag_allfiles
endf

fu! ctrlp#filetag#id()
	retu s:id
endf

"}}}

" vim:fen:fdm=marker:fmr={{{,}}}:fdl=0:fdc=1:ts=2:sw=2:sts=2
