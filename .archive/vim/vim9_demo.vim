vim9script

var i = 1
while i < 5
	echo "count is " i
	i += 1
endwhile

# 变量不能重定义hiding前一个
for j in range(1, 5)
	echo $"[for range]count is {j}"
endfor
