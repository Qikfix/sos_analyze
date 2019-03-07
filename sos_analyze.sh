#!/bin/bash

FOREMAN_REPORT="/tmp/$$.log"

main()
{
  > $FOREMAN_REPORT

  sos_path=$1
  base_dir=$sos_path
  final_name=$(echo $base_dir | grep -E -o sosreport.*)

  echo "The sosreport is: $base_dir"												| tee -a $FOREMAN_REPORT

  report $base_dir $sub_dir
}

report()
{

  base_dir=$1
  sub_dir=$2

  base_foreman="$1/sos_commands/foreman/foreman-debug/var/log/"

  echo "### Welcome to Report ###"													| tee -a $FOREMAN_REPORT
  echo "### CEE/SysMGMT ###"																| tee -a $FOREMAN_REPORT
  echo 																											>> $FOREMAN_REPORT
  echo 																											>> $FOREMAN_REPORT

  echo "## naming resolution"																| tee -a $FOREMAN_REPORT
  echo 																											>> $FOREMAN_REPORT

  echo "// hosts entries"																		>> $FOREMAN_REPORT
  echo "cat $base_dir/etc/hosts"														>> $FOREMAN_REPORT
  echo "---"																								>> $FOREMAN_REPORT
  cat $base_dir/etc/hosts																		&>> $FOREMAN_REPORT
  echo "---"																								>> $FOREMAN_REPORT
  echo 																											>> $FOREMAN_REPORT

  echo "// resolv.conf"																			>> $FOREMAN_REPORT
  echo "cat $base_dir/etc/resolv.conf"											>> $FOREMAN_REPORT
  echo "---"																								>> $FOREMAN_REPORT
  cat $base_dir/etc/resolv.conf															&>> $FOREMAN_REPORT
  echo "---"																								>> $FOREMAN_REPORT
  echo 																											>> $FOREMAN_REPORT


  echo "## network information"															| tee -a $FOREMAN_REPORT
  echo 																											>> $FOREMAN_REPORT

  echo "// ip address"																			>> $FOREMAN_REPORT
  echo "cat $base_dir/ip_addr"															>> $FOREMAN_REPORT
  echo "---"																								>> $FOREMAN_REPORT
  cat $base_dir/ip_addr																			&>> $FOREMAN_REPORT
  echo "---"																								>> $FOREMAN_REPORT
  echo 																											>> $FOREMAN_REPORT

  echo "// current route"																		>> $FOREMAN_REPORT
  echo "cat $base_dir/route"																>> $FOREMAN_REPORT
  echo "---"																								>> $FOREMAN_REPORT
  cat $base_dir/route																				&>> $FOREMAN_REPORT
  echo "---"																								>> $FOREMAN_REPORT
  echo 																											>> $FOREMAN_REPORT




  echo "## installed packages (satellite)"									| tee -a $FOREMAN_REPORT
  echo 																											>> $FOREMAN_REPORT

  echo "// all installed packages which contain satellite"	>> $FOREMAN_REPORT
  echo "grep satellite $base_dir/installed-rpms"						>> $FOREMAN_REPORT
  echo "---"																								>> $FOREMAN_REPORT
  grep satellite $base_dir/installed-rpms 									&>> $FOREMAN_REPORT
  echo "---"																								>> $FOREMAN_REPORT
  echo 																											>> $FOREMAN_REPORT

  echo "// packags provided by 3rd party vendors"																				>> $FOREMAN_REPORT
  echo "cat $base_dir/sos_commands/rpm/package-data | cut -f1,4 | grep -v \"Red Hat\""	>> $FOREMAN_REPORT
  echo "---"																																						>> $FOREMAN_REPORT
  cat $base_dir/sos_commands/rpm/package-data | cut -f1,4 | grep -v "Red Hat"						&>> $FOREMAN_REPORT
  echo "---"																																						>> $FOREMAN_REPORT
  echo 																																									>> $FOREMAN_REPORT


  echo "## Subscriptions"																																| tee -a $FOREMAN_REPORT
  echo 																																									>> $FOREMAN_REPORT

  echo "// subsman identity"																														>> $FOREMAN_REPORT
  echo "cat $base_dir/sos_commands/subscription_manager/subscription-manager_identity"	>> $FOREMAN_REPORT
  echo "---"																																						>> $FOREMAN_REPORT
  cat $base_dir/sos_commands/subscription_manager/subscription-manager_identity					&>> $FOREMAN_REPORT
  echo "---"																																						>> $FOREMAN_REPORT
  echo 																																									>> $FOREMAN_REPORT

  echo "// subsman list installed"																															>> $FOREMAN_REPORT
  echo "cat $base_dir/sos_commands/subscription_manager/subscription-manager_list_--installed"	>> $FOREMAN_REPORT
  echo "---"																																										>> $FOREMAN_REPORT
  cat $base_dir/sos_commands/subscription_manager/subscription-manager_list_--installed					&>> $FOREMAN_REPORT
  echo "---"																																										>> $FOREMAN_REPORT
  echo 																																													>> $FOREMAN_REPORT

  echo "// subsman list consumed"																																>> $FOREMAN_REPORT
  echo "cat $base_dir/sos_commands/subscription_manager/subscription-manager_list_--consumed"		>> $FOREMAN_REPORT
  echo "---"																																										>> $FOREMAN_REPORT
  cat $base_dir/sos_commands/subscription_manager/subscription-manager_list_--consumed					&>> $FOREMAN_REPORT
  echo "---"																																										>> $FOREMAN_REPORT
  echo 																																													>> $FOREMAN_REPORT



#  echo "cat $base_dir/"	| tee -a $FOREMAN_REPORT
#  echo "---"											| tee -a $FOREMAN_REPORT
#  cat $base_dir/		| tee -a $FOREMAN_REPORT
#  echo "---"											| tee -a $FOREMAN_REPORT

  echo "## REPOS"																											| tee -a $FOREMAN_REPORT
  echo 																																>> $FOREMAN_REPORT


  echo "// enabled repos"																							>> $FOREMAN_REPORT
  echo "cat $base_dir/sos_commands/yum/yum_-C_repolist"								>> $FOREMAN_REPORT
  echo "---"																													>> $FOREMAN_REPORT
  cat $base_dir/sos_commands/yum/yum_-C_repolist											&>> $FOREMAN_REPORT
  echo "---"																													>> $FOREMAN_REPORT
  echo 																																>> $FOREMAN_REPORT

#$ cat sos_commands/yum/yum_list_installed
#  echo "cat $base_dir/sos_commands/yum/yum_list_installed"	| tee -a $FOREMAN_REPORT
#  echo "---"											| tee -a $FOREMAN_REPORT
#  cat $base_dir/sos_commands/yum/yum_list_installed		| tee -a $FOREMAN_REPORT
#  echo "---"											| tee -a $FOREMAN_REPORT

  echo "// yum history"																							>> $FOREMAN_REPORT
  echo "cat $base_dir/sos_commands/yum/yum_history"									>> $FOREMAN_REPORT
  echo "---"																												>> $FOREMAN_REPORT
  cat $base_dir/sos_commands/yum/yum_history												&>> $FOREMAN_REPORT
  echo "---"																												>> $FOREMAN_REPORT
  echo 																															>> $FOREMAN_REPORT

  echo "// yum.log info"																						>> $FOREMAN_REPORT
  echo "cat $base_dir/var/log/yum.log"															>> $FOREMAN_REPORT
  echo "---"																												>> $FOREMAN_REPORT
  cat $base_dir/var/log/yum.log																			&>> $FOREMAN_REPORT
  echo "---"																												>> $FOREMAN_REPORT
  echo 																															>> $FOREMAN_REPORT


  echo "## Upgrade"																									| tee -a $FOREMAN_REPORT
  echo 																															>> $FOREMAN_REPORT


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


  echo "## CPU"																																| tee -a $FOREMAN_REPORT
  echo 																																				>> $FOREMAN_REPORT

  echo "// cpu's number"																											>> $FOREMAN_REPORT
  echo "cat $base_dir/proc/cpuinfo | grep processor | wc -l"									>> $FOREMAN_REPORT
  echo "---"																																	>> $FOREMAN_REPORT
  cat $base_dir/proc/cpuinfo | grep processor | wc -l													&>> $FOREMAN_REPORT
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


  echo "## MongoDB"																																				| tee -a $FOREMAN_REPORT
  echo 																																										>> $FOREMAN_REPORT

  echo "// mongodb storage consumption"																										>> $FOREMAN_REPORT
  echo "cat $base_dir/sos_commands/foreman/foreman-debug/mongodb_disk_space"							>> $FOREMAN_REPORT
  echo "---"																																							>> $FOREMAN_REPORT
  cat $base_dir/sos_commands/foreman/foreman-debug/mongodb_disk_space											&>> $FOREMAN_REPORT
  echo "---"																																							>> $FOREMAN_REPORT
  echo 																																										>> $FOREMAN_REPORT


  echo "## PostgreSQL"																																		| tee -a $FOREMAN_REPORT
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


  echo "## QPIDD"																																																	| tee -a $FOREMAN_REPORT
  echo 																																																						>> $FOREMAN_REPORT

  echo "// total number of pulp agents"																																						>> $FOREMAN_REPORT
  echo "cat $base_dir/sos_commands/foreman/foreman-debug/qpid-stat-q | grep pulp.agent | wc -l"										>> $FOREMAN_REPORT
  echo "---"																																																			>> $FOREMAN_REPORT
  cat $base_dir/sos_commands/foreman/foreman-debug/qpid-stat-q | grep pulp.agent | wc -l													&>> $FOREMAN_REPORT
  echo "---"																																																			>> $FOREMAN_REPORT
  echo 																																																						>> $FOREMAN_REPORT

  echo "// total number of (active) pulp agents"																																	>> $FOREMAN_REPORT
  echo "cat $base_dir/sos_commands/foreman/foreman-debug/qpid-stat-q | grep pulp.agent | grep "1     1$" | wc -l"	>> $FOREMAN_REPORT
  echo "---"																																																			>> $FOREMAN_REPORT
  cat $base_dir/sos_commands/foreman/foreman-debug/qpid-stat-q | grep pulp.agent | grep "1     1$" | wc -l				&>> $FOREMAN_REPORT
  echo "---"																																																			>> $FOREMAN_REPORT
  echo 																																																						>> $FOREMAN_REPORT


  echo "## Foreman logs (error)"																		| tee -a $FOREMAN_REPORT
  echo 																															>> $FOREMAN_REPORT

  echo "// total number of errors found on production.log"					>> $FOREMAN_REPORT
  echo "grep "\[E" $base_foreman/foreman/production.log | wc -l"		>> $FOREMAN_REPORT
  echo "---"																												>> $FOREMAN_REPORT
  grep "\[E" $base_foreman/foreman/production.log | wc -l						&>> $FOREMAN_REPORT
  echo "---"																												>> $FOREMAN_REPORT
  echo 																															>> $FOREMAN_REPORT




  echo "// errors from production.log (combined)"																																	>> $FOREMAN_REPORT
  echo "grep "\[E" $base_foreman/foreman/production.log | awk '{print $3, $4, $5}' | sort | uniq -c | sort -nr"		>> $FOREMAN_REPORT
  echo "---"																																																			>> $FOREMAN_REPORT
  grep "\[E" $base_foreman/foreman/production.log | awk '{print $3, $4, $5}' | sort | uniq -c | sort -nr					&>> $FOREMAN_REPORT
  echo "---"																																																			>> $FOREMAN_REPORT
  echo 																																																						>> $FOREMAN_REPORT



  echo "## Foreman cron"																		| tee -a $FOREMAN_REPORT
  echo 																											>> $FOREMAN_REPORT

  echo "// last 20 entries from foreman/cron.log"						>> $FOREMAN_REPORT
  echo "tail -20 $base_foreman/foreman/cron.log"						>> $FOREMAN_REPORT
  echo "---"																								>> $FOREMAN_REPORT
  tail -20 $base_foreman/foreman/cron.log										&>> $FOREMAN_REPORT
  echo "---"																								>> $FOREMAN_REPORT
  echo 																											>> $FOREMAN_REPORT


  echo "## HTTPD"																																										| tee -a $FOREMAN_REPORT
  echo 																																															>> $FOREMAN_REPORT

  echo "// queues on error_log means the # of requests crossed the border. Satellite inaccessible"	>> $FOREMAN_REPORT
  echo "grep queue $base_foreman/httpd/error_log | wc -l"																						>> $FOREMAN_REPORT
  echo "---"																																												>> $FOREMAN_REPORT
  grep queue $base_foreman/httpd/error_log | wc -l																									&>> $FOREMAN_REPORT
  echo "---"																																												>> $FOREMAN_REPORT
  echo 																																															>> $FOREMAN_REPORT

  echo "// when finding something on last step, we will here per date"															>> $FOREMAN_REPORT
  echo "grep queue $base_foreman/httpd/error_log  | awk '{print $2, $3}' | cut -d: -f1,2 | uniq -c"	>> $FOREMAN_REPORT
  echo "---"																																												>> $FOREMAN_REPORT
  grep queue $base_foreman/httpd/error_log  | awk '{print $2, $3}' | cut -d: -f1,2 | uniq -c				&>> $FOREMAN_REPORT
  echo "---"																																												>> $FOREMAN_REPORT
  echo 																																															>> $FOREMAN_REPORT

  echo "// TOP 20 of ip address requesting the satellite via https"																											>> $FOREMAN_REPORT
  echo "cat $base_foreman/httpd/foreman-ssl_access_ssl.log | awk '{print \$1}' | sort | uniq -c | sort -nr | head -n20"	>> $FOREMAN_REPORT
  echo "---"																																																						>> $FOREMAN_REPORT
  cat $base_foreman/httpd/foreman-ssl_access_ssl.log | awk '{print $1}' | sort | uniq -c | sort -nr | head -n20					&>> $FOREMAN_REPORT
  echo "---"																																																						>> $FOREMAN_REPORT
  echo 																																																									>> $FOREMAN_REPORT

  echo "// TOP 20 of ip address requesting the satellite via https (detailed)"																													>> $FOREMAN_REPORT
  echo "cat $base_foreman/httpd/foreman-ssl_access_ssl.log | awk '{print \$1,\$4}' | cut -d: -f1,2,3 | uniq -c | sort -nr | head -n20"	>> $FOREMAN_REPORT
  echo "---"																																																														>> $FOREMAN_REPORT
  cat $base_foreman/httpd/foreman-ssl_access_ssl.log | awk '{print $1,$4}' | cut -d: -f1,2,3 | uniq -c | sort -nr | head -n20						&>> $FOREMAN_REPORT
  echo "---"																																																														>> $FOREMAN_REPORT
  echo 																																																																	>> $FOREMAN_REPORT


#  echo "## RHSM"										| tee -a $FOREMAN_REPORT
  echo 																											>> $FOREMAN_REPORT
#$ cat rhsm/rhsm.log  | grep "\"name\"" | sort | uniq -c | sort -nr | wc -l
#  echo "cat $base_dir/"	| tee -a $FOREMAN_REPORT
#  echo "---"											| tee -a $FOREMAN_REPORT
#  cat $base_dir/		| tee -a $FOREMAN_REPORT
#  echo "---"											| tee -a $FOREMAN_REPORT
#  echo 															>> $FOREMAN_REPORT



#  echo "## virt-who"										| tee -a $FOREMAN_REPORT
#$ ll ../../../../../etc/virt-who.d/
#total 12
#-rwxrwx---+ 1 yank yank 1254 Sep 12 18:04 template.conf
#-rwxrwx---+ 1 yank yank  386 Feb  6 06:35 virt-who-config-3.conf
#-rwxrwx---+ 1 yank yank  388 Feb  6 08:25 virt-who-config-4.conf


#$ cat ../../../../../etc/virt-who.d/*.conf


  echo "## Hypervisors tasks"																																														| tee -a $FOREMAN_REPORT
  echo 																																																									>> $FOREMAN_REPORT

  echo "// latest 30 hypervisors tasks"																																									>> $FOREMAN_REPORT
  echo "cat $base_foreman/../../foreman_tasks_tasks.csv | grep Hypervisors | sed -e 's/,/ /g' | sort -rk4 | head -n 30"	>> $FOREMAN_REPORT
  echo "---"																																																						>> $FOREMAN_REPORT
  cat $base_foreman/../../foreman_tasks_tasks.csv | grep Hypervisors | sed -e 's/,/ /g' | sort -rk4 | head -n 30				&>> $FOREMAN_REPORT
  echo "---"																																																						>> $FOREMAN_REPORT
  echo 																																																									>> $FOREMAN_REPORT


#  echo "## Tomcat"										| tee -a $FOREMAN_REPORT
  echo 																											>> $FOREMAN_REPORT
#$ ls -ltr tomcat/
#  echo "cat $base_dir/"	| tee -a $FOREMAN_REPORT
#  echo "---"											| tee -a $FOREMAN_REPORT
#  cat $base_dir/		| tee -a $FOREMAN_REPORT
#  echo "---"											| tee -a $FOREMAN_REPORT
#  echo 															>> $FOREMAN_REPORT


  echo "## Candlepin"																							| tee -a $FOREMAN_REPORT
  echo 																														>> $FOREMAN_REPORT

  echo "// latest state of candlepin (updating info)"							>> $FOREMAN_REPORT
  echo "grep -B1 Updated $base_foreman/candlepin/candlepin.log"		>> $FOREMAN_REPORT
  echo "---"																											>> $FOREMAN_REPORT
  grep -B1 Updated $base_foreman/candlepin/candlepin.log					&>> $FOREMAN_REPORT
  echo "---"																											>> $FOREMAN_REPORT
  echo 																														>> $FOREMAN_REPORT



  echo "## CRON"																						| tee -a $FOREMAN_REPORT
  echo 																											>> $FOREMAN_REPORT

  echo "// cron from the base OS"														>> $FOREMAN_REPORT
  echo "ls -l $base_dir/var/spool/cron/*"										>> $FOREMAN_REPORT
  echo "---"																								>> $FOREMAN_REPORT
  ls -l $base_dir/var/spool/cron/*													&>> $FOREMAN_REPORT
  echo "---"																								>> $FOREMAN_REPORT
  echo 																											>> $FOREMAN_REPORT

  echo "// checking the content of base OS cron"						>> $FOREMAN_REPORT
  echo "cat $base_dir/var/spool/cron/*"											>> $FOREMAN_REPORT
  echo "---"																								>> $FOREMAN_REPORT
  cat $base_dir/var/spool/cron/*														&>> $FOREMAN_REPORT
  echo "---"																								>> $FOREMAN_REPORT
  echo 																											>> $FOREMAN_REPORT


  echo "## etc/cron*"																				| tee -a $FOREMAN_REPORT
  echo 																											>> $FOREMAN_REPORT

  echo "// all files located on /etc/cron*"									>> $FOREMAN_REPORT
  echo "find $base_dir/etc/cron*"														>> $FOREMAN_REPORT
  echo "---"																								>> $FOREMAN_REPORT
  find $base_dir/etc/cron*																	&>> $FOREMAN_REPORT
  echo "---"																								>> $FOREMAN_REPORT
  echo 																											>> $FOREMAN_REPORT


#  echo "## Audit"										| tee -a $FOREMAN_REPORT
  echo 																											>> $FOREMAN_REPORT
#$ cat var/log/audit/audit.log

  echo "## Foreman Settings"																| tee -a $FOREMAN_REPORT
  echo 																											>> $FOREMAN_REPORT

  echo "// foreman settings"																>> $FOREMAN_REPORT
  echo "cat $base_foreman/../../etc/foreman/settings.yaml"	>> $FOREMAN_REPORT
  echo "---"																								>> $FOREMAN_REPORT
  cat $base_foreman/../../etc/foreman/settings.yaml					&>> $FOREMAN_REPORT
  echo "---"																								>> $FOREMAN_REPORT
  echo 																											>> $FOREMAN_REPORT




  mv $FOREMAN_REPORT /tmp/report-$final_name.log
  echo 
  echo
  echo "## Please check out the file /tmp/report-$final_name.log"
}





# Main

if [ "$1" == "" ]; then
  echo "Please inform the path to the sosrepor dir that you would like to analyze."
  echo "$0 01234567/sosreport_do_wall"
  exit 1
fi

main $1
