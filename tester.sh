#!/bin/bash

#### Note : Please run this script and also look at the various other testcases at the end of the script (Script runs for 8 minutes)
#### Beware : Running this script will remove existing runner.conf file, after completion of the script it will be available again

rm ~/.runner.conf

echo "***************************************"
echo "Configuration File Error Handling Tests"
echo "***************************************"

pass="Success"
fail="Fail"




# Test 1 : Duplicate days
printf "every Tuesday,Wednesday,Tuesday at 1200,1100 run /bin/date " >> ~/.runner.conf
python3 runner.py 2>error.log
testMsg1=$(tail -n 1 error.log)

if [[ $testMsg1 == "there is another process scheduled at the same time" ]]
then 
    echo "Test 1: Duplicate days - Result $pass"

else
    echo "Test 1: Duplicate days - Result $fail"
fi

rm ~/.runner.conf
rm error.log

# Test 2 : Bad Syntax - Day
printf "every Tues at 1100 run /bin/date " >> ~/.runner.conf
python3 runner.py 2>error.log
testMsg2=$(tail -n 1 error.log)

if [[ $testMsg2 == "error in configuration: 1" ]]
then 
    echo "Test 2: Bad Syntax (Day) - Result $pass"

else
    echo "Test 2: Bad Syntax (Day) - Result $fail"
fi

rm ~/.runner.conf
rm error.log

# Test 3 : Bad Syntax - Time
printf "every Tuesday at 11000 run /bin/date " >> ~/.runner.conf
python3 runner.py 2>error.log
testMsg3=$(tail -n 1 error.log)

if [[ $testMsg3 == "error in configuration: 1" ]]
then 
    echo "Test 3: Bad Syntax (Time) - Result $pass"

else
    echo "Test 3: Bad Syntax (Time) - Result $fail"
fi

rm ~/.runner.conf
rm error.log

# Test 4 : Bad Syntax - Day (lowercase) and Correct Identification of Line Number
echo "every Tuesday at 1100 run /bin/date " >> ~/.runner.conf
echo "every tuesday at 1100 run /bin/date " >> ~/.runner.conf
python3 runner.py 2>error.log
testMsg4=$(tail -n 1 error.log)

if [[ $testMsg4 == "error in configuration: 2" ]]
then 
    echo "Test 4: Bad Syntax (Day - lowercase) - Result $pass"

else
    echo "Test 4: Bad Syntax (Day - lowercase) - Result $fail"
fi

rm ~/.runner.conf
rm error.log


# Test 5 : Missing run Keyword
printf "on Tuesday at 1100 /bin/date " >> ~/.runner.conf
python3 runner.py 2>error.log
testMsg5=$(tail -n 1 error.log)

if [[ $testMsg5 == "error in configuration: 1" ]]
then 
    echo "Test 5: Missing run Keyword - Result $pass"

else
    echo "Test 5: Missing run Keyword - Result $fail"
fi

rm ~/.runner.conf
rm error.log


# Test 6 : Bad Syntax - Multiple keywords
printf "on every Tuesday at 1100 run /bin/date " >> ~/.runner.conf
python3 runner.py 2>error.log
testMsg6=$(tail -n 1 error.log)

if [[ $testMsg6 == "error in configuration: 1" ]]
then 
    echo "Test 6: Bad Syntax - Multiple keywords - Result $pass"

else
    echo "Test 6: Bad Syntax - Multiple keywords - Result $fail"
fi

rm ~/.runner.conf
rm error.log

# Test 7 : Invalid Range of Time Identified in Mutliple Times
printf "on Tuesday at 1100,2500 run /bin/date " >> ~/.runner.conf
python3 runner.py 2>error.log
testMsg7=$(tail -n 1 error.log)

if [[ $testMsg7 == "error in configuration: 1" ]]
then 
    echo "Test 7: Invalid Range of Time Identified in Mutliple Times - Result $pass"

else
    echo "Test 7: Invalid Range of Time Identified in Mutliple Times - Result $fail"
fi

rm ~/.runner.conf
rm error.log

# Test 8 : Duplicate Day and Time
echo "every Tuesday at 1100 run /bin/date " >> ~/.runner.conf
echo "every Tuesday at 1100 run /bin/date " >> ~/.runner.conf
python3 runner.py 2>error.log
testMsg8=$(tail -n 1 error.log)

if [[ $testMsg8 == "there is another process scheduled at the same time" ]]
then 
    echo "Test 8: Duplicate Day and Time - Result $pass"

else
    echo "Test 8: Duplicate Day and Time - Result $fail"
fi

rm ~/.runner.conf
rm error.log

