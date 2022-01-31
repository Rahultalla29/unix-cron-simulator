#!/usr/bin/env python3
# -*- coding: ascii -*-

import sys, os, time, datetime, signal, re
from _datetime import timedelta


runRecords = {}
previousRecords = []
pathname = os.path.expanduser("~")
pidPath = pathname+"/.runner.pid"
statusPath = pathname+"/.runner.status"
configPath = pathname+"/.runner.conf"

# Section 1 - Parsing and Helper Functions

def mkDateToRun(day,time,keyword): 

    today = datetime.datetime.now()
    presentDay = today.strftime('%A')

    while today.strftime('%A') != day :
        today += datetime.timedelta(1)

    modTime = [(time[i:i+2]) for i in range(0, len(time), 2)] # Change time format (i.e. 0700 to 07 00)

    #Check if the time on the day has already passed
    if ((keyword == "at") and (presentDay == day)) : 
        if (today.hour > int(modTime[0])): 
            today += datetime.timedelta(1)
            newDate = datetime.datetime(today.year,today.month ,today.day, int(modTime[0]), int(modTime[1]), 0)
            return newDate
            
        elif ((today.hour == int(modTime[0]))) and (today.minute >= int(modTime[1])) : 
            today += datetime.timedelta(1)
            newDate = datetime.datetime(today.year,today.month ,today.day, int(modTime[0]), int(modTime[1]), 0)
            return newDate
    

    elif ((keyword == "every") or (keyword == "on")) and (presentDay == day) :

        if (today.hour > int(modTime[0])): 
            today += datetime.timedelta(7)
            newDate = datetime.datetime(today.year,today.month ,today.day, int(modTime[0]), int(modTime[1]), 0)
            return newDate

            
        elif ((today.hour == int(modTime[0]))) and (today.minute >= int(modTime[1])) : 
            today += datetime.timedelta(7)
            newDate = datetime.datetime(today.year,today.month ,today.day, int(modTime[0]), int(modTime[1]), 0)
            return newDate

    newDate = datetime.datetime(today.year,today.month ,today.day, int(modTime[0]), int(modTime[1]), 0) 
    return newDate


def addRunRecord(dateToRun,keyword,pathname,parameter,runRecord) :
    if dateToRun in runRecord: #Check for same time already exist in record
        sys.stderr.write("there is another process scheduled at the same time\n")
        exit()

    runRecord[dateToRun] = (keyword,pathname,parameter)


def everyInLine(lineAsList) :
    lsOfDays = ["Saturday","Sunday","Monday","Tuesday","Wednesday","Thursday","Friday"]
    dayList = list(lineAsList[1].split(","))
    errorExists = False

    for day in dayList :
        if day in lsOfDays:           
            continue
        else :
            errorExists = True
    if lineAsList[2] != "at":
        errorExists = True
    
    timeList = list(lineAsList[3].split(","))
    for time in timeList :
        if isValidTime(time) and (len(time) == 4):           
            continue
        else :
            errorExists = True
    
    if lineAsList[4] != "run":
        errorExists = True
    
    if not (len(lineAsList) >= 6):
        errorExists = True

    if errorExists:
        return "error in configuration"

    parameters = ' '.join(lineAsList[6:])

    for day in dayList :
        for time in timeList :       
            addRunRecord(mkDateToRun(day,time,"every"),"every",lineAsList[5],parameters,runRecords)
           
    return True

  
def isValidTime(timeStr):
    try: 
        int(timeStr)       # Check string is of integers  
        
        regex = "^([01]?[0-9]|2[0-3])[0-5][0-9]$";  # To check time in 24-hour format.  
        pattern = re.compile(regex)
        isValidFormat = re.search(pattern, timeStr); 

        if isValidFormat:
            return True
        else:
            return False
    except ValueError:
        return False


def atInLine(lineAsList) :
    timeList = list(lineAsList[1].split(","))
    errorExists = False
    for time in timeList :
        if isValidTime(time) and (len(time) == 4):           
            continue
        else :
            errorExists = True
    if (lineAsList[2]) != "run" :
        errorExists = True
    
    if not (len(lineAsList) >= 4):
         errorExists = True
        
    if errorExists:
        return "error in configuration"

    parameters = ' '.join(lineAsList[4:])
    today = datetime.datetime.now()
    for time in timeList :          
        addRunRecord(mkDateToRun(today.strftime('%A'),time,"at"),"once",lineAsList[3],parameters,runRecords)
    
    return True


def onInLine(lineAsList) :

    lsOfDays = ["Saturday","Sunday","Monday","Tuesday","Wednesday","Thursday","Friday"]
    dayList = list(lineAsList[1].split(","))
    errorExists = False

    for day in dayList :
        if day in lsOfDays:           
            continue
        else :
            errorExists = True
    if lineAsList[2] != "at":
        errorExists = True
    
    timeList = list(lineAsList[3].split(","))
    for time in timeList :
        if isValidTime(time) and (len(time) == 4):           
            continue
        else :
            errorExists = True
    
    if lineAsList[4] != "run":
        errorExists = True
    
    if not (len(lineAsList) >= 6):
        errorExists = True

    if errorExists:
        return "error in configuration"

    parameters = ' '.join(lineAsList[6:])

    for day in dayList :
        for time in timeList :           
            addRunRecord(mkDateToRun(day,time,"on"),"once",lineAsList[5],parameters,runRecords)

    return True

