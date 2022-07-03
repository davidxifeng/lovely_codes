
import System.Log.Logger
import System.Log.Handler.Syslog
import System.Log.Handler.Simple
import System.Log.Handler (setFormatter)
import System.Log.Formatter

main = do
        putStrLn "begin main''"
        main''
        putStrLn "begin main'"
        main'
        putStrLn "begin re-main''"
        main''

main'' = do
        errorM "test" "This is going to stderr?"
        debugM "MyApp.Component"  "This is a debug message -- never to be seen"
        logM "test1" DEBUG "1.Debug messages"
        logM "test2" INFO "2.Information"
        logM "test3" NOTICE "3.Normal runtime conditions"
        logM "test4" WARNING "4.General Warnings"
        logM "test5" ERROR "5.General Errors"
        logM "test6" CRITICAL "6.Syslogevere situations"
        logM "test7" ALERT "7.Take immediate action"
        logM "test8" EMERGENCY "8.System is unusable"

 -- By default, all messages of level WARNING and above are sent to stderr.
 -- Everything else is ignored.
 -- "MyApp.Component" is an arbitrary string; you can tune
 -- logging behavior based on it later.
main' = do
        updateGlobalLogger "jack" (setLevel DEBUG)
        updateGlobalLogger rootLoggerName (setLevel DEBUG)
        debugM "jack" "This is a debug message -- never to be seen"
        errorM "jack" "This is going to stderr?"
        errorM "test" "This is going to stderr?"
        warningM "MyApp.Component2" "Something Bad is about to happen."
        -- Copy everything to syslog from here on out.
        s <- openlog "SyslogStuff" [PID] USER DEBUG
        warningM "david" "oh yes, I am david"
        updateGlobalLogger rootLoggerName (addHandler s)
        errorM "MyApp.Component" "This is going to stderr and syslog."

        -- Now we'd like to see everything from BuggyComponent
        -- at DEBUG or higher go to syslog and stderr.
        -- Also, we'd like to still ignore things less than
        -- WARNING in other areas.
        -- 
        -- So, we adjust the Logger for MyApp.BuggyComponent.

        updateGlobalLogger "MyApp.BuggyComponent" (setLevel DEBUG)

        -- This message will go to syslog and stderr
        debugM "MyApp.BuggyComponent" "This buggy component is buggy"
        -- This message will go to syslog and stderr too.
        warningM "MyApp.BuggyComponent" "Still Buggy"
        -- This message goes nowhere.
        debugM "MyApp.WorkingComponent" "Hello"

        -- Now we decide we'd also like to log everything from BuggyComponent at DEBUG
        -- or higher to a file for later diagnostics.  We'd also like to customize the
        -- format of the log message, so we use a 'simpleLogFormatter'

        h <- fileHandler "debug.log" DEBUG >>= \lh -> return $
                 setFormatter lh (simpleLogFormatter "[$time : $loggername : $prio] $msg")
        updateGlobalLogger "MyApp.BuggyComponent" (addHandler h)
        -- This message will go to syslog and stderr, 
        -- and to the file "debug.log" with a format like :
        -- [2010-05-23 16:47:28 : MyApp.BuggyComponent : DEBUG] Some useful diagnostics...
        debugM "MyApp.BuggyComponent" "Some useful diagnostics..."