# Test 9 : Bad Syntax - Path Missing
printf "on Tuesday at 1100,2500 run /bin/date " >> ~/.runner.conf
python3 runner.py 2>error.log
testMsg9=$(tail -n 1 error.log)

if [[ $testMsg9 == "error in configuration: 1" ]]
then 
    echo "Test 9: Bad Syntax (Path Missing) - Result $pass"

else
    echo "Test 9: Bad Syntax (Path Missing) - Result $fail"
fi

rm ~/.runner.conf
rm error.log

# Test 10 : Invalid Time (overflow)
printf "on Tuesday at 1260 run /bin/date" >> ~/.runner.conf
python3 runner.py 2>error.log
testMsg10=$(tail -n 1 error.log)

if [[ $testMsg10 == "error in configuration: 1" ]]
then 
    echo "Test 10: Invalid Time (overflow) - Result $pass"

else
    echo "Test 10: Invalid Time (overflow) - Result $fail"
fi

rm ~/.runner.conf
rm error.log

# Test 11 : Bad Syntax - Invalid Time Format
printf "on Tuesday at 123 run /bin/date" >> ~/.runner.conf
python3 runner.py 2>error.log
testMsg11=$(tail -n 1 error.log)

if [[ $testMsg11 == "error in configuration: 1" ]]
then 
    echo "Test 11: Bad Syntax - Invalid Time Format - Result $pass"

else
    echo "Test 11: Bad Syntax - Invalid Time Format - Result $fail"
fi

rm ~/.runner.conf
rm error.log

# Test 12 : Lines with Same Day and Time 
echo "on Monday at 1100,1200 run /bin/echo Hello" >> ~/.runner.conf
echo "on Monday at 1000,1100 run /bin/echo there" >> ~/.runner.conf
python3 runner.py 2>error.log
testMsg12=$(tail -n 1 error.log)

if [[ $testMsg12 == "there is another process scheduled at the same time" ]]
then 
    echo "Test 12: Lines with Same Day and Time - Result $pass"

else
    echo "Test 12: Lines with Same Day and Time - Result $fail"
fi

rm ~/.runner.conf
rm error.log


# Test 13 : No Configuration File Found
python3 runner.py 2>error.log
testMsg13=$(tail -n 1 error.log)

if [[ $testMsg13 == "configuration file not found" ]]
then 
    echo "Test 13: No Configuration File Found - Result $pass"

else
    echo "Test 13: No Configuration File Found - Result $fail"
fi

rm error.log

echo "***************************************"
echo "Runstatus File Error Handling Tests"
echo "***************************************"



# Test 1 : runner.py Not Running
python3 runstatus.py 2>error.log
testMsg1=$(tail -n 1 error.log)

if [[ $testMsg1 == "status timeout" ]]
then 
    echo "Test 1: runner.py Not Running - Result $pass"

else
    echo "Test 1: runner.py Not Running - Result $fail"
fi

rm error.log

# Test 2 : No PID file found
rm ~/.runner.pid
python3 runstatus.py 2>error.log
testMsg2=$(tail -n 1 error.log)

if [[ $testMsg2 == "file runner.pid file was not found" ]]
then 
    echo "Test 2: No PID file found - Result $pass"

else
    echo "Test 2: No PID file found - Result $fail"
fi

rm error.log

# Test 3 : Invalid PID Found
echo "Hello World" >> ~/.runner.pid
python3 runstatus.py 2>error.log
testMsg3=$(tail -n 1 error.log)

if [[ $testMsg3 == "file runner.pid invalid PID in this file" ]]
then 
    echo "Test 3: Invalid PID Found - Result $pass"

else
    echo "Test 3: Invalid PID Found - Result $fail"
fi
rm ~/.runner.pid
rm error.log

echo "************************************************************"
echo "Runner and RunStatus Integrated Testing By Manual Inspection"
echo "************************************************************"

# Test 1 : every keyword
echo 
echo "Every Keyword Testing"
future=$(date -d '2 minutes'|cut -b 12-16)
hourFuture=$(echo $future | cut -b 1-2)
minFuture=$(echo $future | cut -b 4-5)
today=$(date +"%A")

echo "every $today at $hourFuture$minFuture run /bin/echo Hello World" >> ~/.runner.conf
python3 runner.py &
sleep 10
python3 runstatus.py
sleep 120
python3 runstatus.py
sleep 6

runnerPID=$(tail -n 1  ~/.runner.pid)
kill -9 $runnerPID
rm ~/.runner.conf


# Test 2 : on keyword
echo 
echo "On Keyword Testing"
future=$(date -d '2 minutes'|cut -b 12-16)
hourFuture=$(echo $future | cut -b 1-2)
minFuture=$(echo $future | cut -b 4-5)


