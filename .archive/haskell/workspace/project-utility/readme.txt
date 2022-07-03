Windows系统cmd的代码页设置:
     > 如果haskell源文件使用了utf-8编码,则String的内容亦为utf-8字符串;

     > 然后再Windows控制台输出的字符串也是utf-8的,中文Windows某人不能显示;

     > 需要使用chcp 65001命令把控制台代码页改成utf-8的,

     > 然后把字体改成Lucida Console,即可以显示出中文字体

