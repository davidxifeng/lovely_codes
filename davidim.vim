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
    let s:g.cache_for_page = 0
    let s:g.partly_input = 0
    let s:g.remained_pinyin = ""
    let s:g.record_freq = 0

    call s:input_history()

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
        if s:g.cache_for_page != 0
            let s:hanzi_output = s:cache_for_page()
            return s:hanzi_output
        endif

        let icode = a:base

        "super special code
        if strlen(icode) == 1 && has_key(g:cjk.one, icode)
            let s:pinyin_input = icode
            let s:hanzi_output = s:create_dict_list(split(g:cjk.one[icode]),0)
            return s:hanzi_output
        endif
        
        "TODO use a more reasonable process later
        if strlen(icode) % 2
            let icode = icode[:-2]
        endif

        "english text
        if !s:is_valid_code(icode)
            let s:hanzi_output = [icode, "Future English Text Input"]
            return s:hanzi_output
        endif

        let scd = g:cjk.gb2312
        let phd = g:cjk.phrases

        "pinyin to hanzi
        "IMPORTANT NOTE 23:20
        "this module will soon removed, and I will use sunpinyin as a
        "input method engine backend, and here will only be a front end.
        "begin to research how to wrap sunpinyin with ruby or lua, and then
        "connect it with vimim front end.
        "Feb/09 Thu 01:26:13
        "1> 4,3,2 word input, remember, and p.setence input
        "2> SML someday,
        "3> front end /backend...
        let pylen = strlen(icode) / 2
        if pylen == 1
            let chars = split(scd[icode])
            let s:pinyin_input = icode
            let s:hanzi_output = s:create_dict_list(chars, 1)
        elseif pylen == 2
            if has_key(phd, icode)
                let chars = split(phd[icode])
                let s:pinyin_input = icode
                let s:hanzi_output = s:create_dict_list(chars, 0)
            else
                let s:pinyin_input = icode[:1]
                let chars = split(scd[s:pinyin_input])
                let s:hanzi_output = s:create_dict_list(chars, 1)
                let s:g.partly_input = 1
                let s:g.remained_pinyin = icode[2:]
                let s:ih.set_n = 2
                let s:ih.wait_n = 2
            endif
        elseif pylen == 3
            let s:pinyin_input = icode

            let pylist = []
            call s:pinyin_to_pylist(icode, pylist)
            let hzlist = []
            call s:pylist_to_hzlist(pylist, hzlist)
            let s:hanzi_output = s:create_dict_list(hzlist, 0)
        endif
        return s:hanzi_output
    endif
endfunction

function! s:pinyin_to_pylist(input_py, pylist)
    let r1 = s:parse_pinyin(a:input_py, 0)
    let r2 = s:parse_pinyin(a:input_py, 1)
    let r3 = s:parse_pinyin_single(a:input_py)
    call add(a:pylist, r1)
    call add(a:pylist, r2)
    call add(a:pylist, r3)
endfunction

function! s:pylist_to_hzlist(pylist, hzlist)
    let scd = g:cjk.gb2312
    let phd = g:cjk.phrases

    for one_line in a:pylist
        let line = ""
        for py in one_line
            if has_key(phd, py)
                let tmp = split(phd[py])
                let line .= tmp[0]
            else
                let tmp = split(scd[py])
                let line .= tmp[0][0:2]
            endif
        endfor
        call add(a:hzlist, line)
    endfor
endfunction

function! s:parse_pinyin(pinyin, is_forward)
"is_forward could only be 0 or 1
    let fwd = a:is_forward
    let pys = a:pinyin

    let phd = g:cjk.phrases
    let phrase_list = []

    while strlen(pys) > 0
        let pn = strlen(pys) / 2
        if pn > 5
            let pn = 5
        endif
        let found_a_phrase = 0
        while pn > 1
            if fwd
                let ph1 = pys[:(2*pn-1)]
            else
                let ph1 = pys[(-2*pn):]
            endif
            if has_key(phd, ph1)
                call add(phrase_list, ph1)
                if fwd
                    let pys = pys[(2*pn):]
                else
                    let pys = pys[:((-2*pn)-1)]
                endif
                let found_a_phrase = 1
                break
            endif
            let pn -= 1
        endwhile
        if !found_a_phrase
            if fwd
                let sw = pys[:1]
                let pys = pys[2:]
            else
                let sw = pys[-2:]
                let pys = pys[:-3]
            endif
            call add(phrase_list, sw)
        endif
    endwhile

    if !fwd
        call reverse(phrase_list)
    endif
    return phrase_list
