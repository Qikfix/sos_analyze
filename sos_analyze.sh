#!/bin/bash

#
# Created ....: 03/04/2019
# Developer ..: Waldirio M Pinheiro <waldirio@gmail.com / waldirio@redhat.com>
# Purpose ....: Analyze sosreport and summarize the information (focus on Satellite info)
#

FOREMAN_REPORT="/tmp/$$.log"


# the following while block captures three flags from the command line
# -c copies the output file from the /tmp directory to the current directory
# -l opens the output file from the current directory
# -t opens the output file from the /tmp directory

while getopts "clt" opt "${NULL[@]}"; do
 case $opt in
    c )
    COPY_TO_CURRENT_DIR=true
    ;;
   l )   # open copy from local directory.  Requires option 'c' above.
   OPEN_IN_VIM_RO_LOCAL_DIR=true
#   echo "This is l"
   ;;
   t )   # open copy from /tmp/directory
   OPEN_IN_EDITOR_TMP_DIR=true
#   echo "This is t"
   ;;
    \? )
    ;;
 esac
done
shift "$(($OPTIND -1))"

MYPWD=`pwd`


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

  if [ -d $base_dir/sos_commands/foreman/foreman-debug ]; then
    base_foreman="/sos_commands/foreman/foreman-debug/"
    sos_version="old"
  else
    sos_version="new"
    base_foreman="/"
  fi

  if which rg &>/dev/null; then
    # ripgrep is installed.
    RGOPTS=" -N "
    GREP="$(which rg) $RGOPTS"
    EGREP="$GREP"
  else
    # ripgrep is not installed; use good old GNU grep instead.
    GREP="$(which grep)"
    EGREP="$(which egrep || echo 'grep -E')"
  fi

  echo "The sosreport is: $base_dir"												| tee -a $FOREMAN_REPORT

  #report $base_dir $sub_dir $base_foreman $sos_version
  report $base_dir $base_foreman $sos_version
}

log_tee()
{
  echo $1 | tee -a $FOREMAN_REPORT
}

log()
{
  echo "$1" >> $FOREMAN_REPORT
}

log_cmd()
{
  echo "$@" | bash &>> $FOREMAN_REPORT
}

