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
## Naming Resolution
## Network Information
## Selinux
## Installed Packages (satellite)
## Subscriptions
## Repos
## Upgrade
## Disk
## Memory
## CPU
## Messages
## Foreman Tasks
## Hammer Ping
## Katello service status
## MongoDB Storage
## PostgreSQL Storage
## Passenger
## Qpidd
## Foreman logs (error)
## Foreman cron
## Httpd
## RHSM
## Virt-who
## Hypervisors tasks
## Tomcat
## Candlepin
## Cron
## Files in etc/cron*
## Foreman Settings
## PostgreSQL

## Please check out the file /tmp/report-sosreport-sat64test-123456-2019-03-07-obvjctv.log
```
3. Check the generated report file
```
$ less /tmp/report-sosreport-sat64test-123456-2019-03-07-obvjctv.log
```

Hope you enjoy it.
