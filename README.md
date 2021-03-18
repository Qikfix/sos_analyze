Script used to analyze the sosreport file (focus on Satellite info)

To use it.

1. Extract the sosreport
```
# ll
-rw-------. 1 root root 21735576 Mar  7 15:57 sosreport-sat64test-123456-2019-03-07-obvjctv.tar.xz
#

# tar xf sosreport-sat64test-123456-2019-03-07-obvjctv.tar.xz 
# ll
drwx------. 14 root root     4096 Mar  7 15:56 sosreport-sat64test-123456-2019-03-07-obvjctv
-rw-------.  1 root root 21735576 Mar  7 15:57 sosreport-sat64test-123456-2019-03-07-obvjctv.tar.xz
# 
```
2. Execute the command as below 
```
<file path or $PATH>/sos_analyze.sh <sosreport_dir>
```
The output will be similar to below
```
$ ./sos_analyze.sh sosreport-sat64test-123456-2019-03-07-obvjctv
The sosreport is: sosreport-sat64test-123456-2019-03-07-obvjctv/
creating soft links for compatibility...

### Welcome to Report ###
### CEE/SysMGMT ###

## Date
## Case Summary
## Platform
## Memory
## Storage
## Proxies
## Network Information
## Environment
## SELinux
## cron
## /var/log/messages

## Repos and Packages
## Satellite Upgrade
## Subscriptions
## /var/log/rhsm/rhsm.log
## Satellite Services

## goferd
## PostgreSQL
## MongoDB
## httpd (Apache)
## Passenger
## Puppet Server
## Foreman
## Katello
## Dynflow
## Pulp
## Tomcat
## Candlepin
## virt-who
## qpidd
## qdrouterd
## Subscription Watch

Calling xsos...


Calling insights...
done.


## The output has been saved in these locations:
    report_jrichards2_sosreport-sat64test-123456-2019-03-07-obvjctv.log
    /tmp/report_jrichards2_sosreport-sat64test-123456-2019-03-07-obvjctv.log
```
3. Check the generated report file
```
$ less /tmp/report-sosreport-sat64test-123456-2019-03-07-obvjctv.log
```


#Note. You will see the file as below. The content is all the commands executed by this script.
#```
#internals_help/executed_commands.txt
#```

Hope you enjoy it.
