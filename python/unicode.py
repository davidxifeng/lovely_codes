#coding:utf-8

import sys

print sys.getdefaultencoding()

# to use this function, set python with -S
sys.setdefaultencoding('utf-8')

print sys.getdefaultencoding()

us = u'你好我爱你abc'
print type(us)

# print u'你好我爱你abc'
# will UnicodeEncodeError: 'ascii' codec can't encode characters in
# position 0-4: ordinal not in range(128)

utf8_str = us.encode('utf-8')
print utf8_str

us2 = utf8_str.decode('utf-8')
print type(us2)

assert type(us2) == type(us)
