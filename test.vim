

function! Displayversion()
	echo "simple tool v 0.0.1"
	echo "write : 2012-11-20 16:18:47"
endfunction

function! Test()
	let prj_dir = "E:/NewEclipse/com.example.hellojni.HelloJni"
	let prj_files = glob(prj_dir."/*")
	echo prj_files
endfunction

function! Main()
	call Displayversion()
endfunction

call Main()
