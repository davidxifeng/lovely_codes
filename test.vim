

function! s:Displayversion()
	echo "simple tool v 0.0.1"
	echo "write : 2012-11-20 16:18:47"
endfunction

" make a file type list to a vim reg string
" assume len(li) > 0
" 2012-11-21 16:56:11
function! s:make_reg_string(li)
	if len(a:li) < 1
		return ""
	endif
	let s = '.\('
	for i in a:li
		let s .= i.'\|'
	endfor
	let s = strpart(s, 0, strlen(s) - 1)
	let s .= ')$'
	echo "reg is \n" . s."\n"
	return s
endfunction

"get all files
function! s:filter_file_list(dir, filetypes)
	" a magic utility function ;-D glob()!
	let file_list = split(glob(a:dir."**"), "\n")
	let file_type_reg = s:make_reg_string(a:filetypes)
	call filter(file_list, 'v:val =~? '."'".file_type_reg."'")
	call filter(file_list, '!isdirectory(v:val)')
	"echo file_list
	for l in file_list
		echo l
	endfor
endfunction

"process all files
function! s:process_files(files)
	echo a:files
endfunction

function! Main()
	"call s:Displayversion()
	let prj_dir = "E:/NewEclipse/com.example.hellojni.HelloJni"
	let file_type_list = ["java", "c", "cpp", "mk", "lua", "h", "xml"]
	call s:filter_file_list(prj_dir, file_type_list)
endfunction

call Main()
