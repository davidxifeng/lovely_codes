"David's shuang pin input method
"Begin: Tue 14:17:25 Nov/29 2011
"Maintainer: David Feng <davidxifeng@gmail.com>
"♂♫♀

if exists('g:loaded_david_im') || &cp
  finish
endif
let g:loaded_david_im= 1

function! s:init_global_state()
    "g : the global input method state variable
    let s:g = {}
    let s:g.chinese_mode = 0

    let s:pinyin_input = ""
    let s:hanzi_output = []
    let s:valid_pinyin_length = 0

    let s:shift_english = 0
endfunction

function! DavidVimIM(findstart, base)
    if a:findstart
        let start_column = col(".")-1
        if s:valid_pinyin_length != 0
            let start_column -= s:valid_pinyin_length
        else
            let start_column = -2
        endif
        return start_column
        "-1 cancel with error message -2 cancel silently
    else
        return s:hanzi_output
    endif
endfunction

function! s:begin_select_maps()
    execute 'inoremap <expr> , <SID>page_up_map()'
    execute 'inoremap <expr> . <SID>page_down_map()'
    for key in g:select_keys
        execute 'inoremap <expr> '.key.' <SID>select_keys_map("'.key.'")'
    endfor
endfunction

function! s:end_select_maps()
    execute 'iunmap ,'
    execute 'iunmap .'
    for key in g:select_keys
        execute 'iunmap '.key
    endfor
endfunction

function! <SID>select_keys_map(key)
    let key = a:key
    if pumvisible()
    return key
endfunction

function! <SID>page_up_map()
endfunction

function! <SID>page_down_map()
endfunction

function! <SID>vimim_space()
    if pumvisible()
        let space = <SID>select_keys_map(1)
    else
        if s:shift_english
            let s:shift_english = 0
            return " "
            "use auto cmd for reset left border
        endif
        let cl = getline(".")
        let one_before=cl[col(".")-2]
        if one_before =~# g:im_keycodes
            "fix one ; as non pinyin code
            if one_before == ';' && cl[col(".")-3] !~# g:im_keycodes
                let space = " "
            else
                let space = "\<C-X>\<C-U>"
            endif
        else
            let space = " "
        endif
    endif
    return space
endfunction

function! <SID>vimim_enter()
endfunction

function! s:begin_im()
    "inoremap <expr> <Space>  <SID>vimim_space()
    "inoremap <expr> <CR>  <SID>vimim_enter()
    "inoremap <expr> <BS>  <SID>vimim_bs()
    "inoremap <expr> <Esc>  <SID>vimim_esc()
    call s:begin_select_maps()
    call s:set_im_rc()

    "init state
    let s:g.cache_for_page = 0
endfunction

function! s:end_im()
    "execute 'iunmap <Space>'
    "execute 'iunmap <CR>'
    "execute 'iunmap <BS>'
    "execute 'iunmap <Esc>'
    call s:end_select_maps()
    call s:restore_im_rc()
endfunction

function! s:output_log(s)
    let sh = "echo ".a:s.">>/tmp/vim.log"
    call system(sh)
endfunction

function! s:handle_input()
    let ic=v:char
    if ic =~# "[a-z]"
        let s:valid_pinyin_length += 1
    elseif ic =~# "[;]" && s:valid_pinyin_length != 0
        let s:valid_pinyin_length += 1
    elseif ic == " "
        "invoke cx xu
    else
        let s:valid_pinyin_length = 0
    endif
    call s:output_log(ic.s:valid_pinyin_length)
endfunction

function! <SID>toggle_im()
    if s:g.chinese_mode == 0
        call s:begin_im()
        let s:g.chinese_mode =1
        autocmd InsertCharPre <buffer> call s:handle_input()
    else
        call s:end_im()
        let s:g.chinese_mode =0
        autocmd! InsertCharPre
    endif
endfunction

function! s:set_im_rc()
    set pumheight =10
endfunction

function! s:restore_im_rc()
    set pumheight&
endfunction

function! s:im_frame()
    set completefunc=DavidVimIM
    inoremap <C-L> <Esc>:call <SID>toggle_im()<CR>a
endfunction

function! s:im_main()
    call s:im_frame()
endfunction

call s:im_main()
