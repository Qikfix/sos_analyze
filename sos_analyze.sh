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

  log "// packags provided by 3rd party vendors"
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


  echo "## Upgrade"																																																			| tee -a $FOREMAN_REPORT
  echo 																																																									>> $FOREMAN_REPORT

  echo "// Error on the upgrade file"																																										>> $FOREMAN_REPORT
  echo "grep \"^\[ERROR\" $base_dir/sos_commands/foreman/foreman-debug/var/log/foreman-installer/satellite.log | wc -l"	>> $FOREMAN_REPORT
  echo "---"																																																						>> $FOREMAN_REPORT
  grep "^\[ERROR" $base_dir/sos_commands/foreman/foreman-debug/var/log/foreman-installer/satellite.log	| wc -l					&>> $FOREMAN_REPORT
  echo "---"																																																						>> $FOREMAN_REPORT
  echo 																																																									>> $FOREMAN_REPORT

  echo "// Error on the upgrade file (full info)"																																				>> $FOREMAN_REPORT
  echo "grep \"^\[ERROR\" $base_dir/sos_commands/foreman/foreman-debug/var/log/foreman-installer/satellite.log"					>> $FOREMAN_REPORT
  echo "---"																																																						>> $FOREMAN_REPORT
  grep "^\[ERROR" $base_dir/sos_commands/foreman/foreman-debug/var/log/foreman-installer/satellite.log									&>> $FOREMAN_REPORT
  echo "---"																																																						>> $FOREMAN_REPORT
  echo 																																																									>> $FOREMAN_REPORT

  echo "// Upgrade Completed? (6.4 or greater)"																																										>> $FOREMAN_REPORT
  echo "grep \"Upgrade completed\" $base_dir/sos_commands/foreman/foreman-debug/var/log/foreman-installer/satellite.log | wc -l"	>> $FOREMAN_REPORT
  echo "---"																																																											>> $FOREMAN_REPORT
  grep "Upgrade completed" $base_dir/sos_commands/foreman/foreman-debug/var/log/foreman-installer/satellite.log | wc -l						&>> $FOREMAN_REPORT
  echo "---"																																																											>> $FOREMAN_REPORT
  echo 																																																														>> $FOREMAN_REPORT


  echo "// last 20 lines from upgrade log"																															>> $FOREMAN_REPORT
  echo "tail -20 $base_dir/sos_commands/foreman/foreman-debug/var/log/foreman-installer/satellite.log"	>> $FOREMAN_REPORT
  echo "---"																																														>> $FOREMAN_REPORT
  tail -20 $base_dir/sos_commands/foreman/foreman-debug/var/log/foreman-installer/satellite.log					&>> $FOREMAN_REPORT
  echo "---"																																														>> $FOREMAN_REPORT
  echo 																																																	>> $FOREMAN_REPORT


  echo "## Disk"																										| tee -a $FOREMAN_REPORT
  echo 																															>> $FOREMAN_REPORT


  echo "// full disk info"																					>> $FOREMAN_REPORT
  echo "cat $base_dir/df"																						>> $FOREMAN_REPORT
  echo "---"																												>> $FOREMAN_REPORT
  cat $base_dir/df																									&>> $FOREMAN_REPORT
  echo "---"																												>> $FOREMAN_REPORT
  echo 																															>> $FOREMAN_REPORT

  echo "// disk space output"																									>> $FOREMAN_REPORT
  echo "cat $base_dir/sos_commands/foreman/foreman-debug/disk_space_output"		>> $FOREMAN_REPORT
  echo "---"																																	>> $FOREMAN_REPORT
  cat $base_dir/sos_commands/foreman/foreman-debug/disk_space_output					&>> $FOREMAN_REPORT
  echo "---"																																	>> $FOREMAN_REPORT
  echo 																																				>> $FOREMAN_REPORT


  echo "## Memory"																														| tee -a $FOREMAN_REPORT
  echo 																																				>> $FOREMAN_REPORT

  echo "// memory usage"																											>> $FOREMAN_REPORT
  echo "cat $base_dir/free"																										>> $FOREMAN_REPORT
  echo "---"																																	>> $FOREMAN_REPORT
  cat $base_dir/free																													&>> $FOREMAN_REPORT
  echo "---"																																	>> $FOREMAN_REPORT
  echo 																																				>> $FOREMAN_REPORT

  echo "// TOP 5 memory consumers"																						>> $FOREMAN_REPORT
  echo "cat $base_dir/ps | sort -nrk6 | head -n5"															>> $FOREMAN_REPORT
  echo "---"																																	>> $FOREMAN_REPORT
  cat $base_dir/ps | sort -nrk6 | head -n5																		&>> $FOREMAN_REPORT
  echo "---"																																	>> $FOREMAN_REPORT
  echo 																																				>> $FOREMAN_REPORT

  echo "// users memory consumers"																																																																						>> $FOREMAN_REPORT
  echo "cat \$base_foreman/ps-awfux | sort -nr | awk '{print \$1, \$6}' | grep -v ^USER | grep -v ^COMMAND | awk  '{a[\$1] += \$2} END{for (i in a) print i, a[i]}' | sort -nrk2"	>> $FOREMAN_REPORT
  echo "---"																																																																																	>> $FOREMAN_REPORT
  cat $base_foreman/ps-awfux | sort -nr | awk '{print $1, $6}' | grep -v ^USER | grep -v ^COMMAND | awk  '{a[$1] += $2} END{for (i in a) print i, a[i]}' | sort -nrk2					&>> $FOREMAN_REPORT
  echo "---"																																																																																	>> $FOREMAN_REPORT
  echo 																																																																																				>> $FOREMAN_REPORT

  echo "// Postgres idle process (candlepin)"																																	>> $FOREMAN_REPORT
  echo "cat \$base_foreman/ps-awfux | grep ^postgres | grep idle$ | grep \"candlepin candlepin\" | wc -l"			>> $FOREMAN_REPORT
  echo "---"																																																	>> $FOREMAN_REPORT
  cat $base_foreman/ps-awfux | grep ^postgres | grep idle$ | grep "candlepin candlepin" | wc -l								&>> $FOREMAN_REPORT
  echo "---"																																																	>> $FOREMAN_REPORT
  echo 																																																				>> $FOREMAN_REPORT

  echo "// Postgres idle process (foreman)"																																		>> $FOREMAN_REPORT
  echo "cat \$base_foreman/ps-awfux | grep ^postgres | grep idle$ | grep \"foreman foreman\" | wc -l"					>> $FOREMAN_REPORT
  echo "---"																																																	>> $FOREMAN_REPORT
  cat $base_foreman/ps-awfux | grep ^postgres | grep idle$ | grep "foreman foreman" | wc -l										&>> $FOREMAN_REPORT
  echo "---"																																																	>> $FOREMAN_REPORT
  echo 																																																				>> $FOREMAN_REPORT

  echo "// Postgres idle process (everything)"																																>> $FOREMAN_REPORT
  echo "cat \$base_foreman/ps-awfux | grep ^postgres | grep idle$ | wc -l"																		>> $FOREMAN_REPORT
  echo "---"																																																	>> $FOREMAN_REPORT
  cat $base_foreman/ps-awfux | grep ^postgres | grep idle$ | wc -l																						&>> $FOREMAN_REPORT
  echo "---"																																																	>> $FOREMAN_REPORT
  echo 																																																				>> $FOREMAN_REPORT



  echo "## CPU"																																| tee -a $FOREMAN_REPORT
  echo 																																				>> $FOREMAN_REPORT

  echo "// cpu's number"																											>> $FOREMAN_REPORT
  echo "cat $base_dir/proc/cpuinfo | grep processor | wc -l"									>> $FOREMAN_REPORT
  echo "---"																																	>> $FOREMAN_REPORT
  cat $base_dir/proc/cpuinfo | grep processor | wc -l													&>> $FOREMAN_REPORT
  echo "---"																																	>> $FOREMAN_REPORT
  echo 																																				>> $FOREMAN_REPORT


  echo "## Messages"																													| tee -a $FOREMAN_REPORT
  echo 																																				>> $FOREMAN_REPORT

  echo "// error on message file"																							>> $FOREMAN_REPORT
  echo "grep ERROR $base_dir/var/log/messages"																>> $FOREMAN_REPORT
  echo "---"																																	>> $FOREMAN_REPORT
  grep ERROR $base_dir/var/log/messages																				&>> $FOREMAN_REPORT
  echo "---"																																	>> $FOREMAN_REPORT
  echo 																																				>> $FOREMAN_REPORT


  echo "## Out of Memory"																													| tee -a $FOREMAN_REPORT
  echo 																																				>> $FOREMAN_REPORT

  echo "// out of memory"																							>> $FOREMAN_REPORT
  echo "grep 'Out of memory' $base_dir/var/log/messages"																>> $FOREMAN_REPORT
  echo "---"																																	>> $FOREMAN_REPORT
  grep 'Out of memory' $base_dir/var/log/messages																				&>> $FOREMAN_REPORT
  echo "---"																																	>> $FOREMAN_REPORT
  echo 																																				>> $FOREMAN_REPORT


  echo "## Foreman Tasks"																																	| tee -a $FOREMAN_REPORT
  echo 																																										>> $FOREMAN_REPORT

  echo "// total # of foreman tasks"																											>> $FOREMAN_REPORT
  echo "cat $base_dir/sos_commands/foreman/foreman-debug/foreman_tasks_tasks.csv | wc -l"	>> $FOREMAN_REPORT
  echo "---"																																							>> $FOREMAN_REPORT
  cat $base_dir/sos_commands/foreman/foreman-debug/foreman_tasks_tasks.csv | wc -l				&>> $FOREMAN_REPORT
  echo "---"																																							>> $FOREMAN_REPORT
  echo 																																										>> $FOREMAN_REPORT


  echo "## Hammer Ping"																																		| tee -a $FOREMAN_REPORT
  echo 																																										>> $FOREMAN_REPORT

  echo "// hammer ping output"																														>> $FOREMAN_REPORT
  echo "cat $base_dir/sos_commands/foreman/foreman-debug/hammer-ping"											>> $FOREMAN_REPORT
  echo "---"																																							>> $FOREMAN_REPORT
  cat $base_dir/sos_commands/foreman/foreman-debug/hammer-ping														&>> $FOREMAN_REPORT
  echo "---"																																							>> $FOREMAN_REPORT
  echo 																																										>> $FOREMAN_REPORT


  echo "## Katello service status"																												| tee -a $FOREMAN_REPORT
  echo 																																										>> $FOREMAN_REPORT

  echo "// katello-service status output"																									>> $FOREMAN_REPORT
  echo "cat $base_dir/sos_commands/foreman/foreman-debug/katello_service_status"					>> $FOREMAN_REPORT
  echo "---"																																							>> $FOREMAN_REPORT
  cat $base_dir/sos_commands/foreman/foreman-debug/katello_service_status  								&>> $FOREMAN_REPORT
  echo "---"																																							>> $FOREMAN_REPORT
  echo 																																										>> $FOREMAN_REPORT


  echo "## MongoDB Storage"																																| tee -a $FOREMAN_REPORT
  echo 																																										>> $FOREMAN_REPORT

  echo "// mongodb storage consumption"																										>> $FOREMAN_REPORT
  echo "cat $base_dir/sos_commands/foreman/foreman-debug/mongodb_disk_space"							>> $FOREMAN_REPORT
  echo "---"																																							>> $FOREMAN_REPORT
  cat $base_dir/sos_commands/foreman/foreman-debug/mongodb_disk_space											&>> $FOREMAN_REPORT
  echo "---"																																							>> $FOREMAN_REPORT
  echo 																																										>> $FOREMAN_REPORT


  echo "## PostgreSQL Storage"																														| tee -a $FOREMAN_REPORT
  echo 																																										>> $FOREMAN_REPORT

  echo "// postgres storage consumption"																									>> $FOREMAN_REPORT
  echo "cat $base_dir/sos_commands/foreman/foreman-debug/postgres_disk_space"							>> $FOREMAN_REPORT
  echo "---"																																							>> $FOREMAN_REPORT
  cat $base_dir/sos_commands/foreman/foreman-debug/postgres_disk_space										&>> $FOREMAN_REPORT
  echo "---"																																							>> $FOREMAN_REPORT
  echo 																																										>> $FOREMAN_REPORT


  echo "## Passenger"																																			| tee -a $FOREMAN_REPORT
  echo 																																										>> $FOREMAN_REPORT

  echo "// current passenger status"																											>> $FOREMAN_REPORT
  echo "cat $base_dir/sos_commands/foreman/foreman-debug/passenger_status_pool"						>> $FOREMAN_REPORT
  echo "---"																																							>> $FOREMAN_REPORT
  cat $base_dir/sos_commands/foreman/foreman-debug/passenger_status_pool									&>> $FOREMAN_REPORT
  echo "---"																																							>> $FOREMAN_REPORT
  echo 																																										>> $FOREMAN_REPORT


  echo "## Foreman Tasks"																																					| tee -a $FOREMAN_REPORT
  echo 																																														>> $FOREMAN_REPORT

  echo "// dynflow running"																																				>> $FOREMAN_REPORT
  echo "cat $base_dir/sos_commands/foreman/foreman-debug/ps-awfux  | grep dynflow_executor\$"			>> $FOREMAN_REPORT
  echo "---"																																											>> $FOREMAN_REPORT
  cat $base_dir/sos_commands/foreman/foreman-debug/ps-awfux  | grep dynflow_executor$		 					&>> $FOREMAN_REPORT
  echo "---"																																											>> $FOREMAN_REPORT
  echo 																																														>> $FOREMAN_REPORT



  echo "## Qpidd"																																																	| tee -a $FOREMAN_REPORT
  echo 																																																						>> $FOREMAN_REPORT

  echo "// katello_event_queue (foreman-tasks / dynflow is running?)"																														>> $FOREMAN_REPORT
  echo "grep -E '(  queue|  ===|katello_event_queue)' $base_dir/sos_commands/foreman/foreman-debug/qpid-stat-q"									>> $FOREMAN_REPORT
  echo "---"																																																										>> $FOREMAN_REPORT
  grep -E '(  queue|  ===|katello_event_queue)' $base_dir/sos_commands/foreman/foreman-debug/qpid-stat-q 												&>> $FOREMAN_REPORT
  echo "---"																																																										>> $FOREMAN_REPORT
  echo 																																																													>> $FOREMAN_REPORT


  echo "// total number of pulp agents"																																						>> $FOREMAN_REPORT
  echo "cat $base_dir/sos_commands/foreman/foreman-debug/qpid-stat-q | grep pulp.agent | wc -l"										>> $FOREMAN_REPORT
  echo "---"																																																			>> $FOREMAN_REPORT
  cat $base_dir/sos_commands/foreman/foreman-debug/qpid-stat-q | grep pulp.agent | wc -l													&>> $FOREMAN_REPORT
  echo "---"																																																			>> $FOREMAN_REPORT
  echo 																																																						>> $FOREMAN_REPORT

  echo "// total number of (active) pulp agents"																																		>> $FOREMAN_REPORT
  echo "cat $base_dir/sos_commands/foreman/foreman-debug/qpid-stat-q | grep pulp.agent | grep "1     1\$" | wc -l"	>> $FOREMAN_REPORT
  echo "---"																																																				>> $FOREMAN_REPORT
  cat $base_dir/sos_commands/foreman/foreman-debug/qpid-stat-q | grep pulp.agent | grep "1     1$" | wc -l					&>> $FOREMAN_REPORT
  echo "---"																																																				>> $FOREMAN_REPORT
  echo 																																																							>> $FOREMAN_REPORT


  echo "## Foreman logs (error)"																						| tee -a $FOREMAN_REPORT
  echo 																																			>> $FOREMAN_REPORT

  echo "// total number of errors found on production.log"																																																							>> $FOREMAN_REPORT
  echo "grep -h \"\[E\" $base_foreman/var/log/foreman/production.log* | awk '{print \$4, \$5, \$6, \$7, \$8, \$9, \$10, \$11, \$12, \$13}' | sort | uniq -c | sort -nr"	>> $FOREMAN_REPORT
  echo "---"																																																																														>> $FOREMAN_REPORT
  grep -h "\[E" $base_foreman/var/log/foreman/production.log* | awk '{print $4, $5, $6, $7, $8, $9, $10, $11, $12, $13}' | sort | uniq -c | sort -nr										&>> $FOREMAN_REPORT
  echo "---"																																																																														>> $FOREMAN_REPORT
  echo 																																																																																	>> $FOREMAN_REPORT



  echo "## Foreman cron"																		| tee -a $FOREMAN_REPORT
  echo 																											>> $FOREMAN_REPORT

  echo "// last 20 entries from foreman/cron.log"						>> $FOREMAN_REPORT
  echo "tail -20 $base_foreman/var/log/foreman/cron.log"		>> $FOREMAN_REPORT
  echo "---"																								>> $FOREMAN_REPORT
  tail -20 $base_foreman/var/log/foreman/cron.log						&>> $FOREMAN_REPORT
  echo "---"																								>> $FOREMAN_REPORT
  echo 																											>> $FOREMAN_REPORT


  echo "## Httpd"																																										| tee -a $FOREMAN_REPORT
  echo 																																															>> $FOREMAN_REPORT

  echo "// queues on error_log means the # of requests crossed the border. Satellite inaccessible"	>> $FOREMAN_REPORT
  echo "grep queue $base_foreman/var/log/httpd/error_log | wc -l"																		>> $FOREMAN_REPORT
  echo "---"																																												>> $FOREMAN_REPORT
  grep queue $base_foreman/var/log/httpd/error_log | wc -l																					&>> $FOREMAN_REPORT
  echo "---"																																												>> $FOREMAN_REPORT
  echo 																																															>> $FOREMAN_REPORT

  echo "// when finding something on last step, we will here per date"																			>> $FOREMAN_REPORT
  echo "grep queue $base_foreman/var/log/httpd/error_log  | awk '{print $2, $3}' | cut -d: -f1,2 | uniq -c"	>> $FOREMAN_REPORT
  echo "---"																																																>> $FOREMAN_REPORT
  grep queue $base_foreman/var/log/httpd/error_log  | awk '{print $2, $3}' | cut -d: -f1,2 | uniq -c				&>> $FOREMAN_REPORT
  echo "---"																																																>> $FOREMAN_REPORT
  echo 																																																			>> $FOREMAN_REPORT

  echo "// TOP 20 of ip address requesting the satellite via https"																															>> $FOREMAN_REPORT
  echo "cat $base_foreman/var/log/httpd/foreman-ssl_access_ssl.log | awk '{print \$1}' | sort | uniq -c | sort -nr | head -n20"	>> $FOREMAN_REPORT
  echo "---"																																																										>> $FOREMAN_REPORT
  cat $base_foreman/var/log/httpd/foreman-ssl_access_ssl.log | awk '{print $1}' | sort | uniq -c | sort -nr | head -n20					&>> $FOREMAN_REPORT
  echo "---"																																																										>> $FOREMAN_REPORT
  echo 																																																													>> $FOREMAN_REPORT

  echo "// TOP 20 of ip address requesting the satellite via https (detailed)"																																	>> $FOREMAN_REPORT
  echo "cat $base_foreman/var/log/httpd/foreman-ssl_access_ssl.log | awk '{print \$1,\$4}' | cut -d: -f1,2,3 | uniq -c | sort -nr | head -n20"	>> $FOREMAN_REPORT
  echo "---"																																																																		>> $FOREMAN_REPORT
  cat $base_foreman/var/log/httpd/foreman-ssl_access_ssl.log | awk '{print $1,$4}' | cut -d: -f1,2,3 | uniq -c | sort -nr | head -n20						&>> $FOREMAN_REPORT
  echo "---"																																																																		>> $FOREMAN_REPORT
  echo 																																																																					>> $FOREMAN_REPORT

  echo "// TOP 50 of uri requesting the satellite via https"																																										>> $FOREMAN_REPORT
  echo "cat $base_foreman/var/log/httpd/foreman-ssl_access_ssl.log | awk '{print $1, $6, $7}' | sort | uniq -c | sort -nr | head -n 50"					>> $FOREMAN_REPORT
  echo "---"																																																																		>> $FOREMAN_REPORT
  cat $base_foreman/var/log/httpd/foreman-ssl_access_ssl.log | awk '{print $1, $6, $7}' | sort | uniq -c | sort -nr | head -n 50								&>> $FOREMAN_REPORT
  echo "---"																																																																		>> $FOREMAN_REPORT
  echo 																																																																					>> $FOREMAN_REPORT



  echo "## RHSM"																				| tee -a $FOREMAN_REPORT
  echo 																									>> $FOREMAN_REPORT

  echo "// RHSM errors"																	>> $FOREMAN_REPORT
  echo "grep ERROR $base_dir/var/log/rhsm/rhsm.log"			>> $FOREMAN_REPORT
  echo "---"																						>> $FOREMAN_REPORT
  grep ERROR $base_dir/var/log/rhsm/rhsm.log						&>> $FOREMAN_REPORT
  echo "---"																						>> $FOREMAN_REPORT
  echo 																									>> $FOREMAN_REPORT

  echo "// RHSM Warnings"																>> $FOREMAN_REPORT
  echo "grep WARNING $base_dir/var/log/rhsm/rhsm.log"		>> $FOREMAN_REPORT
  echo "---"																						>> $FOREMAN_REPORT
  grep WARNING $base_dir/var/log/rhsm/rhsm.log					&>> $FOREMAN_REPORT
  echo "---"																						>> $FOREMAN_REPORT
  echo 																									>> $FOREMAN_REPORT

  echo "// Sending updated Host-to-guest"																					>> $FOREMAN_REPORT
  echo "grep \"Sending updated Host-to-guest\" $base_dir/var/log/rhsm/rhsm.log"		>> $FOREMAN_REPORT
  echo "---"																																			>> $FOREMAN_REPORT
  grep "Sending updated Host-to-guest" $base_dir/var/log/rhsm/rhsm.log						&>> $FOREMAN_REPORT
  echo "---"																																			>> $FOREMAN_REPORT
  echo 																																						>> $FOREMAN_REPORT




  echo "## Virt-who"														| tee -a $FOREMAN_REPORT
  echo 																					>> $FOREMAN_REPORT

  echo "// virt-who configuration"							>> $FOREMAN_REPORT
  echo "ls -l $base_dir/etc/virt-who.d"					>> $FOREMAN_REPORT
  echo "---"																		>> $FOREMAN_REPORT
  ls -l $base_dir/etc/virt-who.d								&>> $FOREMAN_REPORT
  echo "---"																		>> $FOREMAN_REPORT
  echo 																					>> $FOREMAN_REPORT

  echo "// virt-who configuration content files"																																				>> $FOREMAN_REPORT
  echo "for b in \$(ls -1 \$base_dir/etc/virt-who.d/*); do echo; echo \$b; echo \"===\"; cat \$b; echo \"===\"; done"		>> $FOREMAN_REPORT
  echo "---"																																																						>> $FOREMAN_REPORT
  for b in $(ls -1 $base_dir/etc/virt-who.d/*); do echo; echo $b; echo "==="; cat $b; echo "==="; done									&>> $FOREMAN_REPORT
  echo "---"																																																						>> $FOREMAN_REPORT
  echo 																																																									>> $FOREMAN_REPORT

  echo "// virt-who configuration content files (hidden characters)"																												>> $FOREMAN_REPORT
  echo "for b in \$(ls -1 \$base_dir/etc/virt-who.d/*); do echo; echo \$b; echo \"===\"; cat -vet \$b; echo \"===\"; done"	>> $FOREMAN_REPORT
  echo "---"																																																								>> $FOREMAN_REPORT
  for b in $(ls -1 $base_dir/etc/virt-who.d/*); do echo; echo $b; echo "==="; cat -vet $b; echo "==="; done									&>> $FOREMAN_REPORT
  echo "---"																																																								>> $FOREMAN_REPORT
  echo 																																																											>> $FOREMAN_REPORT


  echo "## Hypervisors tasks"																																														| tee -a $FOREMAN_REPORT
  echo 																																																									>> $FOREMAN_REPORT

  echo "// latest 30 hypervisors tasks"																																									>> $FOREMAN_REPORT
  echo "cat $base_foreman/foreman_tasks_tasks.csv | grep Hypervisors | sed -e 's/,/ /g' | sort -rk4 | head -n 30"				>> $FOREMAN_REPORT
  echo "---"																																																						>> $FOREMAN_REPORT
  cat $base_foreman/foreman_tasks_tasks.csv | grep Hypervisors | sed -e 's/,/ /g' | sort -rk4 | head -n 30							&>> $FOREMAN_REPORT
  echo "---"																																																						>> $FOREMAN_REPORT
  echo 																																																									>> $FOREMAN_REPORT


  echo "## Tomcat"																							| tee -a $FOREMAN_REPORT
  echo 																														>> $FOREMAN_REPORT

  echo "// Memory (Xms and Xmx)"																	>> $FOREMAN_REPORT
  echo "grep tomcat $base_foreman/ps-awfux"												>> $FOREMAN_REPORT
  echo "---"																											>> $FOREMAN_REPORT
  grep tomcat $base_foreman/ps-awfux															&>> $FOREMAN_REPORT
  echo "---"																											>> $FOREMAN_REPORT
  echo 																														>> $FOREMAN_REPORT

  echo "// cpdb"																									>> $FOREMAN_REPORT
  echo "cat $base_foreman/var/log/candlepin/cpdb.log"							>> $FOREMAN_REPORT
  echo "---"																											>> $FOREMAN_REPORT
  cat $base_foreman/var/log/candlepin/cpdb.log										&>> $FOREMAN_REPORT
  echo "---"																											>> $FOREMAN_REPORT
  echo 																														>> $FOREMAN_REPORT


  echo "## Candlepin"																											| tee -a $FOREMAN_REPORT
  echo 																																		>> $FOREMAN_REPORT

  echo "// latest state of candlepin (updating info)"											>> $FOREMAN_REPORT
  echo "grep -B1 Updated $base_foreman/var/log/candlepin/candlepin.log"		>> $FOREMAN_REPORT
  echo "---"																															>> $FOREMAN_REPORT
  grep -B1 Updated $base_foreman/var/log/candlepin/candlepin.log					&>> $FOREMAN_REPORT
  echo "---"																															>> $FOREMAN_REPORT
  echo 																																		>> $FOREMAN_REPORT

  echo "// ERROR on candlepin log - candlepin.log"																								>> $FOREMAN_REPORT
  echo "grep ERROR $base_foreman/var/log/candlepin/candlepin.log | cut -d ' ' -f1,3- | uniq -c"		>> $FOREMAN_REPORT
  echo "---"																																											>> $FOREMAN_REPORT
  grep ERROR $base_foreman/var/log/candlepin/candlepin.log | cut -d ' ' -f1,3- | uniq -c					&>> $FOREMAN_REPORT
  echo "---"																																											>> $FOREMAN_REPORT
  echo 																																														>> $FOREMAN_REPORT

  echo "// ERROR on candlepin log - error.log"																										>> $FOREMAN_REPORT
  echo "grep ERROR $base_foreman/var/log/candlepin/error.log | cut -d ' ' -f1,3- | uniq -c"				>> $FOREMAN_REPORT
  echo "---"																																											>> $FOREMAN_REPORT
  grep ERROR $base_foreman/var/log/candlepin/error.log | cut -d ' ' -f1,3- | uniq -c							&>> $FOREMAN_REPORT
  echo "---"																																											>> $FOREMAN_REPORT
  echo 																																														>> $FOREMAN_REPORT

  echo "// latest entry on error.log"																			>> $FOREMAN_REPORT
  echo "tail -30 $base_foreman/var/log/candlepin/error.log"								>> $FOREMAN_REPORT
  echo "---"																															>> $FOREMAN_REPORT
  tail -30 $base_foreman/var/log/candlepin/error.log											&>> $FOREMAN_REPORT
  echo "---"																															>> $FOREMAN_REPORT
  echo 																																		>> $FOREMAN_REPORT



  echo "## Cron"																						| tee -a $FOREMAN_REPORT
  echo 																											>> $FOREMAN_REPORT

  echo "// cron from the base OS"														>> $FOREMAN_REPORT
  echo "ls -l $base_dir/var/spool/cron/*"										>> $FOREMAN_REPORT
  echo "---"																								>> $FOREMAN_REPORT
  ls -l $base_dir/var/spool/cron/*													&>> $FOREMAN_REPORT
  echo "---"																								>> $FOREMAN_REPORT
  echo 																											>> $FOREMAN_REPORT

  echo "// checking the content of base OS cron"																																				>> $FOREMAN_REPORT
  echo "for b in \$(ls -1 $base_dir/var/spool/cron/*); do echo; echo \$b; echo \"===\"; cat \$b; echo \"===\"; done"		>> $FOREMAN_REPORT
  echo "---"																																																						>> $FOREMAN_REPORT
  for b in $(ls -1 $base_dir/var/spool/cron/*); do echo; echo $b; echo "==="; cat $b; echo "==="; done									&>> $FOREMAN_REPORT
  echo "---"																																																						>> $FOREMAN_REPORT
  echo 																																																									>> $FOREMAN_REPORT


  echo "## Files in etc/cron*"																							| tee -a $FOREMAN_REPORT
  echo 																																			>> $FOREMAN_REPORT

  echo "// all files located on /etc/cron*"																	>> $FOREMAN_REPORT
  echo "find $base_dir/etc/cron* -type f | awk 'FS=\"/etc/\" {print \$2}'"	>> $FOREMAN_REPORT
  echo "---"																																>> $FOREMAN_REPORT
  find $base_dir/etc/cron* -type f | awk 'FS="/etc/" {print $2}'						&>> $FOREMAN_REPORT
  echo "---"																																>> $FOREMAN_REPORT
  echo 																																			>> $FOREMAN_REPORT


#  echo "## Audit"										| tee -a $FOREMAN_REPORT
#  echo 																											>> $FOREMAN_REPORT
#$ cat var/log/audit/audit.log

  echo "## Foreman Settings"																| tee -a $FOREMAN_REPORT
  echo 																											>> $FOREMAN_REPORT

  echo "// foreman settings"																>> $FOREMAN_REPORT
  echo "cat $base_foreman/etc/foreman/settings.yaml"				>> $FOREMAN_REPORT
  echo "---"																								>> $FOREMAN_REPORT
  cat $base_foreman/etc/foreman/settings.yaml								&>> $FOREMAN_REPORT
  echo "---"																								>> $FOREMAN_REPORT
  echo 																											>> $FOREMAN_REPORT

  echo "// custom hiera"																							>> $FOREMAN_REPORT
  echo "cat $base_foreman/etc/foreman-installer/custom-hiera.yaml"		>> $FOREMAN_REPORT
  echo "---"																													>> $FOREMAN_REPORT
  cat $base_foreman/etc/foreman-installer/custom-hiera.yaml						&>> $FOREMAN_REPORT
  echo "---"																													>> $FOREMAN_REPORT
  echo 																																>> $FOREMAN_REPORT


  echo "## PostgreSQL"																															| tee -a $FOREMAN_REPORT
  echo 																																							>> $FOREMAN_REPORT

  echo "// Deadlock count"																													>> $FOREMAN_REPORT
  echo "grep -h -i deadlock $base_foreman/var/lib/pgsql/data/pg_log/*.log | wc -l"	>> $FOREMAN_REPORT
  echo "---"																																				>> $FOREMAN_REPORT
  grep -h -i deadlock $base_foreman/var/lib/pgsql/data/pg_log/*.log | wc -l					&>> $FOREMAN_REPORT
  echo "---"																																				>> $FOREMAN_REPORT
  echo 																																							>> $FOREMAN_REPORT

  echo "// Deadlock"																												>> $FOREMAN_REPORT
  echo "grep -h -i deadlock $base_foreman/var/lib/pgsql/data/pg_log/*.log"	>> $FOREMAN_REPORT
  echo "---"																																>> $FOREMAN_REPORT
  grep -h -i deadlock $base_foreman/var/lib/pgsql/data/pg_log/*.log					&>> $FOREMAN_REPORT
  echo "---"																																>> $FOREMAN_REPORT
  echo 																																			>> $FOREMAN_REPORT

  echo "// ERROR count"																											>> $FOREMAN_REPORT
  echo "grep ERROR $base_foreman/var/lib/pgsql/data/pg_log/*.log | wc -l"		>> $FOREMAN_REPORT
  echo "---"																																>> $FOREMAN_REPORT
  grep ERROR $base_foreman/var/lib/pgsql/data/pg_log/*.log | wc -l					&>> $FOREMAN_REPORT
  echo "---"																																>> $FOREMAN_REPORT
  echo 																																			>> $FOREMAN_REPORT

  echo "// ERROR"																											>> $FOREMAN_REPORT
  echo "grep -h ERROR $base_foreman/var/lib/pgsql/data/pg_log/*.log"	>> $FOREMAN_REPORT
  echo "---"																													>> $FOREMAN_REPORT
  grep -h ERROR $base_foreman/var/lib/pgsql/data/pg_log/*.log					&>> $FOREMAN_REPORT
  echo "---"																													>> $FOREMAN_REPORT
  echo 																																>> $FOREMAN_REPORT




  echo "// Current Configuration"																																												>> $FOREMAN_REPORT
  echo "cat $base_foreman/var/lib/pgsql/data/postgresql.conf | grep -v ^# | grep -v ^$ | grep -v -P ^"\\t\\t".*#"				>> $FOREMAN_REPORT
  echo "---"																																																						>> $FOREMAN_REPORT
  cat $base_foreman/var/lib/pgsql/data/postgresql.conf | grep -v ^# | grep -v ^$ | grep -v -P ^"\t\t".*# 								&>> $FOREMAN_REPORT
  echo "---"																																																						>> $FOREMAN_REPORT
  echo 																																																									>> $FOREMAN_REPORT




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
