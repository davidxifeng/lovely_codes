#coding:utf-8
from gevent import Greenlet, joinall, spawn, sleep
from gevent.event import AsyncResult, Event


def fa():
    print 'a1'
    sleep(0)
    print 'a2'

def fb():
    print 'b1'
    sleep(0)
    print 'b2'

def main():
    r = []
    r.append(spawn(fa))
    r.append(spawn(fb))
    joinall(r)
    print 'c3'

eve = AsyncResult()

def e1():
    print 'sleep 2'
    sleep(2)
    print 'after sleep, set'
    eve.set()
    print '1 after get'

def e2():
    print 'b'
    eve.get()
    print '2 after get'
    sleep(1)

'''测试结果显示set get不能像switch一样使用'''

def event():
    r = []
    r.append(spawn(e1))
    r.append(spawn(e2))
    joinall(r)

e = Event()

def e3():
    print 'e3 1'
    e.wait()
    print 'e3 2'

def e4():
    print 'e4 1'
    sleep(2)
    e.clear()
    print 'e4 2'
    e.set()

def event2():
    r = []
    r.append(spawn(e3))
    r.append(spawn(e4))
    joinall(r)


if __name__ == '__main__':
    event2()
