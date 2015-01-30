#!/usr/bin/python

import SimpleHTTPServer
import SocketServer


def main():
    Handler = SimpleHTTPServer.SimpleHTTPRequestHandler
    Handler.extensions_map.update({
        '.lua': 'text/lua',
    })
    PORT = 8021
    httpd = SocketServer.TCPServer(("", PORT), Handler)
    print "serving at port", PORT
    httpd.serve_forever()


if __name__ == '__main__':
    main()
