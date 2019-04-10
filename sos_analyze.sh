#!/bin/bash

#
# Created ....: 03/04/2019
# Developer ..: Waldirio M Pinheiro <waldirio@gmail.com / waldirio@redhat.com>
# Purpose ....: Analyze sosreport and summarize the information (focus on Satellite info)
#

FOREMAN_REPORT="/tmp/$$.log"

main()
{
  > $FOREMAN_REPORT

  sos_path=$1
  base_dir=$sos_path
  final_name=$(echo $base_dir | sed -e 's#/$##g' | grep -o sos.* | awk -F"/" '{print $NF}')

  if [ ! -f $base_dir/version.txt ]; then
    echo "This is not a sosreport dir, please inform the path to the correct one."
    exit 1
  fi

  echo "The sosreport is: $base_dir"												| tee -a $FOREMAN_REPORT

  report $base_dir $sub_dir
}

log_tee()
{
  echo $1 | tee -a $FOREMAN_REPORT
}

log()
{
  echo $1 >> $FOREMAN_REPORT
}

log_cmd()
{
  echo $@ | bash &>> $FOREMAN_REPORT
}


report()
{

  base_dir=$1
  sub_dir=$2

  base_foreman="$1/sos_commands/foreman/foreman-debug/"

  log_tee "### Welcome to Report ###"
  log_tee "### CEE/SysMGMT ###"
  log
  log

  log_tee "## Naming Resolution"
  log

  log "// hosts entries"
  log "cat $base_dir/etc/hosts"
  log "---"
  log_cmd "cat $base_dir/etc/hosts"
  log "---"
  log

  log "// resolv.conf"
  log "cat $base_dir/etc/resolv.conf"
  log "---"
  log_cmd "cat $base_dir/etc/resolv.conf"
  log "---"
  log


  log_tee "## Network Information"
  log

  log "// ip address"
  log "cat $base_dir/ip_addr"
  log "---"
  log_cmd "cat $base_dir/ip_addr"
  log "---"
  log

  log "// current route"
  log "cat $base_dir/route"
  log "---"
  log_cmd "cat $base_dir/route"
  log "---"
  log

  log_tee "## Selinux"
  log

  log "// selinux conf"
  log "cat $base_dir/etc/selinux/config"
  log "---"
  log_cmd "cat $base_dir/etc/selinux/config"
  log "---"
  log




  log_tee "## Installed Packages (satellite)"
  log

  log "// all installed packages which contain satellite"
  log "grep satellite $base_dir/installed-rpms"
  log "---"
  log_cmd "grep satellite $base_dir/installed-rpms"
  log "---"
  log

  log "// packages provided by 3rd party vendors"
  log "cat $base_dir/sos_commands/rpm/package-data | cut -f1,4 | grep -v \"Red Hat\" | sort -k2"
  log "---"
  log_cmd "cat $base_dir/sos_commands/rpm/package-data | cut -f1,4 | grep -v \"Red Hat\" | sort -k2"
  log "---"
  log


  log_tee "## Subscriptions"
  log

  log "// subscription identity"
  log "cat $base_dir/sos_commands/subscription_manager/subscription-manager_identity"
  log "---"
  log_cmd "cat $base_dir/sos_commands/subscription_manager/subscription-manager_identity"
  log "---"
  log

  log "// subsman list installed"
  log "cat $base_dir/sos_commands/subscription_manager/subscription-manager_list_--installed"
  log "---"
  log_cmd "cat $base_dir/sos_commands/subscription_manager/subscription-manager_list_--installed"
  log "---"
  log

  log "// subsman list consumed"
  log "cat $base_dir/sos_commands/subscription_manager/subscription-manager_list_--consumed"
  log "---"
  log_cmd "cat $base_dir/sos_commands/subscription_manager/subscription-manager_list_--consumed"
  log "---"
  log


  log_tee "## Repos"
  log


  log "// enabled repos"
  log "cat $base_dir/sos_commands/yum/yum_-C_repolist"
  log "---"
  log_cmd "cat $base_dir/sos_commands/yum/yum_-C_repolist"
  log "---"
  log

  log "// yum history"
  log "cat $base_dir/sos_commands/yum/yum_history"
  log "---"
  log_cmd "cat $base_dir/sos_commands/yum/yum_history"
  log "---"
  log

  log "// yum.log info"
  log "cat $base_dir/var/log/yum.log"
  log "---"
  log_cmd "cat $base_dir/var/log/yum.log"
  log "---"
  log


  log_tee "## Upgrade"
  log

  log "// Error on the upgrade file"
  log "grep \"^\[ERROR\" $base_dir/sos_commands/foreman/foreman-debug/var/log/foreman-installer/satellite.log | wc -l"
  log "---"
  log_cmd "grep \"^\[ERROR\" $base_dir/sos_commands/foreman/foreman-debug/var/log/foreman-installer/satellite.log	| wc -l"
  log "---"
  log

  log "// Error on the upgrade file (full info)"
  log "grep \"^\[ERROR\" $base_dir/sos_commands/foreman/foreman-debug/var/log/foreman-installer/satellite.log"
  log "---"
  log_cmd "grep \"^\[ERROR\" $base_dir/sos_commands/foreman/foreman-debug/var/log/foreman-installer/satellite.log"
  log "---"
  log

  log "// Upgrade Completed? (6.4 or greater)"
  log "grep \"Upgrade completed\" $base_dir/sos_commands/foreman/foreman-debug/var/log/foreman-installer/satellite.log | wc -l"
  log "---"
  log_cmd "grep \"Upgrade completed\" $base_dir/sos_commands/foreman/foreman-debug/var/log/foreman-installer/satellite.log | wc -l"
  log "---"
  log


  log "// last 20 lines from upgrade log"
  log "tail -20 $base_dir/sos_commands/foreman/foreman-debug/var/log/foreman-installer/satellite.log"
  log "---"
  log_cmd "tail -20 $base_dir/sos_commands/foreman/foreman-debug/var/log/foreman-installer/satellite.log"
  log "---"
  log


  log_tee "## Disk"
  log

  log "// full disk info"
  log "cat $base_dir/df"
  log "---"
  log_cmd "cat $base_dir/df"
  log "---"
  log

  log "// disk space output"
  log "cat $base_dir/sos_commands/foreman/foreman-debug/disk_space_output"
  log "---"
  log_cmd "cat $base_dir/sos_commands/foreman/foreman-debug/disk_space_output"
  log "---"
  log


  log_tee "## Memory"
  log

  log "// memory usage"
  log "cat $base_dir/free"
  log "---"
  log_cmd "cat $base_dir/free"
  log "---"
  log

  log "// TOP 5 memory consumers"
  log "cat $base_dir/ps | sort -nrk6 | head -n5"
  log "---"
  log_cmd "cat $base_dir/ps | sort -nrk6 | head -n5"
  log "---"
  log

  log "// users memory consumers"
  log "cat \$base_foreman/ps-awfux | sort -nr | awk '{print \$1, \$6}' | grep -v ^USER | grep -v ^COMMAND | grep -v \"^ $\" | awk  '{a[\$1] += \$2} END{for (i in a) print i, a[i]}' | sort -nrk2"
  log "---"
  log_cmd "cat $base_foreman/ps-awfux | sort -nr | awk '{print \$1, \$6}' | grep -v ^USER | grep -v ^COMMAND | grep -v \"^ $\" | awk  '{a[\$1] += \$2} END{for (i in a) print i, a[i]}' | sort -nrk2"
  log "---"
  log

  log "// Postgres idle process (candlepin)"
  log "cat \$base_foreman/ps-awfux | grep ^postgres | grep idle$ | grep \"candlepin candlepin\" | wc -l"
  log "---"
  log_cmd "cat $base_foreman/ps-awfux | grep ^postgres | grep idle$ | grep \"candlepin candlepin\" | wc -l"
  log "---"
  log

  log "// Postgres idle process (foreman)"
  log "cat \$base_foreman/ps-awfux | grep ^postgres | grep idle$ | grep \"foreman foreman\" | wc -l"
  log "---"
  log_cmd "cat $base_foreman/ps-awfux | grep ^postgres | grep idle$ | grep \"foreman foreman\" | wc -l"
  log "---"
  log

  log "// Postgres idle process (everything)"
  log "cat \$base_foreman/ps-awfux | grep ^postgres | grep idle$ | wc -l"
  log "---"
  log_cmd "cat $base_foreman/ps-awfux | grep ^postgres | grep idle$ | wc -l"
  log "---"
  log



  log_tee "## CPU"
  log

  log "// cpu's number"
  log "cat $base_dir/proc/cpuinfo | grep processor | wc -l"
  log "---"
  log_cmd "cat $base_dir/proc/cpuinfo | grep processor | wc -l"
  log "---"
  log


  log_tee "## Messages"
  log

  log "// error on message file"
  log "grep ERROR $base_dir/var/log/messages"
  log "---"
  log_cmd "grep ERROR $base_dir/var/log/messages"
  log "---"
  log


  log_tee "## Out of Memory"
  log

  log "// out of memory"
  log "grep \"Out of memory\" $base_dir/var/log/messages"
  log "---"
  log_cmd "grep \"Out of memory\" $base_dir/var/log/messages"
  log "---"
  log


  log_tee "## Foreman Tasks"
  log

  log "// total # of foreman tasks"
  log "cat $base_dir/sos_commands/foreman/foreman-debug/foreman_tasks_tasks.csv | wc -l"
  log "---"
  log_cmd "cat $base_dir/sos_commands/foreman/foreman-debug/foreman_tasks_tasks.csv | wc -l"
  log "---"
  log


  log_tee "## Hammer Ping"
  log

  log "// hammer ping output"
  log "cat $base_dir/sos_commands/foreman/foreman-debug/hammer-ping"
  log "---"
  log_cmd "cat $base_dir/sos_commands/foreman/foreman-debug/hammer-ping"
  log "---"
  log


  log "## Katello service status"
  log

  log "// katello-service status output"
  log "cat $base_dir/sos_commands/foreman/foreman-debug/katello_service_status"
  log "---"
  log_cmd "cat $base_dir/sos_commands/foreman/foreman-debug/katello_service_status"
  log "---"
  log


  log_tee "## MongoDB Storage"
  log

  log "// mongodb storage consumption"
  log "cat $base_dir/sos_commands/foreman/foreman-debug/mongodb_disk_space"
  log "---"
  log_cmd "cat $base_dir/sos_commands/foreman/foreman-debug/mongodb_disk_space"
  log "---"
  log


  log_tee "## PostgreSQL Storage"
  log

  log "// postgres storage consumption"
  log "cat $base_dir/sos_commands/foreman/foreman-debug/postgres_disk_space"
  log "---"
  log_cmd "cat $base_dir/sos_commands/foreman/foreman-debug/postgres_disk_space"
  log "---"
  log


  log_tee "## Passenger"
  log

  log "// current passenger status"
  log "cat $base_dir/sos_commands/foreman/foreman-debug/passenger_status_pool"
  log "---"
  log_cmd "cat $base_dir/sos_commands/foreman/foreman-debug/passenger_status_pool"
  log "---"
  log


  log_tee "## Foreman Tasks"
  log

  log "// dynflow running"
  log "cat $base_dir/sos_commands/foreman/foreman-debug/ps-awfux  | grep dynflow_executor\$"
  log "---"
  log_cmd "cat $base_dir/sos_commands/foreman/foreman-debug/ps-awfux  | grep dynflow_executor$"
  log "---"
  log



  log_tee "## Qpidd"
  log

  log "// katello_event_queue (foreman-tasks / dynflow is running?)"
  log "grep -E '(  queue|  ===|katello_event_queue)' $base_dir/sos_commands/foreman/foreman-debug/qpid-stat-q"
  log "---"
  log_cmd "grep -E '(  queue|  ===|katello_event_queue)' $base_dir/sos_commands/foreman/foreman-debug/qpid-stat-q"
  log "---"
  log


  log "// total number of pulp agents"
  log "cat $base_dir/sos_commands/foreman/foreman-debug/qpid-stat-q | grep pulp.agent | wc -l"
  log "---"
  log_cmd "cat $base_dir/sos_commands/foreman/foreman-debug/qpid-stat-q | grep pulp.agent | wc -l"
  log "---"
  log

  log "// total number of (active) pulp agents"
  log "cat $base_dir/sos_commands/foreman/foreman-debug/qpid-stat-q | grep pulp.agent | grep \"1     1\$\" | wc -l"
  log "---"
  log_cmd "cat $base_dir/sos_commands/foreman/foreman-debug/qpid-stat-q | grep pulp.agent | grep \"1     1\$\" | wc -l"
  log "---"
  log


  log_tee "## Foreman logs (error)"
  log

  log "// total number of errors found on production.log - TOP 40"
  log "grep -h \"\[E\" $base_foreman/var/log/foreman/production.log* | awk '{print \$4, \$5, \$6, \$7, \$8, \$9, \$10, \$11, \$12, \$13}' | sort | uniq -c | sort -nr | head -n40"
  log "---"
  log_cmd "grep -h \"\[E\" $base_foreman/var/log/foreman/production.log* | awk '{print \$4, \$5, \$6, \$7, \$8, \$9, \$10, \$11, \$12, \$13}' | sort | uniq -c | sort -nr | head -n40"
  log "---"
  log



  log_tee "## Foreman cron"
  log

  log "// last 20 entries from foreman/cron.log"
  log "tail -20 $base_foreman/var/log/foreman/cron.log"
  log "---"
  log_cmd "tail -20 $base_foreman/var/log/foreman/cron.log"
  log "---"
  log


  log_cmd "## Httpd"
  log

  log "// queues on error_log means the # of requests crossed the border. Satellite inaccessible"
  log "grep queue $base_foreman/var/log/httpd/error_log | wc -l"
  log "---"
  log_cmd "grep queue $base_foreman/var/log/httpd/error_log | wc -l"
  log "---"
  log

  log "// when finding something on last step, we will here per date"
  log "grep queue $base_foreman/var/log/httpd/error_log  | awk '{print \$2, \$3}' | cut -d: -f1,2 | uniq -c"
  log "---"
  log_cmd "grep queue $base_foreman/var/log/httpd/error_log  | awk '{print \$2, \$3}' | cut -d: -f1,2 | uniq -c"
  log "---"
  log

  log "// TOP 20 of ip address requesting the satellite via https"
  log "cat $base_foreman/var/log/httpd/foreman-ssl_access_ssl.log | awk '{print \$1}' | sort | uniq -c | sort -nr | head -n20"
  log "---"
  log_cmd "cat $base_foreman/var/log/httpd/foreman-ssl_access_ssl.log | awk '{print \$1}' | sort | uniq -c | sort -nr | head -n20"
  log "---"
  log

  log "// TOP 20 of ip address requesting the satellite via https (detailed)"
  log "cat $base_foreman/var/log/httpd/foreman-ssl_access_ssl.log | awk '{print \$1,\$4}' | cut -d: -f1,2,3 | uniq -c | sort -nr | head -n20"
  log "---"
  log_cmd "cat $base_foreman/var/log/httpd/foreman-ssl_access_ssl.log | awk '{print \$1,\$4}' | cut -d: -f1,2,3 | uniq -c | sort -nr | head -n20"
  log "---"
  log

  log "// TOP 50 of uri requesting the satellite via https"
  log "cat $base_foreman/var/log/httpd/foreman-ssl_access_ssl.log | awk '{print \$1, \$6, \$7}' | sort | uniq -c | sort -nr | head -n 50"
  log "---"
  log_cmd "cat $base_foreman/var/log/httpd/foreman-ssl_access_ssl.log | awk '{print \$1, \$6, \$7}' | sort | uniq -c | sort -nr | head -n 50"
  log "---"
  log



  log_tee "## RHSM"
  log

  log "// RHSM errors"
  log "grep ERROR $base_dir/var/log/rhsm/rhsm.log"
  log "---"
  log_cmd "grep ERROR $base_dir/var/log/rhsm/rhsm.log"
  log "---"
  log

  log "// RHSM Warnings"
  log "grep WARNING $base_dir/var/log/rhsm/rhsm.log"
  log "---"
  log_cmd "grep WARNING $base_dir/var/log/rhsm/rhsm.log"
  log "---"
  log

  log "// Sending updated Host-to-guest"
  log "grep \"Sending updated Host-to-guest\" $base_dir/var/log/rhsm/rhsm.log"
  log "---"
  log_cmd "grep \"Sending updated Host-to-guest\" $base_dir/var/log/rhsm/rhsm.log"
  log "---"
  log




  log_tee "## Virt-who"
  log

  log "// virt-who configuration"
  log "ls -l $base_dir/etc/virt-who.d"
  log "---"
  log_cmd "ls -l $base_dir/etc/virt-who.d"
  log "---"
  log

  log "// virt-who configuration content files"
  log "for b in \$(ls -1 \$base_dir/etc/virt-who.d/*); do echo; echo \$b; echo \"===\"; cat \$b; echo \"===\"; done"
  log "---"
  log_cmd "for b in $(ls -1 $base_dir/etc/virt-who.d/*); do echo; echo $b; echo \"===\"; cat $b; echo \"===\"; done"
  log "---"
  log

  log "// virt-who configuration content files (hidden characters)"
  log "for b in \$(ls -1 \$base_dir/etc/virt-who.d/*); do echo; echo \$b; echo \"===\"; cat -vet \$b; echo \"===\"; done"
  log "---"
  log_cmd "for b in $(ls -1 $base_dir/etc/virt-who.d/*); do echo; echo $b; echo \"===\"; cat -vet $b; echo \"===\"; done"
  log "---"
  log


  log_tee "## Hypervisors tasks"
  log

  log "// latest 30 hypervisors tasks"
  log "cat $base_foreman/foreman_tasks_tasks.csv | grep Hypervisors | sed -e 's/,/ /g' | sort -rk4 | head -n 30"
  log "---"
  log_cmd "cat $base_foreman/foreman_tasks_tasks.csv | grep Hypervisors | sed -e 's/,/ /g' | sort -rk4 | head -n 30"
  log "---"
  log


  log_tee "## Tomcat"
  log

  log "// Memory (Xms and Xmx)"
  log "grep tomcat $base_foreman/ps-awfux"
  log "---"
  log_cmd "grep tomcat $base_foreman/ps-awfux"
  log "---"
  log

  log "// cpdb"
  log "cat $base_foreman/var/log/candlepin/cpdb.log"
  log "---"
  log_cmd "cat $base_foreman/var/log/candlepin/cpdb.log"
  log "---"
  log


  log_tee "## Candlepin"
  log

  log "// latest state of candlepin (updating info)"
  log "grep -B1 Updated $base_foreman/var/log/candlepin/candlepin.log"
  log "---"
  log_cmd "grep -B1 Updated $base_foreman/var/log/candlepin/candlepin.log"
  log "---"
  log

  log "// ERROR on candlepin log - candlepin.log"
  log "grep ERROR $base_foreman/var/log/candlepin/candlepin.log | cut -d ' ' -f1,3- | uniq -c"
  log "---"
  log_cmd "grep ERROR $base_foreman/var/log/candlepin/candlepin.log | cut -d ' ' -f1,3- | uniq -c"
  log "---"
  log

  log "// ERROR on candlepin log - error.log"
  log "grep ERROR $base_foreman/var/log/candlepin/error.log | cut -d ' ' -f1,3- | uniq -c"
  log "---"
  log_cmd "grep ERROR $base_foreman/var/log/candlepin/error.log | cut -d ' ' -f1,3- | uniq -c"
  log "---"
  log

  log "// latest entry on error.log"
  log "tail -30 $base_foreman/var/log/candlepin/error.log"
  log "---"
  log_cmd "tail -30 $base_foreman/var/log/candlepin/error.log"
  log "---"
  log



  log_tee "## Cron"
  log

  log "// cron from the base OS"
  log "ls -l $base_dir/var/spool/cron/*"
  log "---"
  log_cmd "ls -l $base_dir/var/spool/cron/*"
  log "---"
  log

  log "// checking the content of base OS cron"
  log "for b in \$(ls -1 $base_dir/var/spool/cron/*); do echo; echo \$b; echo \"===\"; cat \$b; echo \"===\"; done"
  log "---"
  log_cmd "for b in $(ls -1 $base_dir/var/spool/cron/*); do echo; echo $b; echo \"===\"; cat $b; echo \"===\"; done"
  log "---"
  log


  log_tee "## Files in etc/cron*"
  log

  log "// all files located on /etc/cron*"
  log "find $base_dir/etc/cron* -type f | awk 'FS=\"/etc/\" {print \$2}'"
  log "---"
  log_cmd "find $base_dir/etc/cron* -type f | awk 'FS=\"/etc/\" {print $2}'"
  log "---"
  log


#  echo "## Audit"										| tee -a $FOREMAN_REPORT
#  echo 																											>> $FOREMAN_REPORT
#$ cat var/log/audit/audit.log

  log_tee "## Foreman Settings"
  log

  log "// foreman settings"
  log "cat $base_foreman/etc/foreman/settings.yaml"
  log "---"
  log_cmd "cat $base_foreman/etc/foreman/settings.yaml"
  log "---"
  log

  log "// custom hiera"
  log "cat $base_foreman/etc/foreman-installer/custom-hiera.yaml"
  log "---"
  log_cmd "cat $base_foreman/etc/foreman-installer/custom-hiera.yaml"
  log "---"
  log


  log_tee "## PostgreSQL"
  log

  log "// Deadlock count"
  log "grep -h -i deadlock $base_foreman/var/lib/pgsql/data/pg_log/*.log | wc -l"
  log "---"
  log_cmd "grep -h -i deadlock $base_foreman/var/lib/pgsql/data/pg_log/*.log | wc -l"
  log "---"
  log

  log "// Deadlock"
  log "grep -h -i deadlock $base_foreman/var/lib/pgsql/data/pg_log/*.log"
  log "---"
  log_cmd "grep -h -i deadlock $base_foreman/var/lib/pgsql/data/pg_log/*.log"
  log "---"
  log

  log "// ERROR count"
  log "grep ERROR $base_foreman/var/lib/pgsql/data/pg_log/*.log | wc -l"
  log "---"
  log_cmd "grep ERROR $base_foreman/var/lib/pgsql/data/pg_log/*.log | wc -l"
  log "---"
  log

  log "// ERROR"
  log "grep -h ERROR $base_foreman/var/lib/pgsql/data/pg_log/*.log"
  log "---"
  log_cmd "grep -h ERROR $base_foreman/var/lib/pgsql/data/pg_log/*.log"
  log "---"
  log




  log "// Current Configuration"
  log "cat $base_foreman/var/lib/pgsql/data/postgresql.conf | grep -v ^# | grep -v ^$ | grep -v -P ^\"\\t\\t\".*#"
  log "---"
  log_cmd "cat $base_foreman/var/lib/pgsql/data/postgresql.conf | grep -v ^# | grep -v ^$ | grep -v -P ^\"\\t\\t\".*#"
  log "---"
  log




## TODO

# cat apache/rpm_-V_httpd 
# cat foreman/rpm_-V_foreman-debug 
# cat krb5/rpm_-V_krb5-libs 
# cat ldap/rpm_-V_openldap 
# cat postgresql/rpm_-V_postgresql 
# cat qpid/rpm_-V_qpid-cpp-server_qpid-tools 
# cat qpid_dispatch/rpm_-V_qpid-dispatch-router 
# cat tomcat/rpm_-V_tomcat 
# cat virtwho/rpm_-V_virt-who 






  mv $FOREMAN_REPORT /tmp/report_${USER}_$final_name.log
  echo 
  echo
  echo "## Please check out the file /tmp/report_${USER}_$final_name.log"
}





# Main

if [ "$1" == "" ]; then
  echo "Please inform the path to the sosrepor dir that you would like to analyze."
  echo "$0 01234567/sosreport_do_wall"
  exit 1
fi

main $1
