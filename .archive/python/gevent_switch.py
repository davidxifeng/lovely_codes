#encoding:utf-8

from greenlet import greenlet

def gfa():
    print 'a1'
    gb.switch()
    print 'a2'
    gb.switch()

def gfb():
    print 'b1'
    ga.switch()
    print 'b2'

ga = greenlet(gfa)
gb = greenlet(gfb)

# note:gevent包装的greenlet类和原生的不同,不能随意使用switch()
# 需要使用start join方法. 之前有误解

from gevent import Greenlet

def fa():
    print 'a1'
    b.switch()
    print 'a2'
    b.switch()
    print 'back in fa again'

def fb():
    print 'b1'
    a.switch()
    print 'b2'
    a.switch()

a = Greenlet(fa)
b = Greenlet(fb)

def main():
    r = []
    ga.switch()
    a.start()
    a.join()
    print 'c3'

if __name__ == '__main__':
    main()
