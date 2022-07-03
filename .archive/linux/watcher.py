#!/usr/bin/python2

# use psutil library
# ubuntu: apt-get install python-psutil


import os
import sys
import time
import psutil
import subprocess

print "game server watcher 1.0"

procs = psutil.process_iter()
for proc in procs:
    if proc.name == "daemon_test":
        print proc
    #else:
        #print proc.name

rc = subprocess.call("./daemon_test", shell = True)

print "process return code is: " + str(rc)