# ref: https://unix.stackexchange.com/questions/44040/a-standard-tool-to-convert-a-byte-count-into-human-kib-mib-etc-like-du-ls1
# Converts bytes value to human-readable string [$1: bytes value]
bytesToHumanReadable() {
    local i=${1:-0} d="" s=0 S=("Bytes" "KiB" "MiB" "GiB" "TiB" "PiB" "EiB" "YiB" "ZiB")
    while ((i > 1024 && s < ${#S[@]}-1)); do
        printf -v d ".%02d" $((i % 1024 * 100 / 1024))
        i=$((i / 1024))
        s=$((s + 1))
    done
    echo "$i$d ${S[$s]}"
}

report()
{

  base_dir=$1
  # sub_dir=$2
  # base_foreman=$base_dir/$3
  # sos_version=$4
  base_foreman=$base_dir/$2
  sos_version=$3

  #base_foreman="$1/sos_commands/foreman/foreman-debug/"

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
  
  log "// hostname"
  log "cat $base_dir/etc/hostname"
  log "---"
  log_cmd "cat $base_dir/etc/hostname"
  log "---"
  log

  log_tee "## Hardware"
  log

  log "// baremetal or vm?"
  log "cat $base_dir/dmidecode | $EGREP '(Vendor|Manufacture)' | head -n3"
  log "---"
  log_cmd "cat $base_dir/dmidecode | $EGREP '(Vendor|Manufacture)' | head -n3"
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

  log "// setroubleshoot package"
  log "$GREP setroubleshoot $base_dir/installed-rpms"
  log "---"
  log_cmd "$GREP setroubleshoot $base_dir/installed-rpms"
  log "---"
  log

  log "// sealert information"
  log "$GREP -o sealert.* $base_dir/var/log/messages | sort -u"
  log "---"
  log_cmd "$GREP -o sealert.* $base_dir/var/log/messages | sort -u"
  log "---"
  log




  log_tee "## Installed Packages (satellite)"
  log

  log "// all installed packages which contain satellite"
  log "$GREP satellite $base_dir/installed-rpms"
  log "---"
  log_cmd "$GREP satellite $base_dir/installed-rpms"
  log "---"
  log

  log "// packages provided by 3rd party vendors"
  log "cat $base_dir/sos_commands/rpm/package-data | cut -f1,4 | $GREP -v -e \"Red Hat\" -e katello-ca-consumer- | sort -k2"
  log "---"
  log_cmd "cat $base_dir/sos_commands/rpm/package-data | cut -f1,4 | $GREP -v -e \"Red Hat\" -e katello-ca-consumer- | sort -k2"
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

  log "// installed katello-agent and/or gofer"
  log "$EGREP '(^katello-agent|^gofer)' $base_dir/installed-rpms"
  log "---"
  log_cmd "$EGREP '(^katello-agent|^gofer)' $base_dir/installed-rpms"
  log "---"
  log

  log "// goferd service"
  log "$EGREP '(^katello-agent|^gofer)' $base_dir/installed-rpms"
  log "cat $base_dir/sos_commands/systemd/systemctl_list-units | $GREP goferd"
  log "---"
  log_cmd "cat $base_dir/sos_commands/systemd/systemctl_list-units | $GREP goferd"
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


# grep "Running installer with args" /var/log/foreman-installer/satellite.log
  log "// Last flag used with satellite-installer"

  if [ "$sos_version" == "old" ];then
    cmd="$EGREP \"(Running installer with args|signal was)\" $base_dir/sos_commands/foreman/foreman-debug/var/log/foreman-installer/satellite.log"
  else
    cmd="$EGREP \"(Running installer with args|signal was)\" $base_dir/var/log/foreman-installer/satellite.log"
  fi

  log "$cmd"
  log "---"
  log_cmd "$cmd"
  log "---"
  log


  log "// All the flags used with satellite-installer"

  if [ "$sos_version" == "old" ];then
    cmd="$GREP \"Running installer with args\" $base_dir/sos_commands/foreman/foreman-debug/var/log/foreman-installer/satellite.* | sort -rk3 | cut -d: -f2-"
  else
    cmd="$GREP \"Running installer with args\" $base_dir/var/log/foreman-installer/satellite.* | sort -rk3 | cut -d: -f2-"
  fi

  log "$cmd"
  log "---"
  log_cmd "$cmd"
  log "---"
  log




  log "// # of error on the upgrade file"

  if [ "$sos_version" == "old" ];then
    cmd="$GREP '^\[ERROR' $base_dir/sos_commands/foreman/foreman-debug/var/log/foreman-installer/satellite.log -c"
  else
    cmd="$GREP '^\[ERROR' $base_dir/var/log/foreman-installer/satellite.log -c"
  fi

  log "$cmd"
  log "---"
  log_cmd "$cmd"
  log "---"
  log


  log "// Error on the upgrade file (full info)"

  if [ "$sos_version" == "old" ];then
    cmd="$GREP '^\[ERROR' $base_dir/sos_commands/foreman/foreman-debug/var/log/foreman-installer/satellite.log"
  else
    cmd="$GREP '^\[ERROR' $base_dir/var/log/foreman-installer/satellite.log"
  fi

  log "$cmd"
  log "---"
  log_cmd "$cmd"
  log "---"
  log

  log "// Upgrade Completed? (6.4 or greater)"

  if [ "$sos_version" == "old" ];then
   #cmd="grep \"Upgrade completed\" $base_dir/sos_commands/foreman/foreman-debug/var/log/foreman-installer/satellite.log | wc -l"
    cmd="$GREP \"Upgrade completed\" $base_dir/sos_commands/foreman/foreman-debug/var/log/foreman-installer/satellite.log -c"
  else
   #cmd="grep \"Upgrade completed\" $base_dir/var/log/foreman-installer/satellite.log | wc -l"
    cmd="$GREP \"Upgrade completed\" $base_dir/var/log/foreman-installer/satellite.log -c"
  fi

  log "$cmd"
  log "---"
  log_cmd "$cmd"
  log "---"
  log


  log "// last 20 lines from upgrade log"

  if [ "$sos_version" == "old" ];then
    cmd="tail -20 $base_dir/sos_commands/foreman/foreman-debug/var/log/foreman-installer/satellite.log"
  else
    cmd="tail -20 $base_dir/var/log/foreman-installer/satellite.log"
  fi

  log "$cmd"
  log "---"
  log_cmd "$cmd"
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

#  log "// disk space output"
#  log "cat $base_dir/sos_commands/foreman/foreman-debug/disk_space_output"
#  log "---"
#  log_cmd "cat $base_dir/sos_commands/foreman/foreman-debug/disk_space_output"
#  log "---"
#  log

  log "// no space left on device"
  log "$GREP \"No space left on device\" $base_dir/* 2>/dev/null"
  log "---"
  log_cmd "$GREP \"No space left on device\" $base_dir/* 2>/dev/null"
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
  log "cat $base_dir/ps | sort -nr | awk '{print \$1, \$6}' | $GREP -v ^USER | $GREP -v ^COMMAND | $GREP -v \"^ $\" | awk  '{a[\$1] += \$2} END{for (i in a) print i, a[i]}' | sort -nrk2"
  log "and"
  log "memory_usage=\$(cat $base_dir/ps | sort -nr | awk '{print \$6}' | $GREP -v ^RSS | $GREP -v ^$ | paste -s -d+ | bc)"
  log "and"
  log "memory_usage_gb=\$(echo \"scale=2;$memory_usage/1024/1024\" | bc)"
  log "---"
  log_cmd "cat $base_dir/ps | sort -nr | awk '{print \$1, \$6}' | $GREP -v ^USER | $GREP -v ^COMMAND | $GREP -v \"^ $\" | awk  '{a[\$1] += \$2} END{for (i in a) print i, a[i]}' | sort -nrk2"
  log
  memory_usage=$(cat $base_dir/ps | sort -nr | awk '{print $6}' | $GREP -v ^RSS | $GREP -v ^$ | paste -s -d+ | bc)
  memory_usage_gb=$(echo "scale=2;$memory_usage/1024/1024" | bc)
  log "Total Memory Consumed in KiB: $memory_usage"
  log "Total Memory Consumed in GiB: $memory_usage_gb"
  log "---"
  log

  log "// Postgres idle process (candlepin)"
  log "cat $base_dir/ps | $GREP ^postgres | $GREP idle$ | $GREP \"candlepin candlepin\" | wc -l"
  log "---"
  log_cmd "cat $base_dir/ps | $GREP ^postgres | $GREP idle$ | $GREP \"candlepin candlepin\" | wc -l"
  log "---"
  log

  log "// Postgres idle process (foreman)"
  log "cat $base_dir/ps | $GREP ^postgres | $GREP idle$ | $GREP \"foreman foreman\" | wc -l"
  log "---"
  log_cmd "cat $base_dir/ps | $GREP ^postgres | $GREP idle$ | $GREP \"foreman foreman\" | wc -l"
  log "---"
  log

  log "// Postgres idle process (everything)"
  log "cat $base_dir/ps | $GREP ^postgres | $GREP idle$ | wc -l"
  log "---"
  log_cmd "cat $base_dir/ps | $GREP ^postgres | $GREP idle$ | wc -l"
  log "---"
  log

  log "// Processes running for a while (TOP 5 per time)"
  log "cat $base_dir/ps | sort -nr -k10 | head -n5"
  log "---"
  log_cmd "cat $base_dir/ps | sort -nr -k10 | head -n5"
  log "---"
  log



  log_tee "## CPU"
  log

  log "// cpu's number"
  log "cat $base_dir/proc/cpuinfo | $GREP processor | wc -l"
  log "---"
  log_cmd "cat $base_dir/proc/cpuinfo | $GREP processor | wc -l"
  log "---"
  log


  log_tee "## Messages"
  log

  log "// error on message file"
  log "$GREP ERROR $base_dir/var/log/messages"
  log "---"
  log_cmd "$GREP ERROR $base_dir/var/log/messages"
  log "---"
  log


  log_tee "## Out of Memory"
  log

  log "// out of memory"
  log "$GREP \"Out of memory\" $base_dir/var/log/messages"
  log "---"
  log_cmd "$GREP \"Out of memory\" $base_dir/var/log/messages"
  log "---"
  log

  log "Pavel Moravec Script to check the memory usage during the oom killer"
  log " - https://gitlab.cee.redhat.com/mna-emea/oom-process-stats"
  log ""
  log "// Memory Consumption"
  log "/usr/bin/python3 /tmp/script/oom-process-stats.py $base_dir/var/log/messages"
  log "---"
  log_cmd "/usr/bin/python3 /tmp/script/oom-process-stats.py $base_dir/var/log/messages"
  log "---"
  log



  log_tee "## Foreman Tasks"
  log

  
  if [ "$sos_version" == "old" ];then
    cmd="cat $base_dir/sos_commands/foreman/foreman-debug/foreman_tasks_tasks.csv | wc -l"
  else
    cmd="cat $base_dir/sos_commands/foreman/foreman_tasks_tasks | wc -l"
  fi

  log "// total # of foreman tasks"
  log "$cmd"
  log "---"
  log_cmd "$cmd"
  log "---"
  log


  if [ "$sos_version" == "old" ];then
    cmd="cat $base_dir/sos_commands/foreman/foreman-debug/foreman_tasks_tasks.csv | cut -d, -f3 | $GREP Actions | sort | uniq -c | sort -nr"
  else
    cmd="cat $base_dir/sos_commands/foreman/foreman_tasks_tasks | sed '1,3d' | cut -d\| -f3 | $GREP Actions | sort | uniq -c | sort -nr"
  fi


  log "// Tasks TOP"
  log "$cmd"
  log "---"
  log_cmd "$cmd"
  log "---"
  log


  if [ "$sos_version" == "old" ];then
    cmd="cat $base_dir/etc/cron.d/foreman-tasks"
  else
    cmd="cat $base_dir/etc/cron.d/foreman-tasks"
  fi

  log "// foreman tasks cleanup script"
  log "$cmd"
  log "---"
  log_cmd "$cmd"
  log "---"
  log



  log "// paused foreman tasks"
  log "$GREP '(^                  id|paused)' $base_dir/sos_commands/foreman/foreman_tasks_tasks | sed 's/  //g' | sed -e 's/ |/|/g' | sed -e 's/| /|/g' | sed -e 's/^ //g' | sed -e 's/|/,/g'"
  log "---"
  log_cmd "$GREP '(^                  id|paused)' $base_dir/sos_commands/foreman/foreman_tasks_tasks | sed 's/  //g' | sed -e 's/ |/|/g' | sed -e 's/| /|/g' | sed -e 's/^ //g' | sed -e 's/|/,/g'"
  log "---"
  log



  log_tee "## Pulp"
  log

  log "// number of tasks not finished"
  log "$GREP '\"task_id\"' $base_dir/sos_commands/pulp/pulp-running_tasks -c"
  log "---"
  log_cmd "$GREP '\"task_id\"' $base_dir/sos_commands/pulp/pulp-running_tasks -c"
  log "---"
  log


#grep "\"task_id\"" 02681559/0050-sosreport-pc1ustsxrhs06-2020-06-26-kfmgbpf.tar.xz/sosreport-pc1ustsxrhs06-2020-06-26-kfmgbpf/sos_commands/pulp/pulp-running_tasks | wc -l

  log "// pulp task not finished"
  log "$EGREP '(\"finish_time\" : null|\"start_time\"|\"state\"|\"pulp:|^})' $base_dir/sos_commands/pulp/pulp-running_tasks"
  log "---"
  log_cmd "$EGREP '(\"finish_time\" : null|\"start_time\"|\"state\"|\"pulp:|^})' $base_dir/sos_commands/pulp/pulp-running_tasks"
  log "---"
  log




  log_tee "## Hammer Ping"
  log

  log "// hammer ping output"

  if [ "$sos_version" == "old" ];then
    cmd="cat $base_dir/sos_commands/foreman/foreman-debug/hammer-ping"
  else
    cmd="cat $base_dir/sos_commands/foreman/hammer_ping"
  fi

  log "$cmd"
  log "---"
  log_cmd "$cmd"
  log "---"
  log


  log "## Katello service status"
  log

  log "// katello-service status output"

  if [ "$sos_version" == "old" ];then
    cmd="cat $base_dir/sos_commands/foreman/foreman-debug/katello_service_status"
  else
    cmd="cat $base_dir/sos_commands/foreman/foreman-maintain_service_status"
  fi

  log "$cmd"
  log "---"
  log_cmd "$cmd"
  log "---"
  log


  log "// katello-service status output - condensed"

  if [ "$sos_version" == "old" ];then
    cmd="$EGREP '(^\*|Active)' $base_dir/sos_commands/foreman/foreman-debug/katello_service_status | tr '^\*' '\n'"
  else
    cmd="$EGREP '(^\*|Active)' $base_dir/sos_commands/foreman/foreman-maintain_service_status | tr '^\*' '\n'"
  fi

  log "$cmd"
  log "---"
  log_cmd "$cmd"
  log "---"
  log


  log_tee "## Puppet Server"
  log

  log "// Puppet Server Error"
  log "$GREP ERROR $base_dir/var/log/puppetlabs/puppetserver/puppetserver.log"
  log "---"
  log_cmd "$GREP ERROR $base_dir/var/log/puppetlabs/puppetserver/puppetserver.log"
  log "---"
  log


  log_tee "## Audit"
  log

  log "// denied in audit.log"
  log "$GREP -o denied.* $base_dir/var/log/audit/audit.log  | sort -u"
  log "---"
  log_cmd "$GREP -o denied.* $base_dir/var/log/audit/audit.log  | sort -u"
  log "---"
  log


  log_tee "## MongoDB Storage"
  log
  # FIX
  log "// mongodb storage consumption"
  log "cat $base_dir/sos_commands/foreman/foreman-debug/mongodb_disk_space"
  log "---"
  log_cmd "cat $base_dir/sos_commands/foreman/foreman-debug/mongodb_disk_space"
  log "---"
  log


  log_tee "## PostgreSQL"
  log

  log "// Checking the process/path"
  log "cat $base_dir/ps | grep postgres | grep data"
  log "---"
  log_cmd "cat $base_dir/ps | grep postgres | grep data"
  log "---"
  log

  log "// postgres storage consumption - /var/lib/psql"
  log "cat $base_dir/sos_commands/postgresql/du_-sh_.var.lib.pgsql"
  log "---"
  log_cmd "cat $base_dir/sos_commands/postgresql/du_-sh_.var.lib.pgsql"
  log "---"
  log

  log "// postgres storage consumption - /var/opt/rh/rh-postgresql12/lib/pgsql/data"
  log "cat $base_dir/sos_commands/postgresql/du_-sh_.var..opt.rh.rh-postgresql12.lib.pgsql"
  log "---"
  log_cmd "cat $base_dir/sos_commands/postgresql/du_-sh_.var..opt.rh.rh-postgresql12.lib.pgsql"
  log "---"
  log

  log "// TOP foreman tables consumption"
  log "head -n30 $base_dir/sos_commands/foreman/foreman_db_tables_sizes"
  log "---"
  log_cmd "head -n30 $base_dir/sos_commands/foreman/foreman_db_tables_sizes"
  log "---"
  log  


  log_tee "## PostgreSQL Log - /var/lib/pgsql/"
  log

  log "// Deadlock count"
  log "$GREP -I -i deadlock $base_foreman/var/lib/pgsql/data/pg_log/*.log -c"
  log "---"
  log_cmd "$GREP -I -i deadlock $base_foreman/var/lib/pgsql/data/pg_log/*.log -c"
  log "---"
  log

  log "// Deadlock"
  log "$GREP -I -i deadlock $base_foreman/var/lib/pgsql/data/pg_log/*.log"
  log "---"
  log_cmd "$GREP -I -i deadlock $base_foreman/var/lib/pgsql/data/pg_log/*.log"
  log "---"
  log

  log "// ERROR count"
  log "$GREP -F ERROR $base_foreman/var/lib/pgsql/data/pg_log/*.log -c"
  log "---"
  log_cmd "$GREP -F ERROR $base_foreman/var/lib/pgsql/data/pg_log/*.log -c"
  log "---"
  log

  log "// ERROR"
  log "$GREP -I ERROR $base_foreman/var/lib/pgsql/data/pg_log/*.log"
  log "---"
  log_cmd "$GREP -I ERROR $base_foreman/var/lib/pgsql/data/pg_log/*.log"
  log "---"
  log

  log "// Current Configuration"
  log "cat $base_foreman/var/lib/pgsql/data/postgresql.conf | $GREP -v ^# | $GREP -v ^$ | $GREP -v ^\"\\t\\t\".*#"
  log "---"
  log_cmd "cat $base_foreman/var/lib/pgsql/data/postgresql.conf | $GREP -v ^# | $GREP -v ^$ | $GREP -v ^\"\\t\\t\".*#"
  log "---"
  log


  log_tee "## PostgreSQL Log - /var/opt/rh/rh-postgresql12/lib/pgsql/data"
  log

  log "// Deadlock count"
  log "$GREP -I -i deadlock $base_foreman/var/opt/rh/rh-postgresql12/lib/pgsql/data/log/*.log -c"
  log "---"
  log_cmd "$GREP -I -i deadlock $base_foreman/var/opt/rh/rh-postgresql12/lib/pgsql/data/log/*.log -c"
  log "---"
  log

  log "// Deadlock"
  log "$GREP -I -i deadlock $base_foreman/var/opt/rh/rh-postgresql12/lib/pgsql/data/log/*.log"
  log "---"
  log_cmd "$GREP -I -i deadlock $base_foreman/var/opt/rh/rh-postgresql12/lib/pgsql/data/log/*.log"
  log "---"
  log

  log "// ERROR count"
  log "$GREP -F ERROR $base_foreman/var/opt/rh/rh-postgresql12/lib/pgsql/data/log/*.log -c"
  log "---"
  log_cmd "$GREP -F ERROR $base_foreman/var/opt/rh/rh-postgresql12/lib/pgsql/data/log/*.log -c"
  log "---"
  log

  log "// ERROR"
  log "$GREP -I ERROR $base_foreman/var/opt/rh/rh-postgresql12/lib/pgsql/data/log/*.log"
  log "---"
  log_cmd "$GREP -I ERROR $base_foreman/var/opt/rh/rh-postgresql12/lib/pgsql/data/log/*.log"
  log "---"
  log

  log "// Current Configuration"
  log "cat $base_foreman/var/opt/rh/rh-postgresql12/lib/pgsql/data/postgresql.conf | $GREP -v ^# | $GREP -v ^$ | $GREP -v ^\"\\t\\t\".*#"
  log "---"
  log_cmd "cat $base_foreman/var/opt/rh/rh-postgresql12/lib/pgsql/data/postgresql.conf | $GREP -v ^# | $GREP -v ^$ | $GREP -v ^\"\\t\\t\".*#"
  log "---"
  log


  log_tee "## Passenger"
  log

  log "// current passenger status"

  if [ "$sos_version" == "old" ];then
    cmd="cat $base_dir/sos_commands/foreman/foreman-debug/passenger_status_pool"
  else
    cmd="cat $base_dir/sos_commands/foreman/passenger-status_--show_pool"
  fi

  log "$cmd"
  log "---"
  log_cmd "$cmd"
  log "---"
  log

  log "// URI requests"

  if [ "$sos_version" == "old" ];then
    cmd="cat $base_dir/sos_commands/foreman/foreman-debug/passenger_status_requests | $GREP uri | sort -k3 | uniq -c"
  else
    cmd="cat $base_dir/sos_commands/foreman/passenger-status_--show_requests | $GREP uri | sort -k3 | uniq -c"
  fi

  log "$cmd"
  log "---"
  log_cmd "$cmd"
  log "---"
  log


  log_tee "## Foreman Tasks"
  log

  log "// dynflow running"
  log "cat $base_dir/ps | $GREP dynflow_executor\$"
  log "---"
  log_cmd "cat $base_dir/ps | $GREP dynflow_executor$"
  log "---"
  log



  log_tee "## Qpidd"
  log

  if [ -f $base_dir/sos_commands/katello/qpid-stat_-q_--ssl-certificate_.etc.pki.pulp.qpid.client.crt_-b_amqps_..localhost_5671 ]; then
    qpid_filename="katello/qpid-stat_-q_--ssl-certificate_.etc.pki.pulp.qpid.client.crt_-b_amqps_..localhost_5671"
  fi
  if [ -f $base_dir/sos_commands/katello/qpid-stat_-q_--ssl-certificate_.etc.pki.katello.qpid_client_striped.crt_-b_amqps_..localhost_5671 ]; then
    qpid_filename="katello/qpid-stat_-q_--ssl-certificate_.etc.pki.katello.qpid_client_striped.crt_-b_amqps_..localhost_5671"
  fi
  if [ -f $base_dir/sos_commands/pulp/qpid-stat_-q_--ssl-certificate_.etc.pki.pulp.qpid.client.crt_-b_amqps_..localhost_5671 ]; then
    qpid_filename="pulp/qpid-stat_-q_--ssl-certificate_.etc.pki.pulp.qpid.client.crt_-b_amqps_..localhost_5671"
  fi

  log "// katello_event_queue (foreman-tasks / dynflow is running?)"

  if [ "$sos_version" == "old" ];then
    cmd="$EGREP '(  queue|  ===|katello_event_queue)' $base_dir/sos_commands/foreman/foreman-debug/qpid-stat-q"
  else
    cmd="$EGREP '(  queue|  ===|katello_event_queue)' $base_dir/sos_commands/$qpid_filename"
  fi

  log "$cmd"
  log "---"
  log_cmd "$cmd"
  log "---"
  log


  log "// total number of pulp agents"

  if [ "$sos_version" == "old" ];then
    cmd="cat $base_dir/sos_commands/foreman/foreman-debug/qpid-stat-q | $GREP -F pulp.agent | wc -l"
  else
    cmd="cat $base_dir/sos_commands/$qpid_filename | $GREP -F pulp.agent | wc -l"
  fi

  log "$cmd"
  log "---"
  log_cmd "$cmd"
  log "---"
  log

  log "// total number of (active) pulp agents"

  if [ "$sos_version" == "old" ];then
    cmd="cat $base_dir/sos_commands/foreman/foreman-debug/qpid-stat-q | $GREP -F pulp.agent | $GREP \" 1.*1\$\" | wc -l"
  else
    cmd="cat $base_dir/sos_commands/$qpid_filename | $GREP -F pulp.agent | $GREP \" 1.*1\$\" | wc -l"
  fi

  log "$cmd"
  log "---"
  log_cmd "$cmd"
  log "---"
  log


  log_tee "## Foreman logs (error)"
  log

  # Note: `grep -I` differs from `rg -I` but the difference in behavior is not causing differences in output here. So I'm leaving `$GREP -I`.
  log "// total number of errors found on production.log - TOP 40"
  log "$GREP -I -F \"[E\" $base_foreman/var/log/foreman/production.log* | awk '{print \$4, \$5, \$6, \$7, \$8, \$9, \$10, \$11, \$12, \$13}' | sort | uniq -c | sort -nr | head -n40"
  log "---"
  log_cmd "$GREP -I -F \"[E\" $base_foreman/var/log/foreman/production.log* | awk '{print \$4, \$5, \$6, \$7, \$8, \$9, \$10, \$11, \$12, \$13}' | sort | uniq -c | sort -nr | head -n40"
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


  log_tee "## Httpd"
  log

  log "// queues on error_log means the # of requests crossed the border. Satellite inaccessible"
  log "$GREP -F 'Request queue is full' $base_foreman/var/log/httpd/error_log | wc -l"
  log "---"
  log_cmd "$GREP -F 'Request queue is full' $base_foreman/var/log/httpd/error_log | wc -l"
  log "---"
  log

  log "// when finding something on last step, we will here per date"
  log "$GREP -F queue $base_foreman/var/log/httpd/error_log  | awk '{print \$2, \$3}' | cut -d: -f1,2 | uniq -c"
  log "---"
  log_cmd "$GREP -F queue $base_foreman/var/log/httpd/error_log  | awk '{print \$2, \$3}' | cut -d: -f1,2 | uniq -c"
  log "---"
  log

  log "// TOP 20 of ip address requesting the satellite via https"
  log "cat $base_foreman/var/log/httpd/foreman-ssl_access_ssl.log | awk '{print \$1}' | sort | uniq -c | sort -nr | head -n20"
  log "---"
  log_cmd "cat $base_foreman/var/log/httpd/foreman-ssl_access_ssl.log | awk '{print \$1}' | sort | uniq -c | sort -nr | head -n20"
  log "---"
  log

  log "// TOP 20 of ip address requesting the satellite via https (detailed)"
  log "cat $base_foreman/var/log/httpd/foreman-ssl_access_ssl.log | awk '{print \$1,\$4}' | cut -d: -f1,2,3 | sort | uniq -c | sort -nr | head -n20"
  log "---"
  log_cmd "cat $base_foreman/var/log/httpd/foreman-ssl_access_ssl.log | awk '{print \$1,\$4}' | cut -d: -f1,2,3 | sort | uniq -c | sort -nr | head -n20"
  log "---"
  log

  log "// TOP 50 of uri requesting the satellite via https"
  log "cat $base_foreman/var/log/httpd/foreman-ssl_access_ssl.log | awk '{print \$1, \$6, \$7}' | sort | uniq -c | sort -nr | head -n 50"
  log "---"
  log_cmd "cat $base_foreman/var/log/httpd/foreman-ssl_access_ssl.log | awk '{print \$1, \$6, \$7}' | sort | uniq -c | sort -nr | head -n 50"
  log "---"
  log

  log "// Possible scanner queries"
  log "cat $base_foreman/var/log/httpd/foreman-ssl_access_ssl.log | grep \" 404 \" | grep -E '(\"-\" \"-\")' | head -n10"
  log "---"
  log_cmd "cat $base_foreman/var/log/httpd/foreman-ssl_access_ssl.log | grep \" 404 \" | grep -E '(\"-\" \"-\")' | head -n10"
  log "---"
  log



  log "// General 2XX errors on httpd logs"
  log "$GREP '\" 2\d\d ' $base_foreman/var/log/httpd/foreman-ssl_access_ssl.log | awk '{print \$9}' | sort | uniq -c | sort -nr"
  log "---"
  log_cmd "$GREP '\" 2\d\d ' $base_foreman/var/log/httpd/foreman-ssl_access_ssl.log | awk '{print \$9}' | sort | uniq -c | sort -nr"
  log "---"
  log

  log "// General 3XX errors on httpd logs"
  log "$GREP '\" 3\d\d ' $base_foreman/var/log/httpd/foreman-ssl_access_ssl.log | awk '{print \$9}' | sort | uniq -c | sort -nr"
  log "---"
  log_cmd "$GREP '\" 3\d\d ' $base_foreman/var/log/httpd/foreman-ssl_access_ssl.log | awk '{print \$9}' | sort | uniq -c | sort -nr"
  log "---"
  log

  log "// General 4XX errors on httpd logs"
  log "$GREP '\" 4\d\d ' $base_foreman/var/log/httpd/foreman-ssl_access_ssl.log | awk '{print \$9}' | sort | uniq -c | sort -nr"
  log "---"
  log_cmd "$GREP '\" 4\d\d ' $base_foreman/var/log/httpd/foreman-ssl_access_ssl.log | awk '{print \$9}' | sort | uniq -c | sort -nr"
  log "---"
  log

  log "// General 5XX errors on httpd logs"
  log "$GREP '\" 5\d\d ' $base_foreman/var/log/httpd/foreman-ssl_access_ssl.log | awk '{print \$9}' | sort | uniq -c | sort -nr"
  log "---"
  log_cmd "$GREP '\" 5\d\d ' $base_foreman/var/log/httpd/foreman-ssl_access_ssl.log | awk '{print \$9}' | sort | uniq -c | sort -nr"
  log "---"
  log




  log_tee "## RHSM"
  log

  log "// RHSM Proxy"
  log "$GREP -F proxy $base_dir/etc/rhsm/rhsm.conf | $GREP -v ^#"
  log "---"
  log_cmd "$GREP -F proxy $base_dir/etc/rhsm/rhsm.conf | $GREP -v ^#"
  log "---"
  log

  log "// Satellite Proxy"
  log "$EGREP '(^  proxy_url|^  proxy_port|^  proxy_username|^  proxy_password)' $base_dir/etc/foreman-installer/scenarios.d/satellite-answers.yaml"
  log "---"
  log_cmd "$EGREP '(^  proxy_url|^  proxy_port|^  proxy_username|^  proxy_password)' $base_dir/etc/foreman-installer/scenarios.d/satellite-answers.yaml"
  log "---"
  log

  log "// Virt-who Proxy"
  log "$GREP -F -i proxy $base_dir/etc/sysconfig/virt-who"
  log "---"
  log_cmd "$GREP -F -i proxy $base_dir/etc/sysconfig/virt-who"
  log "---"
  log

  log "// RHSM errors"
  log "$GREP -F ERROR $base_dir/var/log/rhsm/rhsm.log"
  log "---"
  log_cmd "$GREP -F ERROR $base_dir/var/log/rhsm/rhsm.log"
  log "---"
  log

  log "// RHSM Warnings"
  log "$GREP -F WARNING $base_dir/var/log/rhsm/rhsm.log"
  log "---"
  log_cmd "$GREP -F WARNING $base_dir/var/log/rhsm/rhsm.log"
  log "---"
  log

  log "// duplicated hypervisors #"
  log "$GREP -F \"is assigned to 2 different systems\" $base_dir/var/log/rhsm/rhsm.log | awk '{print \$9}' | sed -e \"s/'//g\" | sort -u | wc -l"
  log "---"
  log_cmd "$GREP -F \"is assigned to 2 different systems\" $base_dir/var/log/rhsm/rhsm.log | awk '{print \$9}' | sed -e \"s/'//g\" | sort -u | wc -l"
  log "---"
  log

  log "// duplicated hypervisors list"
  log "$GREP -F \"is assigned to 2 different systems\" $base_dir/var/log/rhsm/rhsm.log | awk '{print \$9}' | sed -e \"s/'//g\" | sort -u"
  log "---"
  log_cmd "$GREP -F \"is assigned to 2 different systems\" $base_dir/var/log/rhsm/rhsm.log | awk '{print \$9}' | sed -e \"s/'//g\" | sort -u"
  log "---"
  log

  log "// Sending updated Host-to-guest"
  log "$GREP -F \"Sending updated Host-to-guest\" $base_dir/var/log/rhsm/rhsm.log"
  log "---"
  log_cmd "$GREP -F \"Sending updated Host-to-guest\" $base_dir/var/log/rhsm/rhsm.log"
  log "---"
  log




  log_tee "## Virt-who"
  log

  log "// virt-who status"
  log "cat $base_dir/sos_commands/systemd/systemctl_list-units | $GREP -F virt-who"
  log "---"
  log_cmd "cat $base_dir/sos_commands/systemd/systemctl_list-units | $GREP -F virt-who"
  log "---"
  log

  log "// virt-who default configuration"
  log "cat $base_dir/etc/sysconfig/virt-who | $GREP -v ^# | $GREP -v ^$"
  log "---"
  log_cmd "cat $base_dir/etc/sysconfig/virt-who | $GREP -v ^# | $GREP -v ^$"
  log "---"
  log

  log "// virt-who configuration"
  log "ls -l $base_dir/etc/virt-who.d"
  log "---"
  log_cmd "ls -l $base_dir/etc/virt-who.d"
  log "---"
  log

  log "// duplicated server entries on virt-who configuration"
  log "$GREP -I ^server $base_dir/etc/virt-who.d/*.conf | sort | uniq -c"
  log "---"
  log_cmd "$GREP -I ^server $base_dir/etc/virt-who.d/*.conf | sort | uniq -c"
  log "---"
  log



  log "// virt-who configuration content files"
  log "for b in \$(ls -1 \$base_dir/etc/virt-who.d/*.conf); do echo; echo \$b; echo \"===\"; cat \$b; echo \"===\"; done"
  log "---"
  log_cmd "for b in \$(ls -1 $base_dir/etc/virt-who.d/*.conf); do echo; echo \$b; echo \"===\"; cat \$b; echo \"===\"; done"
  log "---"
  log

  log "// virt-who configuration content files (hidden characters)"
  log "for b in \$(ls -1 \$base_dir/etc/virt-who.d/*.conf); do echo; echo \$b; echo \"===\"; cat -vet \$b; echo \"===\"; done"
  log "---"
  log_cmd "for b in \$(ls -1 $base_dir/etc/virt-who.d/*.conf); do echo; echo \$b; echo \"===\"; cat -vet \$b; echo \"===\"; done"
  log "---"
  log

  log "// virt-who server(s)"
  log "cat $base_foreman/var/log/httpd/foreman-ssl_access_ssl.log  | $GREP -F \"cmd=virt-who\" | awk '{print \$1}' | sort | uniq -c"
  log "---"
  log_cmd "cat $base_foreman/var/log/httpd/foreman-ssl_access_ssl.log  | $GREP -F \"cmd=virt-who\" | awk '{print \$1}' | sort | uniq -c"
  log "---"
  log



  log_tee "## Hypervisors tasks"
  log

  log "// latest 30 hypervisors tasks"

  if [ "$sos_version" == "old" ];then
    cmd="cat $base_foreman/foreman_tasks_tasks.csv | $EGREP '(^                  id|Hypervisors)' | sed -e 's/,/ /g' | sort -rk6 | head -n 30 | cut -d\| -f3,4,5,6,7"
  else
    cmd="cat $base_dir/sos_commands/foreman/foreman_tasks_tasks | $EGREP '(^                  id|Hypervisors)' | sed -e 's/,/ /g' | sort -rk6 | head -n 30 | cut -d\| -f3,4,5,6,7"
  fi

  log "$cmd"
  log "---"
  log_cmd "$cmd"
  log "---"
  log


  log_tee "## Tomcat"
  log

  log "// Memory (Xms and Xmx)"
  log "$GREP -F tomcat $base_dir/ps"
  log "---"
  log_cmd "$GREP -F tomcat $base_dir/ps"
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
  log "$GREP -F -B1 Updated $base_foreman/var/log/candlepin/candlepin.log"
  log "---"
  log_cmd "$GREP -F -B1 Updated $base_foreman/var/log/candlepin/candlepin.log"
  log "---"
  log

  log "// ERROR on candlepin log - candlepin.log"
  log "$GREP -F ERROR $base_foreman/var/log/candlepin/candlepin.log | cut -d ' ' -f1,3- | uniq -c"
  log "---"
  log_cmd "$GREP -F ERROR $base_foreman/var/log/candlepin/candlepin.log | cut -d ' ' -f1,3- | uniq -c"
  log "---"
  log

  log "// ERROR on candlepin log - error.log"
  log "$GREP -F ERROR $base_foreman/var/log/candlepin/error.log | cut -d ' ' -f1,3- | uniq -c"
  log "---"
  log_cmd "$GREP -F ERROR $base_foreman/var/log/candlepin/error.log | cut -d ' ' -f1,3- | uniq -c"
  log "---"
  log

  log "// latest entry on error.log"
  log "tail -30 $base_foreman/var/log/candlepin/error.log"
  log "---"
  log_cmd "tail -30 $base_foreman/var/log/candlepin/error.log"
  log "---"
  log

  log "// candlepin storage consumption"
  log "cat $base_dir/sos_commands/candlepin/du_-sh_.var.lib.candlepin"
  log "---"
  log_cmd "cat $base_dir/sos_commands/candlepin/du_-sh_.var.lib.candlepin"
  log "---"
  log

  log "// SCA Information"
  log "$GREP -i \"content access mode\" $base_dir/var/log/candlepin/* | grep -o \"Auto-attach is disabled.*\" | sort -u | grep -v Skipping"
  log "---"
  log_cmd "$GREP -i \"content access mode\" $base_dir/var/log/candlepin/* | grep -o \"Auto-attach is disabled.*\" | sort -u | grep -v Skipping"
  log "---"
  log

  log "// Tasks in Candlepin - Time in miliseconds - TOP 20"
  log "$GREP -o time=.* candlepin.log $base_dir/var/log/candlepin/* | sort -nr | sed -e 's/=/ /g' | sort -k2 -nr | uniq -c | head -n20 | sed -s 's/time /time=/g' | cut -d: -f2"
  log "---"
  log_cmd "$GREP -o time=.* candlepin.log $base_dir/var/log/candlepin/* | sort -nr | sed -e 's/=/ /g' | sort -k2 -nr | uniq -c | head -n20 | sed -s 's/time /time=/g' | cut -d: -f2"
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
  log_cmd "for b in $(ls -1 $base_dir/var/spool/cron/*); do echo; echo \$b; echo \"===\"; cat \$b; echo \"===\"; done"
  log "---"
  log


  log_tee "## Files in etc/cron*"
  log

  log "// all files located on /etc/cron*"
  log "find $base_dir/etc/cron* -type f | awk 'FS=\"/etc/\" {print \$2}'"
  log "---"
  log_cmd "find $base_dir/etc/cron* -type f | awk 'FS=\"/etc/\" {print \$2}'"
  log "---"
  log


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


  log_tee "## Tuning"
  log

  log "// prefork.conf configuration"
  log "cat $base_dir/etc/httpd/conf.modules.d/prefork.conf | $EGREP 'ServerLimit|StartServers'"
  log "---"
  log_cmd "cat $base_dir/etc/httpd/conf.modules.d/prefork.conf | $EGREP 'ServerLimit|StartServers'"
  log "---"
  log

  log "// 05-foreman.conf configuration"
  log "cat $base_dir/etc/httpd/conf.d/05-foreman.conf | $EGREP 'KeepAlive\b|MaxKeepAliveRequests|KeepAliveTimeout|PassengerMinInstances'"
  log "---"
  log_cmd "cat $base_dir/etc/httpd/conf.d/05-foreman.conf | $EGREP 'KeepAlive\b|MaxKeepAliveRequests|KeepAliveTimeout|PassengerMinInstances'"
  log "---"
  log

  log "// 05-foreman-ssl.conf configuration"
  log "cat $base_dir/etc/httpd/conf.d/05-foreman-ssl.conf | $EGREP 'KeepAlive\b|MaxKeepAliveRequests|KeepAliveTimeout|PassengerMinInstances'"
  log "---"
  log_cmd "cat $base_dir/etc/httpd/conf.d/05-foreman-ssl.conf | $EGREP 'KeepAlive\b|MaxKeepAliveRequests|KeepAliveTimeout|PassengerMinInstances'"
  log "---"
  log

  log "// katello.conf configuration"
  log "cat $base_dir/etc/httpd/conf.d/05-foreman-ssl.d/katello.conf | $EGREP 'KeepAlive\b|MaxKeepAliveRequests|KeepAliveTimeout'"
  log "---"
  log_cmd "cat $base_dir/etc/httpd/conf.d/05-foreman-ssl.d/katello.conf | $EGREP 'KeepAlive\b|MaxKeepAliveRequests|KeepAliveTimeout'"
  log "---"
  log

  log "// passenger.conf configuration - 6.3 or less"
  log "cat $base_dir/etc/httpd/conf.d/passenger.conf | $EGREP 'MaxPoolSize|PassengerMaxRequestQueueSize'"
  log "---"
  log_cmd "cat $base_dir/etc/httpd/conf.d/passenger.conf | $EGREP 'MaxPoolSize|PassengerMaxRequestQueueSize'"
  log "---"
  log

  log "// passenger-extra.conf configuration - 6.4+"
  log "cat $base_dir/etc/httpd/conf.modules.d/passenger_extra.conf | $EGREP 'MaxPoolSize|PassengerMaxRequestQueueSize'"
  log "---"
  log_cmd "cat $base_dir/etc/httpd/conf.modules.d/passenger_extra.conf | $EGREP 'MaxPoolSize|PassengerMaxRequestQueueSize'"
  log "---"
  log

  log "// pulp_workers configuration"
  log "cat $base_dir/etc/default/pulp_workers | $EGREP '^PULP_MAX_TASKS_PER_CHILD|^PULP_CONCURRENCY'"
  log "---"
  log_cmd "cat $base_dir/etc/default/pulp_workers | $EGREP '^PULP_MAX_TASKS_PER_CHILD|^PULP_CONCURRENCY'"
  log "---"
  log

  log "// foreman-tasks/dynflow configuration - 6.3 or less"
  log "cat $base_dir/etc/sysconfig/foreman-tasks | $EGREP 'EXECUTOR_MEMORY_LIMIT|EXECUTOR_MEMORY_MONITOR_DELAY|EXECUTOR_MEMORY_MONITOR_INTERVAL'"
  log "---"
  log_cmd "cat $base_dir/etc/sysconfig/foreman-tasks | $EGREP 'EXECUTOR_MEMORY_LIMIT|EXECUTOR_MEMORY_MONITOR_DELAY|EXECUTOR_MEMORY_MONITOR_INTERVAL'"
  log "---"
  log

  log "// foreman-tasks/dynflow configuration - 6.4+"
  log "cat $base_dir/etc/sysconfig/dynflowd | $EGREP 'EXECUTOR_MEMORY_LIMIT|EXECUTOR_MEMORY_MONITOR_DELAY|EXECUTOR_MEMORY_MONITOR_INTERVAL'"
  log "---"
  log_cmd "cat $base_dir/etc/sysconfig/dynflowd | $EGREP 'EXECUTOR_MEMORY_LIMIT|EXECUTOR_MEMORY_MONITOR_DELAY|EXECUTOR_MEMORY_MONITOR_INTERVAL'"
  log "---"
  log

  log "// postgres configuration"
  log "cat $base_dir/var/lib/pgsql/data/postgresql.conf | $EGREP 'max_connections|shared_buffers|work_mem|checkpoint_segments|checkpoint_completion_target' | $GREP -v '^#'"
  log "---"
  log_cmd "cat $base_dir/var/lib/pgsql/data/postgresql.conf | $EGREP 'max_connections|shared_buffers|work_mem|checkpoint_segments|checkpoint_completion_target' | $GREP -v '^#'"
  log "---"
  log

  log "// tomcat configuration"
  log "cat $base_dir/etc/tomcat/tomcat.conf | $GREP -F 'JAVA_OPTS'"
  log "---"
  log_cmd "cat $base_dir/etc/tomcat/tomcat.conf | $GREP -F 'JAVA_OPTS'"
  log "---"
  log

  log "// qpidd configuration"
  log "cat $base_dir/etc/qpid/qpidd.conf | $GREP -F 'mgmt_pub_interval'"
  log "---"
  log_cmd "cat $base_dir/etc/qpid/qpidd.conf | $GREP -F 'mgmt_pub_interval'"
  log "---"
  log

  log "// Insert qpidd information"
  log "cat $base_dir/sos_commands/qpid/ls_-lanR_.var.lib.qpidd | $GREP \" [A-Z][a-z]{2} [0-9]{2} [0-9]{2}:[0-9]{2} \" | awk '{print \$5}' | paste -s -d+ | bc"
  log "---"
  log_cmd "cat $base_dir/sos_commands/qpid/ls_-lanR_.var.lib.qpidd | $GREP \" [A-Z][a-z]{2} [0-9]{2} [0-9]{2}:[0-9]{2} \" | awk '{print \$5}' | paste -s -d+ | bc | awk '{print \"bytes: \"\$1}'"
  fullsize_var_lib_qpid=$(cat $base_dir/sos_commands/qpid/ls_-lanR_.var.lib.qpidd | $GREP " [A-Z][a-z]{2} [0-9]{2} [0-9]{2}:[0-9]{2} " | awk '{print $5}' | paste -s -d+ | bc)
  size_var_lib_qpid=$(bytesToHumanReadable ${fullsize_var_lib_qpid})
  log "size: ${size_var_lib_qpid}"
  log "---"
  log

  log "// httpd|apache limits"
  log "cat $base_dir/etc/systemd/system/httpd.service.d/limits.conf | $GREP -F 'LimitNOFILE'"
  log "---"
  log_cmd "cat $base_dir/etc/systemd/system/httpd.service.d/limits.conf | $GREP -F 'LimitNOFILE'"
  log "---"
  log

  log "// qrouterd limits"
  log "cat $base_dir/etc/systemd/system/qdrouterd.service.d/90-limits.conf | $GREP -F 'LimitNOFILE'"
  log "---"
  log_cmd "cat $base_dir/etc/systemd/system/qdrouterd.service.d/90-limits.conf | $GREP -F 'LimitNOFILE'"
  log "---"
  log

  log "// qpidd limits"
  log "cat $base_dir/etc/systemd/system/qpidd.service.d/90-limits.conf | $GREP -F 'LimitNOFILE'"
  log "---"
  log_cmd "cat $base_dir/etc/systemd/system/qpidd.service.d/90-limits.conf | $GREP -F 'LimitNOFILE'"
  log "---"
  log

  log "// smart proxy dynflow core limits"
  log "cat $base_dir/etc/systemd/system/smart_proxy_dynflow_core.service.d/90-limits.conf | $GREP -F 'LimitNOFILE'"
  log "---"
  log_cmd "cat $base_dir/etc/systemd/system/smart_proxy_dynflow_core.service.d/90-limits.conf | $GREP -F 'LimitNOFILE'"
  log "---"
  log

  log "// sysctl configuration"
  log "cat $base_dir/etc/sysctl.conf | $GREP -F 'fs.aio-max-nr'"
  log "---"
  log_cmd "cat $base_dir/etc/sysctl.conf | $GREP -F 'fs.aio-max-nr'"
  log "---"
  log

  log "// dynflow executors - 6.3 or less"
  log "$GREP -F EXECUTORS_COUNT $base_dir/etc/sysconfig/foreman-tasks"
  log "---"
  log_cmd "$GREP -F EXECUTORS_COUNT $base_dir/etc/sysconfig/foreman-tasks"
  log "---"
  log
 
  log "// dynflow executors - 6.4 or greater"
  log "$GREP -F EXECUTORS_COUNT $base_dir/etc/sysconfig/dynflowd"
  log "---"
  log_cmd "$GREP -F EXECUTORS_COUNT $base_dir/etc/sysconfig/dynflowd"
  log "---"
  log


  log "// Used answer file during the satellite-installer run"
  log "cat $base_dir/etc/foreman-installer/scenarios.d/satellite.yaml | grep answer"
  log "---"
  log_cmd "cat $base_dir/etc/foreman-installer/scenarios.d/satellite.yaml | grep answer"
  log "---"
  log

  log "// Current tuning preset"
  log "cat $base_dir/etc/foreman-installer/scenarios.d/satellite.yaml | grep tunin"
  log "---"
  log_cmd "cat $base_dir/etc/foreman-installer/scenarios.d/satellite.yaml | grep tunin"
  log "---"
  log

  log "// Current puma setting"
  log "cat $base_dir/etc/foreman-installer/scenarios.d/satellite-answers.yaml | grep puma"
  log "---"
  log_cmd "cat $base_dir/etc/foreman-installer/scenarios.d/satellite-answers.yaml | grep puma"
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




  if [ /tmp/script/ins_check.sh ]; then
    echo "Calling insights ..."
    /tmp/script/ins_check.sh $sos_path >> $FOREMAN_REPORT
    echo "done."
  fi

  if [ $COPY_TO_CURRENT_DIR ] || [ $OPEN_IN_VIM_RO_LOCAL_DIR ]; then
    echo 
    echo
    echo "## Creating a copy of the report in your current directory - $MYPWD/report_${USER}_$final_name.log"
    cp $FOREMAN_REPORT $MYPWD/report_${USER}_$final_name.log
  fi

  mv $FOREMAN_REPORT /tmp/report_${USER}_$final_name.log
  echo 
  echo
  echo "## Please check out the file /tmp/report_${USER}_$final_name.log"


}




# Main

if [ "$1" == "" ] || [ "$1" == "--help" ]; then
  echo "Please inform the path to the sosrepor dir that you would like to analyze."
  echo "$0 [OPTION] 01234567/sosreport_do_wall"
  echo ""
  echo "OPTION"
  echo "You can add a flags after $0 as informed below"
  echo "   -c copies the output file from the /tmp directory to the current directory"
  echo "   -l opens the output file from the current directory"
  echo "   -t opens the output file from the /tmp directory"
  exit 1
fi

main $1


# the following code will open the requested report
# in the user's editor of choice
# if none is defined, "less" will be chosen.

if [ ! "$EDITOR" ]; then
   EDITOR=`which less`
fi

if [ $OPEN_IN_VIM_RO_LOCAL_DIR ]; then
   $EDITOR -R $MYPWD/report_${USER}_$final_name.log
fi

if [ $OPEN_IN_EDITOR_TMP_DIR ]; then
   #echo placeholder 
   $EDITOR /tmp/report_${USER}_$final_name.log
fi
