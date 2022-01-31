#!/usr/bin/env python3
# -*- coding: ascii -*-

import sys, os, signal, time


pathname = os.path.expanduser("~")
pidPath = pathname+"/.runner.pid"
statusPath = pathname+"/.runner.status"
configPath = pathname+"/.runner.conf"

# Section 1 - Retrieve PID
try:
        
    f = open(pidPath, "r")
    ls = []
    for x in f:
        formattedLine = x.strip("\n")
        ls.append(formattedLine)
        os.kill(int(formattedLine), 0)
        os.kill(int(formattedLine), signal.SIGUSR1)
    f.close()


except FileNotFoundError as fileNotExist :
    sys.stderr.write("file {} file was not found\n".format("runner.pid"))
    exit()

except OSError:
    sys.stderr.write("status timeout\n")
    exit()

except ValueError:
    sys.stderr.write("file {} invalid PID in this file\n".format("runner.pid"))
    exit()

# Section 2 - Read Status
try:
        
    runnerStatFile = open(statusPath, "r")
    count = len(runnerStatFile.readlines())
    runnerStatFile.close()

    time_to_wait = 5

    while count <= 0:
        time.sleep(time_to_wait)
        runnerStatFile = open(statusPath, "r")
        count = len(runnerStatFile.readlines())
        runnerStatFile.close()
        if count == 0:
            sys.stderr.write("status timeout\n")
            exit()

    runnerStatFile = open(statusPath, "r")
    for x in runnerStatFile:
        print(x, end = "")
    print()
    runnerStatFile.close()

    runnerStatFileW = open(statusPath, "w")
    runnerStatFileW.truncate(0)
    runnerStatFileW.close()
    

except FileNotFoundError as statusFileNotExist :
    sys.stderr.write("file {} file was not found\n".format("runner.status"))
    exit()
    
