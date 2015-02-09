# 旋转图片 并设置alpha透明度
convert gun_003_n.png -alpha set -background none -rotate 54 output.png

# grep的一个应用
cat ~/.zshrc | grep "export PATH" >> ~/.zprofile


# Thu May 23 21:39:25 CST 2013
# 一个简单的awk匹配:
# ps:通用语言很容易实现的任务,用shell执行却因为不熟悉感觉好麻烦
du -h | awk '{if(match($1, "M")>0) print $0}'

# Tue Dec 18 21:49:30 HKT 2012
# 梦幻般的工具:do the right extraction
dtrx /tmp/test.tgz


netcat

mtr
lftp

#控制台版的irc client
irssi


sudo ngrep  -l -q -d eth0 "^GET | ^POST " tcp and port 80
#这个文件用来保存一些好用的工具, 或者一些命令的用法示例,等等


# 查找文件并执行in place替换
find . -name '*.lua' | xargs perl -pi -e 's/abc/def/g'