endfunction

function! s:parse_pinyin_single(pinyin)
    let scd = g:cjk.gb2312
    let lst = []
    let i = 0
    let m = strlen(a:pinyin) - 2
    while i <= m
        call add(lst, a:pinyin[i : i+1])
        let i += 2
    endwhile
    return lst
endfunction

function! s:actions_after_insert(n)
    let s:g.cache_for_page = 0

    if s:g.record_freq
        call s:record_char_freq(a:n)
    endif

    call s:ih.add_to_history(s:pinyin_input, s:hanzi_output[a:n].word)

    if s:ih.set_n
        let s:ih.wait_n -= 1
        if !s:ih.wait_n
            let history = s:ih.last_n_history(s:ih.set_n)
            let pinyin = ""
            let hanzi = ""
                for [a, b] in history
                    let pinyin .= a
                    let hanzi .= b
                endfor
            "add a new phrase dict
            let g:cjk.phrases[pinyin] = hanzi

            let s:ih.set_n = 0
        endif
    endif
endfunction

function! s:record_char_freq(n)
    let s:g.record_freq = 0
    let tk = s:pinyin_input[:1]
    let newstr = g:cjk.gb2312[tk]
    let inputed_char = s:hanzi_output[a:n].word
    let starti = matchend(newstr, inputed_char)
    let length = strlen(newstr)
    if length == starti 
        "the last char at the last position
        let g:cjk.gb2312[tk] = s:special_sort(g:cjk.gb2312[tk]."1")
    else
        if newstr[starti] == " "
            let newstring = newstr[: starti-1]."1".newstr[starti :]
        else
            let endi = starti
            while endi + 1 < length && newstr[endi+1] != " "
                let endi += 1
            endwhile
            let freq = newstr[starti : endi]
            let freq = freq + 1
            let newstring = newstr[: starti-1].freq.newstr[endi+1 :]
        endif
        let g:cjk.gb2312[tk] = s:special_sort(newstring)
    endif
endfunction

function! s:cache_for_page()
    " FIX non times counts position shift...
    " list length check at page_up page_down
    if s:g.cache_for_page == 1
        let A = s:hanzi_output[-10:]
        let B = s:hanzi_output[:-11]
    elseif s:g.cache_for_page == 2
        let A = s:hanzi_output[10:]
        let B = s:hanzi_output[:9]
    endif
    return A + B
endfunction

function! s:create_dict_list(chars, trim_number)
    let dict_list = []
    let i = 1
    for char in a:chars
        let dict_item = {}

        if a:trim_number
            let char = char[:2]
            let s:g.record_freq = 1
        endif
        let dict_item["abbr"] = i."  ".char
        let dict_item["word"] = char
        let dict_item["dup"] = 1
        let i = i==9 ? 0 : i+1
        call add(dict_list, dict_item)
    endfor
    return dict_list
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

function! s:is_valid_code(code)
    let cd = a:code

    let code_length = strlen(cd)

    if code_length % 2
        let last_index = code_length - 2
    else
        let last_index = code_length - 3
    endif
    
    let answer = 1
    let index = 0

    while index <= code_length - 2
        let wd = strpart(cd,index,2)

        let found_a_match = 0
        for vc in g:cjk.pinyin_table_list
            if wd ==# vc
                let found_a_match = 1
                break
            endif
        endfor

        if !found_a_match
            let answer = 0
            break
        else
            let index += 2
        endif
    endwhile
    return answer
endfunction

function! <SID>select_keys_map(key)
    let key = a:key
    if pumvisible()
        if key =~ '\d'
            let n = (key < 1 ? 9 : key-1)
        endif
        let key = repeat("\<C-N>", n)
        let key .= "\<C-Y>"
        if s:g.partly_input
            let s:g.partly_input = 0
            let key .= s:g.remained_pinyin."\<C-X>\<C-U>"
        endif
        call s:actions_after_insert(n)
    endif
    return key
endfunction

