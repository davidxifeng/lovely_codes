"David's shuang pin input method
"Begin: Tue 14:17:25 Nov/29 2011
"Maintainer: David Feng <davidxifeng@gmail.com>

if exists('g:loaded_david_im') || &cp
  finish
endif
let g:loaded_david_im= 1

function! s:init_global_state()
    "g : the global input method state variable
    let s:g = {}
    let s:g.chinese_mode = 0
    let s:g.entered_english = 0
    let s:g.cache_for_page = 0
    let s:g.partly_input = 0
    let s:g.remained_pinyin = ""
    let s:g.record_freq = 0

    let s:pinyin_input = ""
    let s:hanzi_output = []
endfunction

function! DavidVimIM(findstart, base)
    if a:findstart
        let start_column = col(".")-2
        " must be col. -2 TWO!
        let current_line = getline(".")
        while start_column>= 1
            if current_line[start_column] =~# g:im_keycodes
                let start_column -= 1
            else
                let start_column += 1
                break
            endif
        endwhile
        "TODO return -1 thing ...
        return start_column
    else
        if s:g.cache_for_page != 0
            let s:hanzi_output = s:cache_for_page()
            return s:hanzi_output
        endif

        let icode = a:base

        "super special code
        if strlen(icode) == 1 && has_key(g:cjk.one, icode)
            let s:hanzi_output = split(g:cjk.one[icode])
            "TODO add menu tag here... and also has_key false...
            return s:hanzi_output
        endif
        
        "TODO use a more reasonable process later
        if strlen(icode) % 2
            let icode = icode[:-2]
        endif
        let s:pinyin_input = icode

        "english text
        if !s:is_valid_code(icode)
            let s:hanzi_output = [icode, "Future English Text Input"]
            return s:hanzi_output
        endif

        let scd = g:cjk.gb2312
        let phd = g:cjk.phrases

        "pinyin to hanzi
        let pylen = strlen(icode)/2
        if pylen == 1
            let chars = split(scd[icode])
            let s:hanzi_output = s:create_dict_list(chars, 1)
        elseif pylen == 2
            if has_key(phd, icode)
                let chars = split(phd[icode])
                let s:hanzi_output = s:create_dict_list(chars, 0)
            else
                let chars = split(scd[(icode[:1])])
                let s:hanzi_output = s:create_dict_list(chars, 1)
                let s:g.partly_input = 1
                let s:g.remained_pinyin = icode[-2:]
            endif
        elseif pylen == 3
            let pylist = s:parse_pinyin(icode, 1)
            if len(pylist) == 1
                let chars = split(phd[icode])
                let s:hanzi_output = s:create_dict_list(chars, 0)
            elseif len(pylist) == 2
                if strlen(pylist[0]) ==2
                    let ch1 = split(scd[pylist[0]])
                elseif strlen(pylist[0]) == 4
                    let ch1 = split(phd[pylist[0]])
                endif
                let s:hanzi_output = s:create_dict_list(ch1, 0)
                let s:g.partly_input = 1
                let s:g.remained_pinyin = pylist[1]
            elseif len(pylist) == 3
                let cs = split("三个汉字词 看你怎么办")
                let s:hanzi_output = s:create_dict_list(cs, 0)
            endif
        endif
        return s:hanzi_output
    endif
endfunction

function! s:my_sort_list(chars)
    "current: only support single char + weight
    let l = a:chars

    let tail_list = []
    let order_list = []

    for i in l
        " with weight number or not ?
        if strlen(i) == 3
            call add(tail_list, i)
        else
            call s:my_add_list(order_list, i)
        endif
    endfor

    return order_list + tail_list
endfunction

function! s:my_add_list(order_list, item)
    "if a+0 <= b+0 "which one is better, or faster?
    let ol = a:order_list
    let it = a:item

    if empty(ol)
        call add(ol, it)
        return
    endif

    let a = it[3:]

    "improve the algorithm, or use user define sort()
    let idx = len(ol) - 1
    while idx >= 0
        let b = ol[idx][3:]
        if str2nr(a) <= str2nr(b)
            call insert(ol, it, idx + 1)
            return
        endif
        let idx -= 1
    endwhile
    call insert(ol, it, 0) "idx
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

function! JieXi(s,f)
    return s:parse_pinyin(a:s,a:f)
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

function! s:actions_after_insert()
    let s:g.cache_for_page = 0
endfunction

