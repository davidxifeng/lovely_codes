import time
import gevent
from gevent import select

def foo():
    print('Running in foo')
    gevent.sleep(0)
    print('Explicit context switch to foo again')

def bar():
    print('Explicit context to bar')
    gevent.sleep(0)
    print('Implicit context switch back to bar')

def test1():
    gevent.joinall([gevent.spawn(foo), gevent.spawn(bar),])


start = time.time()
tic = lambda: 'at %1.1f seconds' % (time.time() - start)

def gr1():
    # Busy waits for a second, but we don't want to stick around...
    print('Started Polling: 1', tic())
    select.select([], [], [], 2)
    print('Ended Polling 1: ', tic())

def gr2():
    # Busy waits for a second, but we don't want to stick around...
    print('Started Polling 2: ', tic())
    select.select([], [], [], 2)
    print('Ended Polling 2: ', tic())

def gr3():
    print("Hey lets do some stuff while the greenlets poll, at", tic())
    gevent.sleep(1)



def test_io_block():
    gevent.joinall([
        gevent.spawn(gr1),
        gevent.spawn(gr2),
        gevent.spawn(gr3),
        ])


def main():
    #test1()
    test_io_block()


if __name__ == "__main__":
    main()