function! <SID>page_up_map()
    let key = ','
    if pumvisible() && len(s:hanzi_output) > 10 "&ph
        let s:g.cache_for_page = 1
        let key = "\<C-E>\<C-X>\<C-U>"
    endif
    return key 
endfunction

function! <SID>page_down_map()
    let key = '.'
    if pumvisible() && len(s:hanzi_output) > 10 "&ph
        let s:g.cache_for_page = 2
        let key = "\<C-E>\<C-X>\<C-U>"
    endif
    return key 
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
    if pumvisible()
        let enter = "\<C-E>"
        let s:shift_english = 1
    else
        let cl = getline(".")
        let one_before=cl[col(".")-2]
        if one_before =~# g:im_keycodes
            let enter = ""
            let s:shift_english = 1
        else
            let enter = "\<CR>"
        endif
    endif
    return enter
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

"new core function Feb/26 Sun 09:30:26
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
    "not all the expression could use a <space>
    set completeopt =menuone,preview
    set pumheight =10
endfunction

function! s:restore_im_rc()
    "set to default
    set completeopt&
    set pumheight&
endfunction

function! s:read_db_file()
    let dict=g:cjk.gb2312
    if ! filereadable(s:tgbf)
        return 0
    endif
    for line in readfile(s:tgbf)
        let words = split(line)
        let first = 1
        for word in words
            if first
                let first = 0
                let key_pinyin = word
            else
                if has_key(dict,key_pinyin)
                    let dict[key_pinyin] = dict[key_pinyin]." ".word
                else
                    let dict[key_pinyin] = " ".word
                endif
            endif
        endfor
    endfor
    return 1
endfunction

function! s:read_phrase_data_file()
    if !filereadable(s:tpdf)
        return 0
    endif
    let dict = g:cjk.phrases
    for line in readfile(s:tpdf)
        let phrases = split(line)
        let first = 1
        for phrase in phrases
            if first
                let first = 0
                let pykey = phrase
            else
                if has_key(dict, pykey)
                    let dict[pykey] = dict[pykey]." ".phrase
                else
                    let dict[pykey] = " ".phrase
                endif
            endif
        endfor
    endfor
    return 1
endfunction

function! s:save_dict_to_datafile(dict, file)
    let lst = []
    for it in sort(keys(a:dict))
        let nl = it ." ". a:dict[it]
        call add(lst, nl)
    endfor
    call writefile(lst, a:file)
endfunction

function! s:update_dict_file()
    if s:ih.count
        call s:save_dict_to_datafile(g:cjk.gb2312, s:tgbf)
        call s:save_dict_to_datafile(g:cjk.phrases, s:tpdf)
    endif
endfunction

function! s:process_data_files_real()
    let s:tagfile = "/tmp/davidim/running_ims.v"
    if !filereadable(s:tagfile)
        call system("mkdir /tmp/davidim/")
        call system("echo 1>/tmp/davidim/running_ims.v")
    endif
endfunction

function! s:process_data_files()
    let s:tpdf = "/tmp/pdf.txt"
    let s:tgbf = "/tmp/gb2312.txt"
    let ppdf = "/home/david/data/Dropbox/wiki/ph.txt"
    let pgbf = "/home/david/data/Dropbox/wiki/sc.txt"
    if !filereadable(s:tpdf)
        call system("cp ".ppdf." ".s:tpdf)
    endif
    if !filereadable(s:tgbf)
        call system("cp ".pgbf." ".s:tgbf)
    endif
endfunction

function! s:init_global_data()
    if !exists("g:cjk")
        let g:cjk = {}
        let g:cjk.one = s:get_super_code()
        let g:cjk.pinyin_table_list = s:get_pinyin_table()
        let g:cjk.gb2312 = {}
        let g:cjk.phrases = {}

        call s:process_data_files()
        call s:read_db_file()
        call s:read_phrase_data_file()

        function! g:cjk.sdb()
            return self.gb2312
        endfunction

        function! g:cjk.pdb()
            return self.phrases
        endfunction

        let g:im_keycodes = "[a-z;]"
        let g:select_keys = range(10)
    endif
endfunction

function! s:im_frame()
    set completefunc=DavidVimIM
    inoremap <C-L> <Esc>:call <SID>toggle_im()<CR>a
    autocmd BufWinLeave * call s:update_dict_file()