echo "on $today,Monday at $hourFuture$minFuture,0010 run /bin/echo Hello World" >> ~/.runner.conf
python3 runner.py &
sleep 10
python3 runstatus.py
sleep 120
python3 runstatus.py
sleep 6

runnerPID=$(tail -n 1  ~/.runner.pid)
kill -9 $runnerPID
rm ~/.runner.conf

# Test 3 : at keyword
echo 
echo "At Keyword Testing"
future=$(date -d '2 minutes'|cut -b 12-16)
hourFuture=$(echo $future | cut -b 1-2)
minFuture=$(echo $future | cut -b 4-5)


echo "at $hourFuture$minFuture,0010 run /bin/echo Hello World" >> ~/.runner.conf
python3 runner.py &
sleep 10
python3 runstatus.py
sleep 120
python3 runstatus.py
sleep 6

runnerPID=$(tail -n 1  ~/.runner.pid)
kill -9 $runnerPID
rm ~/.runner.conf

# Test 4 : Mixed Keywords
echo 
echo "Mixed Keywords Testing"
future=$(date -d '2 minutes'|cut -b 12-16)
hourFuture=$(echo $future | cut -b 1-2)
minFuture=$(echo $future | cut -b 4-5)


echo "at $hourFuture$minFuture run /bin/echo Hello World" >> ~/.runner.conf
echo "on Tuesday at 1100 run /bin/date" >> ~/.runner.conf
echo "on Tuesday at 0000 run /bin/date" >> ~/.runner.conf
echo "every Tuesday at 1200 run /bin/date" >> ~/.runner.conf
echo "every Monday,Tuesday,Wednesday at 0900,1000 run /bin/date" >> ~/.runner.conf
echo "on Tuesday at 0800 run /bin/echo Hello World!" >> ~/.runner.conf

python3 runner.py &
sleep 10
python3 runstatus.py
sleep 120
python3 runstatus.py
sleep 6

runnerPID=$(tail -n 1  ~/.runner.pid)
kill -9 $runnerPID
rm ~/.runner.conf

echo "*********************************************"
echo "Runner and RunStatus Complete Test Variations"
echo "*********************************************"



touch ~/.runner.conf
cat << content > ~/.runner.conf
every Tuesday at 1200,1100 run /bin/date 
every Tuesday,Wednesday,Tuesday at 1200,1100 run /bin/date 
every Tues at 1100 run /bin/date 
every Tuesday at 11000 run /bin/date 
every Tuesday at 1100 run /bin/datehi
every tuesday at 1100 run /bin/date 
on Tuesday at 1100 /bin/echo/touch 
on every Tuesday at 1100 run /bin/date 
on Tuesday at 1100,2500 run /bin/date 
every Tuesday at 1100 run /bin/date 
every Tuesday at 1100 run /bin/date 
on Tuesday at 1100,2500 run /bin/date 
on Tuesday at 1260 run /bin/date
on Tuesday at 123 run /bin/date
on Monday at 1100,1200 run /bin/echo Hello
on Monday at 1000,1100 run /bin/echo there
on Tuesday,Monday at 1100,2500 run /bin/date 
on Tuesday,Monday,St at 1260 run /bin/date
on Tuesday,Monday,Sunday,iji at 123 run /bin/date
at 0730 run /bin/touch
at 0730 run /bin/echohijok kokjoj oj oj
at 0730 run /bin/echo
at 0730 run /bin/tou
at 0730 run /bin/eco
on hi Tuesday at 1100 run /bin/date 
hi Tuesday at 1100 run /bin/date 
on Tuesday hi 1100,2500 run /bin/date 
on Tuesday at hi run /bin/date 
on Tuesday at 1100,2500 hi /bin/date 
on Tuesday at 1100,2500 run hi 
hi Tuesday at 1100 run /bin/date 
every hi at 1100 run /bin/date 
every Tuesday hi 1100 run /bin/date 
every Tuesday at hi run /bin/date 
every Tuesday at 1100 hi /bin/date
every Tuesday at 1100 run hi
hi 0730 run /bin/touch
at hi run /bin/touch
at 0730 hi /bin/touch
at 0730 run hi
every Monday,Tuesday,Wednesday,Thursday,Friday,Saturday,Sunday at 1200,1100,1234 run /bin/date 
on Monday,Tuesday,Wednesday,Thursday,Friday,Saturday,Sunday at 1200,1100,1234 run /bin/date 
at 0000,1111,2222 run /bin/date
at 0100,0200,0300,0400,0500,0600,0700,0800,0900,1000,1100,1200,1300 run /bin/date
content