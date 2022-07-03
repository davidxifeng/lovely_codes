#!/usr/local/bin/python
#coding:utf-8
from flask import Flask, send_from_directory, redirect, url_for

# Sun Mar 31 22:58:47 CST 2013
# 这么简单明了的教程,几分钟就几乎0基础写完了一个本地的静态
# 文档网站,用来在打开本地文档的时候是通过http,从而使一些浏览器插件可用
# python真的也是一门必备的语言技能了


app = Flask(__name__)

@app.route("/")
def home():
    return redirect(url_for('doc_files', filename='index.html'))

@app.route("/<path:filename>")
def doc_files(filename):
    return send_from_directory("/Users/david/Books/Python/flask-docs",
            filename, as_attachment=False)

if __name__ == '__main__':

#   这个选项用来启用自动加载文件更新
    app.debug = True
#   默认端口5000
    app.run()