endfunction

function! s:input_history()
    let s:ih = {}
    let s:ih.pinyin = []
    let s:ih.hanzi = []
    let s:ih.count = 0
    let s:ih.size = 10
    let s:ih.set_n = 0
    let s:ih.wait_n = 0

    function! s:ih.add_to_history(py, hz)
        call insert(self.pinyin, a:py)
        call insert(self.hanzi, a:hz)
        if self.count < self.size
            let self.count += 1
        else
            call remove(self.pinyin, -1)
            call remove(self.hanzi, -1)
        endif
    endfunction

    function! s:ih.last_n_history(ln) " assert( ln<10 )
        let result = []
        let i = 0
        while i < a:ln
            let lily = []
            call add(lily, self.pinyin[i])
            call add(lily, self.hanzi[i])
            call add(result, lily)
            let i += 1
        endwhile
        return reverse(result)
    endfunction

endfunction

function! s:init_im()
    call s:init_global_state()
    call s:init_global_data()
endfunction

function! s:im_main()
    call s:im_frame()
    call s:init_im()
endfunction

function! Sort_compare_for_im(a, b)
    let a = str2nr(a:a[3:])
    let b = str2nr(a:b[3:])
    return a == b ? 0 : a > b ? -1 : 1
endfunction

function! s:special_sort(str)
    let lt = split(a:str)
    let ol = []
    let tl = []
    for i in lt
        let l = strlen(i)
        if l == 3
            call add(tl, i)
        elseif l > 3
            call add(ol, i)
        endif
    endfor
    call sort(ol, "Sort_compare_for_im")
    return join(ol + tl)
endfunction

function s:get_super_code()
    let jack=
        \{
        \'a':"啊 啊 阿 吖",
        \'b':"不 把 吧 别 比",
        \'c':"才 错 次 从 草 菜 此",
        \'d':"的 点 到 大 多",
        \'e':"我 爱 你 他 她 它 零 百 千 万 程 序 员 聂 振",
        \'f':"一 二 三 四 五",
        \'g':"六 七 八 九 十",
        \'h':"威",
        \'i':"▲ 你 他 她 它 零 百 千 万 程 序 员 聂 振",
        \'j':"我 爱 你 他 她 它 零 百 千 万 程 序 员 聂 振",
        \'k':"我 爱 你 他 她 它 零 百 千 万 程 序 员 聂 振",
        \'l':"我 爱 你 他 她 它 零 百 千 万 程 序 员 聂 振",
        \'m':"我 爱 你 他 她 它 零 百 千 万 程 序 员 聂 振",
        \'n':"我 爱 你 他 她 它 零 百 千 万 程 序 员 聂 振",
        \'o':"我 爱 你 他 她 它 零 百 千 万 程 序 员 聂 振",
        \'p':"我 爱 你 他 她 它 零 百 千 万 程 序 员 聂 振",
        \'q':"我 爱 你 他 她 它 零 百 千 万 程 序 员 聂 振",
        \'r':"我 爱 你 他 她 它 零 百 千 万 程 序 员 聂 振",
        \'s':"我 爱 你 他 她 它 零 百 千 万 程 序 员 聂 振",
        \'t':"我 爱 你 他 她 它 零 百 千 万 程 序 员 聂 振",
        \'u':"我 爱 你 他 她 它 零 百 千 万 程 序 员 聂 振",
        \'v':"我 爱 你 他 她 它 零 百 千 万 程 序 员 聂 振",
        \'w':"我 爱 你 他 她 它 零 百 千 万 程 序 员 聂 振",
        \'x':"我 爱 你 他 她 它 零 百 千 万 程 序 员 聂 振",
        \'y':"也 我 爱 你 他 她 它 零 百 千 万 程 序 员 聂 振",
        \'z':"我 爱 你 他 她 它 零 百 千 万 程 序 员 聂 振"
        \}
    return jack
endfunction