def sortRecord(runRecord) :

    sorted(runRecord.keys())
    sortedrecords = {}
    for elem in sorted(runRecord.items()) :
        sortedrecords[elem[0]] = elem[1]
    
    return sortedrecords

def timeToSleep(dateToRun) :

    present = datetime.datetime.now()
    delta = dateToRun - present
    timeToWait = int(delta.total_seconds())

    return timeToWait

 
def writeToStatus(statusfile,message) :

    try:

        if os.path.getsize(statusfile) == 0 :

            statusFile = open(statusfile, "w")
            statusFile.write(message)
            statusFile.close()
        else :
            statusFile = open(statusfile, "a")
            statusFile.write("\n")
            statusFile.write(message)
            statusFile.close()

    except FileNotFoundError as statusFileNotExist :
        sys.stderr.write("file {} file was not found\n".format("runner.status"))
        exit()

# Section 2 - File Creation 
try:
    
    statusFile = open(statusPath, "w+")
    statusFile.close()

except FileNotFoundError as statusFileNotExist :
    sys.stderr.write("file {} File was not found\n".format("runner.status"))
    exit()
except IOError as statusFileNotCreated :
    sys.stderr.write("file {} File was not created\n".format("runner.status"))
    exit()


pid = str(os.getpid())

try:
    
    pidFile = open(pidPath, "w+")
    pidFile.write(pid)
    pidFile.close()

except FileNotFoundError as pidFileNotExist :
    sys.stderr.write("file {} File was not found\n".format("runner.pid"))
    exit()
except IOError as pidFileNotCreated :
    sys.stderr.write("file {} File was not created\n".format("runner.pid"))
    exit()

# Section 3 - Main Parsing Loop 
try:
        
    configFile = open(configPath, "r")
    
    
    if os.path.getsize(configPath) == 0 :
        sys.stderr.write("configuration file empty\n")
        exit()

    count = 0
    messageFlag = None
    while True: 
        line = configFile.readline() 
        
        if not line: 
            break

        count += 1
        
        formattedLine = line.strip("\n").split(" ")
        if formattedLine[0] == "at":
               messageFlag = atInLine(formattedLine)
        
        elif formattedLine[0] == "every":
               messageFlag = everyInLine(formattedLine)
        
        elif formattedLine[0] == "on":
               messageFlag = onInLine(formattedLine)
        else:
            messageFlag = "error in configuration"
        
        if messageFlag == "error in configuration":
            sys.stderr.write("{}: {}\n".format(messageFlag,count))
            exit()

    configFile.close()

except FileNotFoundError as fileNotExist :
    sys.stderr.write("configuration file not found\n")
    exit()

# Section 4 - Signal Catch
def sigCatch(sigNum,frame) :

    sortRecord(runRecords)

    if len(previousRecords) != 0 :
        for record in previousRecords:
            writeToStatus(statusPath,record)

    for key in runRecords:
        path = runRecords.get(key)[1]
        params = runRecords.get(key)[2]
        message = "will run at {} {} {}".format(key.strftime('%c'),path,params)
        writeToStatus(statusPath,message)

signal.signal(signal.SIGUSR1,sigCatch)


# Section 5 - Process Creation/Execution Loop

while len(runRecords) != 0:

    runRecords = sortRecord(runRecords) # First sort records by time
    dateObj = next(iter(runRecords)) #Calculate the time till we run next program and sleep till then 
    time.sleep(timeToSleep(dateObj))
    
    # Run program
    path = next(iter(runRecords.values()))[1]
    params = next(iter(runRecords.values()))[2]
    modParams = [path] + params.split(" ")
    keyword = next(iter(runRecords.values()))[0]

    r,w = os.pipe()
    currentPid = os.fork()
    
    # Parent
    if currentPid > 0:
        my_pid = os.getpid()

        ret_val = os.wait()

        if keyword != "every" :
            del runRecords[dateObj]

        elif keyword == "every" :
            newDateObj = dateObj + timedelta(7)
            del runRecords[dateObj]
            addRunRecord(newDateObj,"every",path,params,runRecords)        

        os.close(w)
        r = os.fdopen(r)
        errorFlag = r.read()

        if errorFlag == "error occurred" :
            errorMsg = "error {} {} {}".format(datetime.datetime.now().strftime('%c'),path,params)
            previousRecords.append(errorMsg)
 
        else :
            successMsg = "ran {} {} {}".format(datetime.datetime.now().strftime('%c'),path,params)
            previousRecords.append(successMsg)
 
    # Child   
    elif currentPid == 0:
        my_pid = os.getpid()
        try:
            
            os.execv(path,modParams)            
        except OSError:
            

            os.close(r)
            w = os.fdopen(w,'w')
            w.write("error occurred")
            w.close()
            exit()

    else:
        sys.stderr.write("fork error\n")


sys.stderr.write("nothing left to run\n")
exit()