function! Save_Data_File()
    let newlist = []
    call add(newlist, string(g:cjk.gb2312))
    call writefile(newlist, "/tmp/new2312.txt")
endfunction

function! s:record_char_freq(n)
    let s:g.record_freq = 0
    let newstr = g:cjk.gb2312[s:pinyin_input]
    let inputed_char = s:hanzi_output[a:n].word
    let starti = matchend(newstr, inputed_char)
    let length = strlen(newstr)
    if length == starti 
        "the last char at the last position
        let g:cjk.gb2312[s:pinyin_input] =
        \ s:special_sort(g:cjk.gb2312[s:pinyin_input]."1")
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
        let g:cjk.gb2312[s:pinyin_input] = s:special_sort(newstring)
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
    " variable function member typedef define(macro)
    "let kind_value = "vfmtd"
    for char in a:chars
        let dict_item = {}

        "remove the number before
        "if all character is 3-byte, then use this;
        "or else use remove 0-9 method
        if a:trim_number
            let char = char[:2]
            let s:g.record_freq = 1
        endif
        let dict_item["abbr"] = i."  ".char
        let dict_item["word"] = char
        "let dict_item["kind"] = kind_value[ i%5]
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
            let key .= s:g.remained_pinyin."\<C-X>\<C-U>"
            let s:g.partly_input = 0
        endif
        call s:actions_after_insert()
        if s:g.record_freq
            call s:record_char_freq(n)
        endif
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
        let space = "\<C-Y>"
        if s:g.partly_input
            let s:g.partly_input = 0
            let space .= s:g.remained_pinyin."\<C-X>\<C-U>"
        endif
        call s:actions_after_insert()
        if s:g.record_freq
            call s:record_char_freq(0)
        endif
    else
        let one_before=getline(".")[col(".")-2]
        if one_before =~# g:im_keycodes
            let space = "\<C-X>\<C-U>"
        else
            let space = " "
        endif
    endif
    return space
endfunction

function! s:begin_im()
    inoremap <expr> <Space>  <SID>vimim_space()
    "inoremap <expr> <CR>  <SID>vimim_space()
    "inoremap <expr> <BS>  <SID>vimim_space()
    "inoremap <expr> <Esc>  <SID>vimim_space()
    call s:begin_select_maps()
    call s:set_im_rc()

    "init state
    let s:g.cache_for_page = 0
endfunction

function! s:end_im()
    execute 'iunmap <Space>'
    "execute 'iunmap <CR>'
    "execute 'iunmap <BS>'
    "execute 'iunmap <Esc>'
    call s:end_select_maps()
    call s:restore_im_rc()
endfunction

function! <SID>toggle_im()
    if s:g.chinese_mode == 0
        call s:begin_im()
        let s:g.chinese_mode =1
    else
        call s:end_im()
        let s:g.chinese_mode =0
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

function! s:copy_data_files()
" backup file: manual or use shell script... outside vim
" or else the backup operation will be to much...
    let s:tpdf = "/tmp/pdf.txt"
    let s:tgbf = "/tmp/gb2312.txt"
    let ppdf = "/home/david/.vim/plugin/phrase2012.txt"
    let pgbf = "/home/david/.vim/plugin/gb2312.txt"
    if !filereadable(s:tpdf)
        call system("cp ".ppdf." ".s:tpdf)
    endif
    if !filereadable(s:tgbf)
        call system("cp ".pgbf." ".s:tgbf)
    endif
endfunction

function! s:init_global_data()
    if !exists("g:im_keycodes")
        let g:im_keycodes = "[a-z;]"
        let g:select_keys = range(10)

        let g:cjk = {}
        let g:cjk.one = s:get_super_code()
        let g:cjk.pinyin_table_list = s:get_pinyin_table()
        let g:cjk.gb2312 = {}
        let g:cjk.phrases = {}

        call s:copy_data_files()

        call s:read_db_file()
        call s:read_phrase_data_file()
    endif
endfunction

function! s:init_im()
    inoremap <silent> <C-J> <Esc>:call <SID>toggle_im()<CR>a
endfunction

function! s:im_main()
    "add save & restore here, toggle
    set completefunc=DavidVimIM

    call s:init_global_state()
    call s:init_global_data()
    call s:init_im()
    command! SaveMe call Save_Data_File()
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
        \'i':"我 爱 你 他 她 它 零 百 千 万 程 序 员 聂 振",
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
        \ "zu", "zr", "zv", "zp", "zo", "nu" ]
    return table
endfunction 

call s:im_main()
