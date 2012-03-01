"David's shuang pin input method
"Begin: Tue 14:17:25 Nov/29 2011
"Maintainer: David Feng <davidxifeng@gmail.com>
"♂♫♀

if exists('g:loaded_david_im') || &cp
  finish
endif
let g:loaded_david_im= 1

function! s:init_global_state()
    let s:g = {}
    let s:g.chinese_mode = 0

    let s:pinyin_input = ""
    let s:hanzi_output = []
    let s:pylength = 0

    let s:shift_english = 0
endfunction

function! DavidVimIM(findstart, base)
    if a:findstart
        return s:pylength == 0 ? -2 : col(".")-1-s:pylength
    else
        return ["LOVE","DAVID"]
    endif
endfunction

function! s:begin_im()
    inoremap <expr> <Space> <SID>vimim_space()
    "inoremap <expr> <CR> <SID>vimim_enter()
    "inoremap <expr> <BS> <SID>vimim_bs()
    "inoremap <expr> <Esc> <SID>vimim_esc()
    call s:set_im_rc()
    autocmd InsertCharPre <buffer> call s:check_typed_char()
    "init state let s:g.cache_for_page = 0
endfunction

function! s:end_im()
    execute 'iunmap <Space>'
    "execute 'iunmap <CR>'
    "execute 'iunmap <BS>'
    "execute 'iunmap <Esc>'
    call s:restore_im_rc()
    autocmd! InsertCharPre
endfunction

function! s:set_im_rc()
    set pumheight =10
endfunction

function! s:restore_im_rc()
    set pumheight&
endfunction

function! <SID>toggle_im()
    if s:g.chinese_mode == 0
        call s:begin_im()
        let s:g.chinese_mode = 1
    else
        call s:end_im()
        let s:g.chinese_mode = 0
    endif
endfunction

function! <SID>vimim_space()
    if pumvisible()
        return "\<C-Y>"
    else
        if s:pylength == 0
            return " "
        else
            return "\<C-X>\<C-U>"
        endif
    endif
endfunction

function! s:check_typed_char()
    let ic=v:char
    if ic =~# "[a-z]"
        let s:pylength += 1
    elseif ic == ";" && s:pylength != 0
        let s:pylength += 1
    else
        let s:pylength = 0
    endif
endfunction
 
function! s:im_frame()
    set completefunc=DavidVimIM
    inoremap <C-L> <Esc>:call <SID>toggle_im()<CR>a
endfunction

function! s:im_main()
    call s:init_global_state()
    call s:im_frame()
endfunction

call s:im_main()