function! s:get_pinyin_table()
     " total: 406
     let table = [
        \ "oa", "ol", "oj", "oh", "ok", "ba", "bl", "bj", "bh", "bk",
        \ "bz", "bf", "bg", "bi", "bm", "bc", "bx", "bn", "b;", "bo", 
        \ "bu", "ca", "cl", "cj", "ch", "ck", "ce", "cf", "cg", "ia", 
        \ "il", "ij", "ih", "ik", "ie", "if", "ig", "ii", "is", "ib",
        \ "iu", "iw", "iy", "ir", "id", "iv", "ip", "io", "ci", "cs",
        \ "cb", "cu", "cr", "cv", "cp", "co", "da", "dl", "dj", "dh",
        \ "dk", "de", "dz", "df", "di", "dw", "dm", "dc", "dx", "d;",
        \ "dq", "ds", "db", "du", "dr", "dv", "dp", "do", "oe", "oz",
        \ "of", "or", "fa", "fj", "fh", "fz", "ff", "fg", "fc", "fo",
        \ "fb", "fu", "ga", "gl", "gj", "gh", "gk", "ge", "gz", "gf",
        \ "gg", "gs", "gb", "gu", "gw", "gy", "gr", "gd", "gv", "gp",
        \ "go", "ha", "hl", "hj", "hh", "hk", "he", "hz", "hf", "hg",
        \ "hs", "hb", "hu", "hw", "hy", "hr", "hd", "hv", "hp", "ho",
        \ "oi", "ji", "jw", "jm", "jd", "jc", "jx", "jn", "j;", "js",
        \ "jq", "ju", "jr", "jt", "jp", "ka", "kl", "kj", "kh", "kk",
        \ "ke", "kf", "kg", "ks", "kb", "ku", "kw", "ky", "kr", "kd",
        \ "kv", "kp", "ko", "la", "ll", "lj", "lh", "lk", "le", "lz",
        \ "lg", "li", "lw", "lm", "ld", "lc", "lx", "ln", "l;", "lq",
        \ "ls", "lb", "lu", "lr", "lt", "lp", "lo", "ly", "ma", "ml",
        \ "mj", "mh", "mk", "me", "mz", "mf", "mg", "mi", "mm", "mc",
        \ "mx", "mn", "m;", "mq", "mo", "mb", "mu", "na", "nl", "nj",
        \ "nh", "nk", "ne", "nz", "nf", "ng", "ni", "nm", "nd", "nc",
        \ "nx", "nn", "n;", "nq", "ns", "nb", "nr", "nt", "no", "ny",
        \ "oo", "ob", "pa", "pl", "pj", "ph", "pk", "pz", "pf", "pg",
        \ "pi", "pm", "pc", "px", "pn", "p;", "po", "pb", "pu", "qi",
        \ "qw", "qm", "qd", "qc", "qx", "qn", "q;", "qs", "qq", "qu",
        \ "qr", "qt", "qp", "rj", "rh", "rk", "re", "rf", "rg", "ri",
        \ "rs", "rb", "ru", "rr", "rv", "rp", "ro", "sa", "sl", "sj",
        \ "sh", "sk", "se", "sf", "sg", "ua", "ul", "uj", "uh", "uk",
        \ "ue", "uz", "uf", "ug", "ui", "ub", "uu", "uw", "uy", "ur",
        \ "ud", "uv", "up", "uo", "si", "ss", "sb", "su", "sr", "sv",
        \ "sp", "so", "ta", "tl", "tj", "th", "tk", "te", "tg", "ti",
        \ "tm", "tc", "tx", "t;", "ts", "tb", "tu", "tr", "tv", "tp",
        \ "to", "wa", "wl", "wj", "wh", "wz", "wf", "wg", "wo", "wu",
        \ "xi", "xw", "xm", "xd", "xc", "xx", "xn", "x;", "xs", "xq",
        \ "xu", "xr", "xt", "xp", "ya", "yj", "yh", "yk", "ye", "yi",
        \ "yn", "y;", "yo", "ys", "yb", "yu", "yr", "yt", "yp", "za",
        \ "zl", "zj", "zh", "zk", "ze", "zz", "zf", "zg", "va", "vl",
        \ "vj", "vh", "vk", "ve", "vf", "vg", "vi", "vs", "vb", "vu",
        \ "vw", "vy", "vr", "vd", "vv", "vp", "vo", "zi", "zs", "zb",
        \ "zu", "zr", "zv", "zp", "zo", "nu", "dg" 
        \ ]
    return table
endfunction 

call s:im_main()
