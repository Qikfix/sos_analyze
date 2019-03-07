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
The sosreport is: sosreport-sat64test-123456-2019-03-07-obvjctv
### Welcome to Report ###
### CEE/SysMGMT ###
## naming resolution
## network information
## installed packages (satellite)
## Subscriptions
## REPOS
## Upgrade
## Disk
## Memory
## CPU
## Foreman Tasks
## Hammer Ping
## Katello service status
## MongoDB
## PostgreSQL
## Passenger
## QPIDD
## Foreman logs (error)
## Foreman cron
## HTTPD
## Hypervisors tasks
## Candlepin
## CRON
## etc/cron*
## Foreman Settings


## Please check out the file /tmp/report-sosreport-sat64test-123456-2019-03-07-obvjctv.log
```
3. Check the generated report file
```
$ less /tmp/report-sosreport-sat64test-123456-2019-03-07-obvjctv.log
```

Hope you enjoy it.
