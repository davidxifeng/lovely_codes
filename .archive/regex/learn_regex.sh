#!/usr/bin/env zsh


CC=1

# 打印分隔符
function print_sep() {
    echo '---' $CC '---'
    ((CC=$CC + 1)) # shell的语法果然值得王垠批评 必须要2对括号
    # let "CC=($CC + 1)" 等价于上一行的写法
}
print_sep


# 匹配不以function开头的, 包含 任意字符 和 go的行
# (后记, 这个需求用来搜索Lua源码中的函数调用,排除掉函数定义,我想做一次伸手党,
# 却花了很长时间才搞定,结果后来也明白用法了...)

ag '^(?!function).*?go' test_pcre

print_sep
# 匹配所有的单词, 但排除掉function
ag '\b((?!function)\w)+\b' test_pcre
