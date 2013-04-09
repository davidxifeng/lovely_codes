#coding:utf-8

def test():
    import sys
    print sys.getdefaultencoding()
# to use this function, start python with -S
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

def test_kanzi():
    a = u'你'
    print ord(a)
    print ord(u'好')
    print ord('3')

if __name__ == '__main__':
    test_kanzi()
