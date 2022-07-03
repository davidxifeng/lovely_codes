def bundle_action(f):
    def ddd(self, *arg, **args):
        self.a()
        print 'in dec', args
        r = f(self, *arg, **args)
        return r
    return ddd

class Test():

    def a(self):
        print 'a'

    @bundle_action
    def b(self):
        print 'b'

    @bundle_action
    def b2(self, hi, key = 'love'):
        print hi, key


t = Test()
t.b()

t.b2(2, key = 'david')
t.b2(2)

'''

def decorator_whith_params_and_func_args(arg_of_decorator):
    def handle_func(func):
        def handle_args(*args, **kwargs):
            print "begin"
            func(*args, **kwargs)
            print "end"
            print arg_of_decorator, func, args,kwargs
        return handle_args
    return handle_func


@decorator_whith_params_and_func_args("123")
def foo4(a, b=2):
    print "Content"

foo4(1, b=3)
'''
