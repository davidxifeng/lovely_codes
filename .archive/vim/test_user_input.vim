

" test:
" :so %
" :DavidTest this is a test

com! -nargs=* DavidTest call CmdFunc(<f-args>)

" 变参说明
" a:0 是变参的个数,可以为0
" a:1 a:2 ... a:000是整个变参list vim限制最多只有20个参数
function! CmdFunc(...)
    let args_list = a:000
    echo args_list
    echo type(args_list)
    echo a:0
    echo a:1
endfunction

