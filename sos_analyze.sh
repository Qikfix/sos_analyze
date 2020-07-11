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

  #sos_path=$1
  #base_dir=$sos_path
  final_name=$(echo $base_dir | sed -e 's#/$##g' | grep -o sos.* | awk -F"/" '{print $NF}')

#  if [ ! -f $base_dir/version.txt ]; then
#    echo "This is not a sosreport dir, please inform the path to the correct one."
#    exit 1
#  fi

  # detect base directory

  base_dir=""
  sos_subdir=`ls -d $1/sosreport-* $1/foreman-debug-* $1/spacewalk-debug 2>/dev/null | grep . | head -1`

  if [ -d conf ] || [ -d sos_commands ] || [ -f version.txt ] || [ -f hammer-ping ]; then

    base_dir=`pwd`

  elif [ -d $1/conf ] || [ -d $1/sos_commands ] || [ -f $1/version.txt ] || [ -f $1/hammer-ping ]; then

    base_dir="$1"

  elif [ -d $sos_subdir/conf ] || [ -d $sos_subdir/sos_commands ] || [ -f $sos_subdir/version.txt ] || [ -f $sos_subdir/hammer-ping ]; then

    base_dir="$sos_subdir"

  else

    echo "This is not a sosreport dir, please inform the path to the correct one."
    exit 1

  fi

  # detect presence of foreman-debug directory

  if [ -d $base_dir/sos_commands/foreman/foreman-debug ]; then
    base_foreman="/sos_commands/foreman/foreman-debug/"
    sos_version="old"
  else
    sos_version="new"
    base_foreman="/"
  fi

  echo "The sosreport is: $base_dir"												| tee -a $FOREMAN_REPORT

  consolidate_differences

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


# The CSVLINKS variable contains files to which we want to link, along with alternate filenames found in older sosreport versions, foreman-debug files and satellite-debug files.

CSVLINKS="sos_commands/block/blkid_-c_.dev.null,blkid
sos_commands/boot/efibootmgr_-v,efibootmgr
sos_commands/candlepin/du_-sh_.var.lib.candlepin,hornetq_disk_space
sos_commands/cron/root_crontab,crontab_-l
sos_commands/date/date,timestamp
sos_commands/filesys/df_-ali_-x_autofs,df_-ali
sos_commands/filesys/df_-al_-x_autofs,df_-al
sos_commands/foreman/bundle_--local_--gemfile_.usr.share.foreman.Gemfile,bundle_list
sos_commands/foreman/foreman-selinux-relabel_-nv,foreman_filecontexts
sos_commands/foreman/ls_-lanR_.root.ssl-build,katello_ssl_build_dir
sos_commands/foreman/ls_-lanR_.usr.share.foreman.config.hooks,foreman_hooks_list
sos_commands/foreman/passenger-memory-stats,passenger_memory
sos_commands/foreman/passenger-status_--show_backtraces,passenger_status_backtraces
sos_commands/foreman/passenger-status_--show_pool,passenger_status_pool
sos_commands/foreman/passenger-status_--show_requests,passenger_status_requests
sos_commands/foreman/ping_-c1_-W1_localhost,ping_localhost
sos_commands/foreman/scl_enable_tfm_gem_list,gem_list_scl
sos_commands/kernel/modinfo_ALL_MODULES,modinfo_tpm_tpm_tis_libata_efivars_tcp_cubic_kernel_printk_kgdb_spurious_pstore_dynamic_debug_pcie_aspm_pci_hotplug_pciehp_acpiphp_intel_idle_acpi_pci_slot_processor_thermal_acpi_memhotplug_battery_keyboard_vt_8250_kgdboc_kgdbts_scsi_mod_pcmcia_core_pcmci,modinfo_nfsd_exportfs_auth_rpcgss_usb_storage_ipmi_devintf_ipmi_
sos_commands/kernel/uname_-a,uname
sos_commands/libraries/ldconfig_-p_-N_-X,ldconfig_-p
sos_commands/lvm2/lvs_-a_-o_lv_tags_devices_lv_kernel_read_ahead_lv_read_ahead_stripes_stripesize_--config_global_locking_type_0_metadata_read_only_1,lvs_-a_-o_lv_tags_devices_--config_global_locking_type_0
sos_commands/lvm2/pvs_-a_-v_-o_pv_mda_free_pv_mda_size_pv_mda_count_pv_mda_used_count_pe_start_--config_global_locking_type_0_metadata_read_only_1,pvs_-a_-v_-o_pv_mda_free_pv_mda_size_pv_mda_count_pv_mda_used_count_pe_start_--config_global_locking_type_0
sos_commands/lvm2/pvscan_-v_--config_global_locking_type_0_metadata_read_only_1,pvscan_-v_--config_global_locking_type_0
sos_commands/lvm2/vgdisplay_-vv_--config_global_locking_type_0_metadata_read_only_1,vgdisplay_-vv_--config_global_locking_type_0
sos_commands/lvm2/vgscan_-vvv_--config_global_locking_type_0_metadata_read_only_1,vgscan_-vvv_--config_global_locking_type_0
sos_commands/lvm2/vgs_-v_-o_vg_mda_count_vg_mda_free_vg_mda_size_vg_mda_used_count_vg_tags_--config_global_locking_type_0_metadata_read_only_1,vgs_-v_-o_vg_mda_count_vg_mda_free_vg_mda_size_vg_mda_used_count_vg_tags_--config_global_locking_type_0
sos_commands/networking/ip_-d_address,ip_address,ip_a
sos_commands/networking/ip_neigh_show_nud_noarp,ip_neigh_show
sos_commands/networking/ip_route_show_table_all,ip_r
sos_commands/networking/ip_-s_-d_link,ip_-s_link
sos_commands/networking/iptables_-t_filter_-nvL,iptables_-t_mangle_-nvL
sos_commands/networking/iptables_-vnxL,iptables_-t_nat_-nvL,iptables
sos_commands/networking/netstat_-W_-agn,netstat_-agn
sos_commands/networking/netstat_-W_-neopa,netstat_-neopa,netstat
sos_commands/networking/route_-n,route
sos_commands/pam/ls_-lanF_.lib_.security,ls_-laF_.lib.security.pam__so
sos_commands/pci/lspci_-nnvv,lspci_-nvv
sos_commands/postgresql/du_-sh_.var.lib.pgsql,postgres_disk_space
sos_commands/process/lsof_-b_M_-n_-l_-c,lsof_-b_M_-n_-l
sos_commands/process/ps_auxwww,process_list
sos_commands/process/ps_-elfL,ps-elfm
sos_commands/puppet/facter,facts
sos_commands/puppet/ls_-lanR_.etc.puppetlabs.code.modules,puppet_manifests_tree
sos_commands/puppet/ls_-lanR_.etc.puppet.modules,puppet_manifests_tree
sos_commands/puppet/puppet_--version,version_puppet
sos_commands/rpm/sh_-c_rpm_--nodigest_-qa_--qf_NAME_-_VERSION_-_RELEASE_._ARCH_INSTALLTIME_date_awk_-F_printf_-59s_s_n_1_2_sort_-V,sh_-c_rpm_--nodigest_-qa_--qf_NAME_-_VERSION_-_RELEASE_._ARCH_INSTALLTIME_date_awk_-F_printf_-59s_s_n_1_2_sort_-f,rpm_-qa_--qf_NAME_-_VERSION_-_RELEASE_._ARCH_INSTALLTIME_date_.b,installed_packages,rpm-manifest
sos_commands/satellite/rhn-charsets,database-character-sets
sos_commands/satellite/rhn-schema-version,database-schema-version
sos_commands/selinux/semanage_fcontext_-l,selinux_fcontext
sos_commands/tftpserver/ls_-lanR_.tftpboot,tftpboot_tree
sos_commands/selinux/semodule_-l,selinux_modules
sos_commands/hardware/dmesg_.bin.grep_-e_e820._-e_agp,dmesg_grep_-e_e820._-e_aperature
sos_commands/networking/ifconfig_-a,ifconfig
etc/hosts
var/log/audit/audit.log,selinux_denials.log
sos_commands/alternatives/alternatives_--display_elspec
sos_commands/alternatives/alternatives_--display_emacs.etags
sos_commands/alternatives/alternatives_--display_java
sos_commands/alternatives/alternatives_--display_jaxp_parser_impl
sos_commands/alternatives/alternatives_--display_jaxp_transform_impl
sos_commands/alternatives/alternatives_--display_jre_1.8.0
sos_commands/alternatives/alternatives_--display_jre_1.8.0_openjdk
sos_commands/alternatives/alternatives_--display_jre_openjdk
sos_commands/alternatives/alternatives_--display_jsp
sos_commands/alternatives/alternatives_--display_libnssckbi.so.x86_64
sos_commands/alternatives/alternatives_--display_mta
sos_commands/alternatives/alternatives_--display_nmap
sos_commands/alternatives/alternatives_--display_servlet
sos_commands/alternatives/alternatives_--list
sos_commands/alternatives/alternatives_--version
sos_commands/alternatives/rpm_-V_chkconfig
sos_commands/ansible/ansible_all_-m_ping_-vvvv
sos_commands/ansible/ansible_--version
sos_commands/ansible/rpm_-V_ansible
sos_commands/apache/apachectl_-M
sos_commands/apache/apachectl_-S
sos_commands/apache/rpm_-V_httpd
sos_commands/auditd/auditctl_-l
sos_commands/auditd/auditctl_-s
sos_commands/auditd/ausearch_--input-logs_-m_avc_user_avc_-ts_today
sos_commands/auditd/rpm_-V_audit
sos_commands/block/blockdev_--report
sos_commands/block/lsblk
sos_commands/block/lsblk_-D
sos_commands/block/lsblk_-f_-a_-l
sos_commands/block/lsblk_-t
sos_commands/block/ls_-lanR_.dev
sos_commands/block/ls_-lanR_.sys.block
sos_commands/block/rpm_-V_util-linux
sos_commands/boot/lsinitrd
sos_commands/boot/ls_-lanR_.boot
sos_commands/boot/mokutil_--sb-state
sos_commands/boot/rpm_-V_grub2_grub2-common
sos_commands/btrfs/btrfs_filesystem_show
sos_commands/btrfs/btrfs_version
sos_commands/btrfs/rpm_-V_btrfs-progs
sos_commands/candlepin/candlepin_db_tables_sizes
sos_commands/candlepin/rpm_-V_candlepin
sos_commands/ceph/ceph_df
sos_commands/ceph/ceph-disk_list
sos_commands/ceph/ceph_fs_dump_--format_json-pretty
sos_commands/ceph/ceph_fs_ls
sos_commands/ceph/ceph_health_detail
sos_commands/ceph/ceph_health_detail_--format_json-pretty
sos_commands/ceph/ceph_mon_dump
sos_commands/ceph/ceph_mon_stat
sos_commands/ceph/ceph_mon_status
sos_commands/ceph/ceph_osd_crush_dump
sos_commands/ceph/ceph_osd_crush_show-tunables
sos_commands/ceph/ceph_osd_df_tree
sos_commands/ceph/ceph_osd_dump
sos_commands/ceph/ceph_osd_stat
sos_commands/ceph/ceph_osd_tree
sos_commands/ceph/ceph_pg_dump
sos_commands/ceph/ceph_quorum_status
sos_commands/ceph/ceph_report
sos_commands/ceph/ceph_status
sos_commands/ceph/ceph_versions
sos_commands/ceph/rpm_-V_librados2
sos_commands/cgroups/systemd-cgls
sos_commands/chrony/chronyc_activity
sos_commands/chrony/chronyc_-n_clients
sos_commands/chrony/chronyc_-n_sources
sos_commands/chrony/chronyc_ntpdata
sos_commands/chrony/chronyc_serverstats
sos_commands/chrony/chronyc_sourcestats
sos_commands/chrony/chronyc_tracking
sos_commands/chrony/journalctl_--no-pager_--unit_chronyd
sos_commands/chrony/rpm_-V_chrony
sos_commands/crypto/fips-mode-setup_--check
sos_commands/crypto/update-crypto-policies_--is-applied
sos_commands/crypto/update-crypto-policies_--show
sos_commands/date/date_--utc
sos_commands/date/hwclock
sos_commands/dbus/busctl_list_--no-pager
sos_commands/dbus/busctl_status
sos_commands/dbus/rpm_-V_dbus
sos_commands/devicemapper/dmsetup_info_-c
sos_commands/devicemapper/dmsetup_ls_--tree
sos_commands/devicemapper/dmsetup_status
sos_commands/devicemapper/dmsetup_table
sos_commands/devicemapper/dmstats_list
sos_commands/devicemapper/dmstats_print_--allregions
sos_commands/devicemapper/rpm_-V_device-mapper
sos_commands/devices/udevadm_info_--export-db
sos_commands/docker/journalctl_--no-pager_--unit_docker
sos_commands/docker/ls_-alhR_.etc.docker
sos_commands/dracut/dracut_--list-modules
sos_commands/dracut/dracut_--print-cmdline
sos_commands/dracut/rpm_-V_dracut
sos_commands/filesys/findmnt
sos_commands/filesys/lslocks
sos_commands/filesys/ls_-ltradZ_.tmp
sos_commands/filesys/mount_-l
sos_commands/firewalld/firewall-cmd_--direct_--get-all-chains
sos_commands/firewalld/firewall-cmd_--direct_--get-all-passthroughs
sos_commands/firewalld/firewall-cmd_--direct_--get-all-rules
sos_commands/firewalld/firewall-cmd_--get-log-denied
sos_commands/firewalld/firewall-cmd_--list-all-zones
sos_commands/firewalld/firewall-cmd_--permanent_--direct_--get-all-chains
sos_commands/firewalld/firewall-cmd_--permanent_--direct_--get-all-passthroughs
sos_commands/firewalld/firewall-cmd_--permanent_--direct_--get-all-rules
sos_commands/firewalld/firewall-cmd_--permanent_--list-all-zones
sos_commands/firewalld/firewall-cmd_--state
sos_commands/firewalld/nft_list_ruleset
sos_commands/firewalld/rpm_-V_firewalld
sos_commands/foreman/dynflow_actions
sos_commands/foreman/dynflow_execution_plans
sos_commands/foreman/dynflow_schema_info
sos_commands/foreman/dynflow_steps
sos_commands/foreman/foreman_auth_table
sos_commands/foreman/foreman_db_tables_sizes
sos_commands/foreman/foreman-maintain_service_status
sos_commands/foreman/foreman_settings_table
sos_commands/foreman/foreman_tasks_tasks
sos_commands/foreman/hammer_ping
sos_commands/foreman/rpm_-V_foreman_foreman-proxy
sos_commands/grub2/grub2-mkconfig
sos_commands/grub2/ls_-lanR_.boot
sos_commands/grub2/rpm_-V_grub2_grub2-common
sos_commands/hardware/dmidecode
sos_commands/host/hostid
sos_commands/host/hostname
sos_commands/host/hostnamectl_status
sos_commands/host/hostname_-f
sos_commands/host/uptime
sos_commands/i18n/locale
sos_commands/insights/rpm_-V_insights-client
sos_commands/ipmitool/ipmitool_chassis_status
sos_commands/ipmitool/ipmitool_fru_print
sos_commands/ipmitool/ipmitool_mc_info
sos_commands/ipmitool/ipmitool_sdr_info
sos_commands/ipmitool/ipmitool_sel_info
sos_commands/ipmitool/ipmitool_sel_list
sos_commands/ipmitool/ipmitool_sensor_list
sos_commands/ipmitool/rpm_-V_ipmitool
sos_commands/java/alternatives_--display_java
sos_commands/java/readlink_-f_.usr.bin.java
sos_commands/katello/db_table_size
sos_commands/katello/katello_repositories
sos_commands/katello/qpid-stat_-c_--ssl-certificate_.etc.pki.katello.qpid_client_striped.crt_-b_amqps_..localhost_5671
sos_commands/katello/qpid-stat_-q_--ssl-certificate_.etc.pki.katello.qpid_client_striped.crt_-b_amqps_..localhost_5671
sos_commands/katello/qpid-stat_-u_--ssl-certificate_.etc.pki.katello.qpid_client_striped.crt_-b_amqps_..localhost_5671
sos_commands/katello/rpm_-V_katello
sos_commands/kdump/rpm_-V_kexec-tools
sos_commands/kernel/bpftool_-j_map_list
sos_commands/kernel/bpftool_-j_prog_list
sos_commands/kernel/dkms_status
sos_commands/kernel/dmesg
sos_commands/kernel/ls_-lt_.sys.kernel.slab
sos_commands/kernel/lsmod
sos_commands/kernel/rpm_-V_kernel
sos_commands/kernel/sysctl_-a
sos_commands/krb5/klist_-ket_.etc.krb5.keytab
sos_commands/krb5/klist_-ket_.var.kerberos.krb5kdc..k5
sos_commands/krb5/rpm_-V_krb5-libs
sos_commands/last/last
sos_commands/last/lastlog
sos_commands/last/last_reboot
sos_commands/last/last_shutdown
sos_commands/ldap/certutil_-L_-d_.etc.openldap
sos_commands/ldap/rpm_-V_openldap
sos_commands/libraries/ld_so_cache
sos_commands/libvirt/ls_-lR_.var.lib.libvirt.qemu
sos_commands/logrotate/logrotate_debug
sos_commands/md/mdadm_-D_.dev.md
sos_commands/memory/free
sos_commands/memory/free_-m
sos_commands/memory/lsmem_-a_-o_RANGE_SIZE_STATE_REMOVABLE_ZONES_NODE_BLOCK
sos_commands/memory/swapon_--bytes_--show
sos_commands/memory/swapon_--summary_--verbose
sos_commands/multipath/multipathd_show_config
sos_commands/multipath/multipath_-ll
sos_commands/multipath/multipath_-t
sos_commands/multipath/multipath_-v4_-ll
sos_commands/networking/biosdevname_-d
sos_commands/networking/bridge_-d_vlan_show
sos_commands/networking/bridge_-s_-s_-d_link_show
sos_commands/networking/bridge_-s_-s_-d_-t_fdb_show
sos_commands/networking/bridge_-s_-s_-d_-t_mdb_show
sos_commands/networking/ifenslave_-a
sos_commands/networking/ip_-4_rule
sos_commands/networking/ip_-6_route_show_table_all
sos_commands/networking/ip_-6_rule
sos_commands/networking/ip_maddr_show
sos_commands/networking/ip_mroute_show
sos_commands/networking/ip_netns
sos_commands/networking/ip_-o_addr
sos_commands/networking/ip_-s_-s_neigh_show
sos_commands/networking/netstat_-s
sos_commands/networking/plotnetcfg
sos_commands/networking/tc_-s_qdisc_show
sos_commands/networkmanager/nmcli_con
sos_commands/networkmanager/nmcli_con_show_--active
sos_commands/networkmanager/nmcli_dev
sos_commands/networkmanager/nmcli_general_status
sos_commands/networkmanager/rpm_-V_NetworkManager
sos_commands/nis/domainname
sos_commands/nss/rpm_-V_nss-tools_nss-sysinit_nss-util_nss-softokn_nss_nss-pem_nss-softokn-freebl
sos_commands/openshift/oo-diagnostics_-v
sos_commands/openssl/rpm_-V_openssl_openssl-libs
sos_commands/pam/faillock
sos_commands/pam/pam_tally2
sos_commands/pci/lspci_-tv
sos_commands/perl/perl_-V
sos_commands/perl/rpm_-V_perl-parent_perl-File-Temp_perl-Text-ParseWords_perl-Scalar-List-Utils_perl-Encode_perl-Data-Dumper_perl-libs_perl_perl-Compress-Raw-Zlib_perl-Digest_perl-constant_perl-Git_perl-Time-HiRes_perl-threads_perl-Time-Local_perl-Pod-Usage_perl-Getopt-Lon
sos_commands/podman/ls_-alhR_.etc.cni
sos_commands/podman/podman_images
sos_commands/podman/podman_info
sos_commands/podman/podman_pod_ps
sos_commands/podman/podman_pod_ps_-a
sos_commands/podman/podman_port_--all
sos_commands/podman/podman_ps
sos_commands/podman/podman_ps_-a
sos_commands/podman/podman_stats_--no-stream_--all
sos_commands/podman/podman_version
sos_commands/podman/podman_volume_ls
sos_commands/postfix/mailq
sos_commands/postfix/postconf
sos_commands/postfix/rpm_-V_postfix
sos_commands/postgresql/rpm_-V_postgresql
sos_commands/processor/cpufreq-info
sos_commands/processor/cpuid
sos_commands/processor/cpuid_-r
sos_commands/processor/cpupower_frequency-info
sos_commands/processor/cpupower_idle-info
sos_commands/processor/cpupower_info
sos_commands/processor/lscpu
sos_commands/processor/turbostat_--debug_sleep_10
sos_commands/processor/x86info_-a
sos_commands/process/ps_alxwww
sos_commands/process/ps_auxwwwm
sos_commands/process/ps_axo_flags_state_uid_pid_ppid_pgid_sid_cls_pri_addr_sz_wchan_lstart_tty_time_cmd
sos_commands/process/ps_axo_pid_ppid_user_group_lwp_nlwp_start_time_comm_cgroup
sos_commands/process/pstree
sos_commands/pulp/mongo-collection_sizes
sos_commands/pulp/mongo-db_stats
sos_commands/pulp/mongo-reserved_resources
sos_commands/pulp/mongo-task_status
sos_commands/pulp/pulp-running_tasks
sos_commands/pulp/rpm_-V_pulp-server_pulp-katello
sos_commands/puppet/rpm_-V_puppetserver
sos_commands/python/python2_-V
sos_commands/python/python3_-V
sos_commands/python/python-version
sos_commands/python/rpm_-V_python
sos_commands/qpid_dispatch/qdstat_-a
sos_commands/qpid_dispatch/qdstat_-c
sos_commands/qpid_dispatch/qdstat_-m
sos_commands/qpid_dispatch/qdstat_-n
sos_commands/qpid_dispatch/rpm_-V_qpid-dispatch-router
sos_commands/qpid/ls_-lanR_.var.lib.qpidd
sos_commands/qpid/qpid-cluster
sos_commands/qpid/qpid-config_exchanges
sos_commands/qpid/qpid-config_exchanges_-b
sos_commands/qpid/qpid-config_exchanges_-r
sos_commands/qpid/qpid-config_queues
sos_commands/qpid/qpid-config_queues_-b
sos_commands/qpid/qpid-config_queues_-r
sos_commands/qpid/qpid-ha_query
sos_commands/qpid/qpid-route_link_list
sos_commands/qpid/qpid-route_route_list
sos_commands/qpid/qpid-stat_-b
sos_commands/qpid/qpid-stat_-c
sos_commands/qpid/qpid-stat_-e
sos_commands/qpid/qpid-stat_-g
sos_commands/qpid/qpid-stat_-m
sos_commands/qpid/qpid-stat_-q
sos_commands/qpid/qpid-stat_-u
sos_commands/qpid/rpm_-V_qpid-cpp-server_qpid-tools
sos_commands/release/lsb_release
sos_commands/release/lsb_release_-a
sos_commands/rpm/lsof_D_var_lib_rpm
sos_commands/rpm/package-data
sos_commands/rpm/rpm_-V_rpm-build_rpm-python_rpm-libs_rpm_rpm-build-libs
sos_commands/ruby/gem_list
sos_commands/ruby/gem_--version
sos_commands/ruby/irb_--version
sos_commands/ruby/rpm_-V_ruby_ruby-irb
sos_commands/ruby/ruby_--version
sos_commands/satellite/ls_-lanR_.root.ssl-build
sos_commands/scsi/lsscsi
sos_commands/scsi/sg_map_-x
sos_commands/selinux/ps_auxZww
sos_commands/selinux/selinuxconlist_root
sos_commands/selinux/selinuxdefcon_root
sos_commands/selinux/selinuxexeccon_.bin.passwd
sos_commands/selinux/semanage_interface_-l
sos_commands/selinux/semanage_login_-l
sos_commands/selinux/semanage_module_-l
sos_commands/selinux/semanage_node_-l
sos_commands/selinux/semanage_-o
sos_commands/selinux/semanage_port_-l
sos_commands/selinux/semanage_user_-l
sos_commands/selinux/sestatus
sos_commands/selinux/sestatus_-b
sos_commands/selinux/sestatus_-v
sos_commands/services/chkconfig_--list
sos_commands/services/ls_.var.lock.subsys
sos_commands/services/runlevel
sos_commands/soundcard/amixer
sos_commands/soundcard/aplay_-l
sos_commands/soundcard/aplay_-L
sos_commands/squid/rpm_-V_squid
sos_commands/subscription_manager/rct_cat-cert_.etc.pki.product-default.69.pem
sos_commands/subscription_manager/rpm_-V_subscription-manager
sos_commands/subscription_manager/subscription-manager_identity
sos_commands/subscription_manager/subscription-manager_list_--consumed
sos_commands/subscription_manager/subscription-manager_list_--installed
sos_commands/subscription_manager/syspurpose_show
sos_commands/systemd/journalctl_--list-boots
sos_commands/systemd/journalctl_--verify
sos_commands/systemd/ls_-lR_.lib.systemd
sos_commands/systemd/rpm_-V_systemd
sos_commands/systemd/systemctl_list-dependencies
sos_commands/systemd/systemctl_list-jobs
sos_commands/systemd/systemctl_list-machines
sos_commands/systemd/systemctl_list-timers_--all
sos_commands/systemd/systemctl_list-unit-files
sos_commands/systemd/systemctl_list-units
sos_commands/systemd/systemctl_list-units_--failed
sos_commands/systemd/systemctl_show_--all
sos_commands/systemd/systemctl_show-environment
sos_commands/systemd/systemctl_show_service_--all
sos_commands/systemd/systemctl_status_--all
sos_commands/systemd/systemd-analyze
sos_commands/systemd/systemd-analyze_blame
sos_commands/systemd/systemd-analyze_dump
sos_commands/systemd/systemd-analyze_plot.svg
sos_commands/systemd/systemd-delta
sos_commands/systemd/systemd-resolve_--statistics
sos_commands/systemd/systemd-resolve_--status
sos_commands/systemd/timedatectl
sos_commands/system/rpm_-V_glibc-common_glibc_initscripts_zlib
sos_commands/sysvipc/ipcs
sos_commands/sysvipc/ipcs_-u
sos_commands/teamd/rpm_-V_teamd
sos_commands/tftpserver/ls_-lanR_.srv.tftp
sos_commands/tftpserver/rpm_-V_tftp-server
sos_commands/tomcat/rpm_-V_tomcat
sos_commands/tuned/rpm_-V_tuned
sos_commands/tuned/tuned-adm_active
sos_commands/tuned/tuned-adm_list
sos_commands/tuned/tuned-adm_recommend
sos_commands/tuned/tuned-adm_verify
sos_commands/usb/lsusb
sos_commands/usb/lsusb_-t
sos_commands/usb/lsusb_-v
sos_commands/vhostmd/rpm_-V_virt-what
sos_commands/x11/xrandr_--verbose
sos_commands/xfs/xfs_admin_-l_-u_.dev.mapper.rhel_denjht1-root
sos_commands/xfs/xfs_info
sos_commands/xfs/xfs_info_.boot
sos_commands/xinetd/rpm_-V_xinetd
sos_commands/yum/package-cleanup_--dupes
sos_commands/yum/package-cleanup_--problems
sos_commands/yum/plugin-packages
sos_commands/yum/rpm_-V_yum-rhn-plugin_yum-utils_yum-metadata-parser_yum
sos_commands/yum/yum_-C_repolist
sos_commands/yum/yum_history
sos_commands/yum/yum_list_installed
sos_commands/zfs/zfs_get_all
sos_commands/zfs/zfs_list_-t_all_-o_space
sos_commands/zfs/zpool_list
sos_commands/zfs/zpool_status_-vx
sos_commands/abrt/abrt-log
sos_commands/autofs/etc.init.d.autofs_status
sos_commands/cups/lpstat_-d
sos_commands/cups/lpstat_-s
sos_commands/cups/lpstat_-t
sos_commands/dmraid/dmraid_-b
sos_commands/dmraid/dmraid_-r
sos_commands/dmraid/dmraid_-s
sos_commands/dmraid/dmraid_-tay
sos_commands/dmraid/dmraid_-V
sos_commands/ipa/certutil_-L_-d_.etc.httpd.alias
sos_commands/ipa/certutil_-L_-d_.var.lib.pki-ca.alias
sos_commands/ipa/getcert_list
sos_commands/ipa/klist_-ket_.etc.dirsrv.ds.keytab
sos_commands/ipa/klist_-ket_.etc.httpd.conf.ipa.keytab
sos_commands/ipa/ls_-la_.etc.dirsrv.slapd-_.schema
sos_commands/keyutils/keyctl_show
sos_commands/networking/ip6tables_-t_filter_-nvL
sos_commands/networking/ip6tables_-vnxL
sos_commands/ntp/ntpstat
sos_commands/ntp/ntptime
sos_commands/numa/numactl_--hardware
sos_commands/numa/numactl_--show
sos_commands/numa/numastat
sos_commands/numa/numastat_-m
sos_commands/numa/numastat_-n
sos_commands/pci/lspci
sos_commands/samba/testparm_-s_-v
sos_commands/samba/wbinfo_--domain_._-g
sos_commands/samba/wbinfo_--domain_._-u
sos_commands/sunrpc/rpcinfo_-p_localhost
sos_commands/systemtap/stap-report
sos_commands/systemtap/uname_-r
sos_commands/upstart/initctl_--system_list
sos_commands/upstart/initctl_--system_version
sos_commands/upstart/init_--version
sos_commands/upstart/ls_-l_.etc.init
sos_commands/autofs/chkconfig_--list_autofs
sos_commands/autofs/egrep_-e_automount_pid._nfs_.proc.mounts
sos_commands/autofs/mount_egrep_-e_automount_pid._nfs
sos_commands/autofs/ps_auxwww_grep_automount
sos_commands/autofs/rpm_-qV_autofs
sos_commands/bootloader/ls_-laR_.boot
sos_commands/crontab/users_crontabs
sos_commands/dmraid/dmraid_-rD
sos_commands/dmraid/ls_-laR_.dev
sos_commands/dmraid/ls_-laR_.sys.block
sos_commands/dmraid/lvs_-a_-o_devices_--config_global_locking_type_0
sos_commands/dmraid/mdadm_-D_.dev.md
sos_commands/dmraid/multipath_-v4_-ll
sos_commands/dmraid/pvs_-a_-v_--config_global_locking_type_0
sos_commands/dmraid/pvscan_-v_--config_global_locking_type_0
sos_commands/dmraid/systool_-v_-c_-b_scsi
sos_commands/dmraid/udevinfo_-ap_.sys.block.md0
sos_commands/dmraid/udevinfo_-ap_.sys.block.sr0
sos_commands/dmraid/vgdisplay_-vv_--config_global_locking_type_0
sos_commands/dmraid/vgscan_-vvv_--config_global_locking_type_0
sos_commands/dmraid/vgs_-v_--config_global_locking_type_0
sos_commands/emc/powermt_version
sos_commands/emc/usr.symcli.bin.stordaemon_list
sos_commands/emc/usr.symcli.bin.stordaemon_-v_list
sos_commands/emc/usr.symcli.bin.symbcv_list
sos_commands/emc/usr.symcli.bin.symbcv_-v_list
sos_commands/emc/usr.symcli.bin.symcfg_-app_-v_list
sos_commands/emc/usr.symcli.bin.symcfg_-connections_list
sos_commands/emc/usr.symcli.bin.symcfg_-db
sos_commands/emc/usr.symcli.bin.symcfg_-dir_all_-v_list
sos_commands/emc/usr.symcli.bin.symcfg_-fa_all_-port_list
sos_commands/emc/usr.symcli.bin.symcfg_list
sos_commands/emc/usr.symcli.bin.symcfg_list_-lock
sos_commands/emc/usr.symcli.bin.symcfg_list_-lockn_all
sos_commands/emc/usr.symcli.bin.symcfg_-ra_all_-port_list
sos_commands/emc/usr.symcli.bin.symcfg_-sa_all_-port_list
sos_commands/emc/usr.symcli.bin.symcfg_-semaphores_list
sos_commands/emc/usr.symcli.bin.symcfg_-v_list
sos_commands/emc/usr.symcli.bin.symcg_list
sos_commands/emc/usr.symcli.bin.symcg_-v_list
sos_commands/emc/usr.symcli.bin.symcli_-def
sos_commands/emc/usr.symcli.bin.symclone_list
sos_commands/emc/usr.symcli.bin.symdev_list
sos_commands/emc/usr.symcli.bin.symdev_-rdfa_list
sos_commands/emc/usr.symcli.bin.symdev_-rdfa_-v_list
sos_commands/emc/usr.symcli.bin.symdev_-v_list
sos_commands/emc/usr.symcli.bin.symdg_list
sos_commands/emc/usr.symcli.bin.symdg_-v_list
sos_commands/emc/usr.symcli.bin.symevent_list
sos_commands/emc/usr.symcli.bin.symhost_show_-config
sos_commands/emc/usr.symcli.bin.syminq
sos_commands/emc/usr.symcli.bin.syminq_hba_-fibre
sos_commands/emc/usr.symcli.bin.syminq_hba_-scsi
sos_commands/emc/usr.symcli.bin.syminq_-symmids
sos_commands/emc/usr.symcli.bin.syminq_-v
sos_commands/emc/usr.symcli.bin.symmaskdb_list_database
sos_commands/emc/usr.symcli.bin.symmaskdb_-v_list_database
sos_commands/emc/usr.symcli.bin.symmask_list_hba
sos_commands/emc/usr.symcli.bin.symmask_list_logins
sos_commands/emc/usr.symcli.bin.sympd_list
sos_commands/emc/usr.symcli.bin.sympd_list_-vcm
sos_commands/emc/usr.symcli.bin.symrdf_list
sos_commands/emc/usr.symcli.bin.symrdf_-rdfa_list
sos_commands/emc/usr.symcli.bin.symrdf_-rdfa_-v_list
sos_commands/emc/usr.symcli.bin.symrdf_-v_list
sos_commands/emc/usr.symcli.bin.symsnap_list
sos_commands/emc/usr.symcli.bin.symsnap_list_-savedevs
sos_commands/general/dmesg_now
sos_commands/general/tail_sa01
sos_commands/hardware/dmesg_.bin.egrep_3c359_3c59x_3w-9xxx_3w-sas_3w-xxxx_8139cp_8139t
sos_commands/hardware/lshal
sos_commands/libraries/ldconfig_-v
sos_commands/logrotate/logrotate_status
sos_commands/networking/ip_link
sos_commands/nfsserver/nfsstat
sos_commands/nfsserver/rpcinfo_-p_localhost
sos_commands/ntp/ntptrace
sos_commands/rpm/rpm_-Va
sos_commands/selinux/rpm_-q_-V_selinux-policy-strict
sos_commands/selinux/rpm_-q_-V_selinux-policy-targeted
sos_commands/selinux/sestatus_-vb
sos_commands/smartcard/ls_-l_.usr.lib.pam_pkcs11
sos_commands/smartcard/pkcs11_inspect_debug
sos_commands/smartcard/pklogin_finder_debug
sos_commands/soundcard/lspci_grep_-i_audio
sos_commands/soundcard/sndmodules_loaded
sos_commands/startup/service_--status-all
sos_commands/systemtap/rpm_-qa_.bin.egrep_-e_kernel._uname_-r_-e_systemtap_-e_elfutils_
sos_commands/x11/dmesg_grep_-e_agpgart
ifconfig,ifconfig_-a
chkconfig,chkconfig_--list
date,date_--utc
df,df_-al,df_-ali,df_-al_-x_autofs,df_-ali_-x_autofs,diskinfo
dmidecode
hostname,hostname_-f
ip_addr,ip_address,ip_a
last
lsb_release
lsmod
lsof,lsof_-b_M_-n_-l,lsof_-b_M_-n_-l_-c
lspci,lspci_-nvv,lspci_-nnvv
mount,mount_-l
netstat,netstat_-W_-neopa,netstat_-neopa
ps,ps_auxwww,ps_auxwwwm,ps_auxww,ps_auxww,ps_-elfL,ps_-elf,ps_axo_flags_state_uid_pid_ppid_pgid_sid_cls_pri_addr_sz_wchan_lstart_tty_time_cmd,ps_axo_pid_ppid_user_group_lwp_nlwp_start_time_comm_cgroup
pstree
route,route_-n
uname,uname_-a
uptime
vgdisplay,vgdisplay_-vv_--config_global_locking_type_0
database-character-sets,rhn-charsets
database-schema-version,rhn-schema-version"


# The consolidate_differences function looks for files that are expected by our tools if they don't appear in the expected locations.  This can increase the utility of old sosreports and related files.

consolidate_differences()
{

  # create a few basic links

  if [ ! -f $base_dir/version.txt ]; then touch $base_dir/version.txt; fi

  if [ -d $base_dir/usr/lib ] && [ ! -f $base_dir/lib ]; then ln -s usr/lib $base_dir/lib 2>/dev/null; fi

  #mkdir -p $base_dir/sos_commands/foreman/foreman-debug 2>/dev/null


  # this section handles spacewalk-debug files

  if [ -d $base_dir/conf ]; then

        mkdir -p $base_dir/var/log
        ln -s conf $base_dir/etc 2>/dev/null

        if [ -d $base_dir/conf/tomcat/tomcat6 ]; then ln -s tomcat/tomcat6 $base_dir/conf/tomcat6 2>/dev/null; fi

        if [ -d $base_dir/httpd-logs/httpd ]; then ln -s ../../httpd-logs/httpd $base_dir/var/log/httpd 2>/dev/null; fi
        if [ -d $base_dir/tomcat-logs/tomcat6 ]; then ln -s ../../tomcat-logs/tomcat6 $base_dir/var/log/tomcat6 2>/dev/null; fi
        if [ -d $base_dir/rhn-logs/rhn ]; then ln -s ../../rhn-logs/rhn $base_dir/var/log/rhn 2>/dev/null; fi
        if [ -d $base_dir/cobbler-logs ]; then ln -s ../../cobbler-logs $base_dir/var/log/cobbler 2>/dev/null; fi
        if [ -d $base_dir/audit-log ]; then ln -s ../../audit-log i$base_dir/var/log/audit 2>/dev/null; fi
        if [ -d $base_dir/schema-upgrade-logs ]; then ln -s ../../../schema-upgrade-logs $base_dir/var/log/spacewalk/schema-upgrade 2>/dev/null; fi

        #mkdir -p $base_dir/sos_commands/foreman/foreman-debug

    	if [ -d $base_dir/containers ]; then
    		mkdir -p $base_dir/sos_commands/podman
    		if [ -f $base_dir/containers/ps ]; then ln -s ../../containers/ps $base_dir/sos_commands/podman/podman_ps 2>/dev/null; fi
    	fi

  fi


  # this section links directories together to ensure that scripts can find their content

  #if [ -d $base_dir/etc ]; then ln -s ../../../etc $base_dir/sos_commands/foreman/foreman-debug/etc 2>/dev/null; fi
  #if [ -d $base_dir/usr ]; then ln -s ../../../usr $base_dir/sos_commands/foreman/foreman-debug/usr 2>/dev/null; fi
  #if [ -d $base_dir/var ]; then ln -s ../../../var $base_dir/sos_commands/foreman/foreman-debug/var 2>/dev/null; fi

  if [ -d $base_dir/sos_commands/dmraid ] && [ ! -d $base_dir/sos_commands/devicemapper ]; then ln -s dmraid $base_dir/sos_commands/devicemapper 2>/dev/null; fi
  if [ -d $base_dir/sos_commands/lsbrelease ]; then ln -s lsbrelease $base_dir/sos_commands/release 2>/dev/null; fi
  if [ -d $base_dir/sos_commands/printing ]; then ln -s printing $base_dir/sos_commands/cups 2>/dev/null; fi


  # this section populates the sos_commands directory and various links in the root directory of the sosreport

   for MYENTRY in `echo -e "$CSVLINKS"`; do
	MYARRAY=()
	for i in "`echo $MYENTRY | tr ',' '\n'`"; do
		MYARRAY+=($i)
	done

	count=0
	MYDIR=""
	MYFILE=""
	MATCH=""
	for i in "${MYARRAY[@]}"; do
		let count=$count+1

		if [ "$count" -eq 1 ]; then

			# this section finds and links the preferred file names

			MYDIR=`dirname $i`
			MYFILE=`basename $i`

			MATCH=`find $base_dir -type f -name $MYFILE 2>/dev/null | egrep -v '\./containers/ps'`	# containers/ps contains podman processes, not normal processes

			if [ -f "$MATCH" ] && [ ! -L "$MATCH" ] && [ ! -f "$i" ]; then
				mkdir -p $base_dir/$MYDIR
				ln -s -r $MATCH $base_dir/$i 2>/dev/null
				break	# if we found the preferred file, break regardless of whether or not the link operation works
			fi
		else

			# this section finds and links older file names

			MATCH=`find $base_dir -type f -name $i 2>/dev/null`
			LINKTARGET=`echo $MYDIR/$MYFILE`

			if [ -f "$MATCH" ] && [ ! -L "$MATCH" ] && [ ! -f "$LINKTARGET" ]; then
				mkdir -p $base_dir/$MYDIR
				ln -s -r $MATCH $base_dir/$LINKTARGET 2>/dev/null
				break	# if the first attempt fails, so will subsequent finds; we might as well break here
			fi

		fi


	done
  done
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
  log "cat $base_dir/dmidecode | grep -E '(Vendor|Manufacture)' | head -n3"
  log "---"
  log_cmd "cat $base_dir/dmidecode | grep -E '(Vendor|Manufacture)' | head -n3"
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
  log "grep setroubleshoot $base_dir/installed-rpms"
  log "---"
  log_cmd "grep setroubleshoot $base_dir/installed-rpms"
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

  log "// installed katello-agent and/or gofer"
  log "grep -E '(^katello-agent|^gofer)' $base_dir/installed-rpms"
  log "---"
  log_cmd "grep -E '(^katello-agent|^gofer)' $base_dir/installed-rpms"
  log "---"
  log

  log "// goferd service"
  log "grep -E '(^katello-agent|^gofer)' $base_dir/installed-rpms"
  log "cat $base_dir/sos_commands/systemd/systemctl_list-units | grep goferd"
  log "---"
  log_cmd "cat $base_dir/sos_commands/systemd/systemctl_list-units | grep goferd"
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
    cmd="grep \"Running installer with args\" $base_dir/sos_commands/foreman/foreman-debug/var/log/foreman-installer/satellite.log"
  else
    cmd="grep \"Running installer with args\" $base_dir/var/log/foreman-installer/satellite.log"
  fi

  log "$cmd"
  log "---"
  log_cmd "$cmd"
  log "---"
  log


  log "// All the flags used with satellite-installer"

  if [ "$sos_version" == "old" ];then
    cmd="grep \"Running installer with args\" $base_dir/sos_commands/foreman/foreman-debug/var/log/foreman-installer/satellite.* | sort -rk3 | cut -d: -f2-"
  else
    cmd="grep \"Running installer with args\" $base_dir/var/log/foreman-installer/satellite.* | sort -rk3 | cut -d: -f2-"
  fi

  log "$cmd"
  log "---"
  log_cmd "$cmd"
  log "---"
  log




  log "// # of error on the upgrade file"

  if [ "$sos_version" == "old" ];then
    cmd="grep '^\[ERROR' $base_dir/sos_commands/foreman/foreman-debug/var/log/foreman-installer/satellite.log | wc -l"
  else
    cmd="grep '^\[ERROR' $base_dir/var/log/foreman-installer/satellite.log | wc -l"
  fi

  log "$cmd"
  log "---"
  log_cmd "$cmd"
  log "---"
  log


  log "// Error on the upgrade file (full info)"

  if [ "$sos_version" == "old" ];then
    cmd="grep '^\[ERROR' $base_dir/sos_commands/foreman/foreman-debug/var/log/foreman-installer/satellite.log"
  else
    cmd="grep '^\[ERROR' $base_dir/var/log/foreman-installer/satellite.log"
  fi

  log "$cmd"
  log "---"
  log_cmd "$cmd"
  log "---"
  log

  log "// Upgrade Completed? (6.4 or greater)"

  if [ "$sos_version" == "old" ];then
    cmd="grep \"Upgrade completed\" $base_dir/sos_commands/foreman/foreman-debug/var/log/foreman-installer/satellite.log | wc -l"
  else
    cmd="grep \"Upgrade completed\" $base_dir/var/log/foreman-installer/satellite.log | wc -l"
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
  log "grep -h -r \"No space left on device\" $base_dir/* 2>/dev/null"
  log "---"
  log_cmd "grep -h -r \"No space left on device\" $base_dir/* 2>/dev/null"
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
  log "cat $base_dir/ps | sort -nr | awk '{print \$1, \$6}' | grep -v ^USER | grep -v ^COMMAND | grep -v \"^ $\" | awk  '{a[\$1] += \$2} END{for (i in a) print i, a[i]}' | sort -nrk2"
  log "and"
  log "memory_usage=\$(cat $base_dir/ps | sort -nr | awk '{print \$6}' | grep -v ^RSS | grep -v ^$ | paste -s -d+ | bc)"
  log "and"
  log "memory_usage_gb=\$(echo \"scale=2;$memory_usage/1024/1024\" | bc)"
  log "---"
  log_cmd "cat $base_dir/ps | sort -nr | awk '{print \$1, \$6}' | grep -v ^USER | grep -v ^COMMAND | grep -v \"^ $\" | awk  '{a[\$1] += \$2} END{for (i in a) print i, a[i]}' | sort -nrk2"
  log
  memory_usage=$(cat $base_dir/ps | sort -nr | awk '{print $6}' | grep -v ^RSS | grep -v ^$ | paste -s -d+ | bc)
  memory_usage_gb=$(echo "scale=2;$memory_usage/1024/1024" | bc)
  log "Total Memory Consumed in KiB: $memory_usage"
  log "Total Memory Consumed in GiB: $memory_usage_gb"
  log "---"
  log

  log "// Postgres idle process (candlepin)"
  log "cat $base_dir/ps | grep ^postgres | grep idle$ | grep \"candlepin candlepin\" | wc -l"
  log "---"
  log_cmd "cat $base_dir/ps | grep ^postgres | grep idle$ | grep \"candlepin candlepin\" | wc -l"
  log "---"
  log

  log "// Postgres idle process (foreman)"
  log "cat $base_dir/ps | grep ^postgres | grep idle$ | grep \"foreman foreman\" | wc -l"
  log "---"
  log_cmd "cat $base_dir/ps | grep ^postgres | grep idle$ | grep \"foreman foreman\" | wc -l"
  log "---"
  log

  log "// Postgres idle process (everything)"
  log "cat $base_dir/ps | grep ^postgres | grep idle$ | wc -l"
  log "---"
  log_cmd "cat $base_dir/ps | grep ^postgres | grep idle$ | wc -l"
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
    cmd="cat $base_dir/sos_commands/foreman/foreman-debug/foreman_tasks_tasks.csv | cut -d, -f3 | grep Actions | sort | uniq -c | sort -nr"
  else
    cmd="cat $base_dir/sos_commands/foreman/foreman_tasks_tasks | sed '1,3d' | cut -d\| -f3 | grep Actions | sort | uniq -c | sort -nr"
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
  log "grep -E '(^                  id|paused)' $base_dir/sos_commands/foreman/foreman_tasks_tasks | sed 's/  //g' | sed -e 's/ |/|/g' | sed -e 's/| /|/g' | sed -e 's/^ //g' | sed -e 's/|/,/g'"
  log "---"
  log_cmd "grep -E '(^                  id|paused)' $base_dir/sos_commands/foreman/foreman_tasks_tasks | sed 's/  //g' | sed -e 's/ |/|/g' | sed -e 's/| /|/g' | sed -e 's/^ //g' | sed -e 's/|/,/g'"
  log "---"
  log



  log_tee "## Pulp"
  log

  log "// number of tasks not finished"
  log "grep '\"task_id\"' $base_dir/sos_commands/pulp/pulp-running_tasks | wc -l"
  log "---"
  log_cmd "grep '\"task_id\"' $base_dir/sos_commands/pulp/pulp-running_tasks | wc -l"
  log "---"
  log


#grep "\"task_id\"" 02681559/0050-sosreport-pc1ustsxrhs06-2020-06-26-kfmgbpf.tar.xz/sosreport-pc1ustsxrhs06-2020-06-26-kfmgbpf/sos_commands/pulp/pulp-running_tasks | wc -l

  log "// pulp task not finished"
  log "grep -E '(\"finish_time\" : null|\"start_time\"|\"state\"|\"pulp:|^})' $base_dir/sos_commands/pulp/pulp-running_tasks"
  log "---"
  log_cmd "grep -E '(\"finish_time\" : null|\"start_time\"|\"state\"|\"pulp:|^})' $base_dir/sos_commands/pulp/pulp-running_tasks"
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
    cmd="grep -E '(^\*|Active)' $base_dir/sos_commands/foreman/foreman-debug/katello_service_status | tr '^\*' '\n'"
  else
    cmd="grep -E '(^\*|Active)' $base_dir/sos_commands/foreman/foreman-maintain_service_status | tr '^\*' '\n'"
  fi

  log "$cmd"
  log "---"
  log_cmd "$cmd"
  log "---"
  log


  log_tee "## Puppet Server"
  log

  log "// Puppet Server Error"
  log "grep ERROR $base_dir/var/log/puppetlabs/puppetserver/puppetserver.log"
  log "---"
  log_cmd "grep ERROR $base_dir/var/log/puppetlabs/puppetserver/puppetserver.log"
  log "---"
  log


  log_tee "## Audit"
  log

  log "// denied in audit.log"
  log "grep -o denied.* $base_dir/var/log/audit/audit.log  | sort -u"
  log "---"
  log_cmd "grep -o denied.* $base_dir/var/log/audit/audit.log  | sort -u"
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


  log_tee "## PostgreSQL Storage"
  log

  log "// postgres storage consumption"

  if [ "$sos_version" == "old" ];then
    cmd="cat $base_dir/sos_commands/foreman/foreman-debug/postgres_disk_space"
  else
    cmd="cat $base_dir/sos_commands/postgresql/du_-sh_.var.lib.pgsql"
  fi

  log "$cmd"
  log "---"
  log_cmd "$cmd"
  log "---"
  log


  log "// TOP foreman tables consumption"
  log "head -n30 $base_dir/sos_commands/katello/db_table_size"
  log "---"
  log_cmd "head -n30 $base_dir/sos_commands/katello/db_table_size"
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
    cmd="cat $base_dir/sos_commands/foreman/foreman-debug/passenger_status_requests | grep uri | sort -k3 | uniq -c"
  else
    cmd="cat $base_dir/sos_commands/foreman/passenger-status_--show_requests | grep uri | sort -k3 | uniq -c"
  fi

  log "$cmd"
  log "---"
  log_cmd "$cmd"
  log "---"
  log


  log_tee "## Foreman Tasks"
  log

  log "// dynflow running"
  log "cat $base_dir/ps | grep dynflow_executor\$"
  log "---"
  log_cmd "cat $base_dir/ps | grep dynflow_executor$"
  log "---"
  log



  log_tee "## Qpidd"
  log

  if [ -f $base_dir/sos_commands/katello/qpid-stat_-q_--ssl-certificate_.etc.pki.pulp.qpid.client.crt_-b_amqps_..localhost_5671 ]; then
    qpid_filename="qpid-stat_-q_--ssl-certificate_.etc.pki.pulp.qpid.client.crt_-b_amqps_..localhost_5671"
  fi
  if [ -f $base_dir/sos_commands/katello/qpid-stat_-q_--ssl-certificate_.etc.pki.katello.qpid_client_striped.crt_-b_amqps_..localhost_5671 ]; then
    qpid_filename="qpid-stat_-q_--ssl-certificate_.etc.pki.katello.qpid_client_striped.crt_-b_amqps_..localhost_5671"
  fi

  log "// katello_event_queue (foreman-tasks / dynflow is running?)"

  if [ "$sos_version" == "old" ];then
    cmd="grep -E '(  queue|  ===|katello_event_queue)' $base_dir/sos_commands/foreman/foreman-debug/qpid-stat-q"
  else
    cmd="grep -E '(  queue|  ===|katello_event_queue)' $base_dir/sos_commands/katello/$qpid_filename"
  fi

  log "$cmd"
  log "---"
  log_cmd "$cmd"
  log "---"
  log


  log "// total number of pulp agents"

  if [ "$sos_version" == "old" ];then
    cmd="cat $base_dir/sos_commands/foreman/foreman-debug/qpid-stat-q | grep pulp.agent | wc -l"
  else
    cmd="cat $base_dir/sos_commands/katello/$qpid_filename | grep pulp.agent | wc -l"
  fi

  log "$cmd"
  log "---"
  log_cmd "$cmd"
  log "---"
  log

  log "// total number of (active) pulp agents"

  if [ "$sos_version" == "old" ];then
    cmd="cat $base_dir/sos_commands/foreman/foreman-debug/qpid-stat-q | grep pulp.agent | grep \" 1.*1\$\" | wc -l"
  else
    cmd="cat $base_dir/sos_commands/katello/$qpid_filename | grep pulp.agent | grep \" 1.*1\$\" | wc -l"
  fi

  log "$cmd"
  log "---"
  log_cmd "$cmd"
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


  log_tee "## Httpd"
  log

  log "// queues on error_log means the # of requests crossed the border. Satellite inaccessible"
  log "grep 'Request queue is full' $base_foreman/var/log/httpd/error_log | wc -l"
  log "---"
  log_cmd "grep 'Request queue is full' $base_foreman/var/log/httpd/error_log | wc -l"
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


  log "// General 2XX errors on httpd logs"
  log "grep -P '\" 2\d\d ' $base_foreman/var/log/httpd/foreman-ssl_access_ssl.log | awk '{print \$9}' | sort | uniq -c | sort -nr"
  log "---"
  log_cmd "grep -P '\" 2\d\d ' $base_foreman/var/log/httpd/foreman-ssl_access_ssl.log | awk '{print \$9}' | sort | uniq -c | sort -nr"
  log "---"
  log

  log "// General 3XX errors on httpd logs"
  log "grep -P '\" 3\d\d ' $base_foreman/var/log/httpd/foreman-ssl_access_ssl.log | awk '{print \$9}' | sort | uniq -c | sort -nr"
  log "---"
  log_cmd "grep -P '\" 3\d\d ' $base_foreman/var/log/httpd/foreman-ssl_access_ssl.log | awk '{print \$9}' | sort | uniq -c | sort -nr"
  log "---"
  log

  log "// General 4XX errors on httpd logs"
  log "grep -P '\" 4\d\d ' $base_foreman/var/log/httpd/foreman-ssl_access_ssl.log | awk '{print \$9}' | sort | uniq -c | sort -nr"
  log "---"
  log_cmd "grep -P '\" 4\d\d ' $base_foreman/var/log/httpd/foreman-ssl_access_ssl.log | awk '{print \$9}' | sort | uniq -c | sort -nr"
  log "---"
  log

  log "// General 5XX errors on httpd logs"
  log "grep -P '\" 5\d\d ' $base_foreman/var/log/httpd/foreman-ssl_access_ssl.log | awk '{print \$9}' | sort | uniq -c | sort -nr"
  log "---"
  log_cmd "grep -P '\" 5\d\d ' $base_foreman/var/log/httpd/foreman-ssl_access_ssl.log | awk '{print \$9}' | sort | uniq -c | sort -nr"
  log "---"
  log




  log_tee "## RHSM"
  log

  log "// RHSM Proxy"
  log "grep proxy $base_dir/etc/rhsm/rhsm.conf | grep -v ^#"
  log "---"
  log_cmd "grep proxy $base_dir/etc/rhsm/rhsm.conf | grep -v ^#"
  log "---"
  log

  log "// Satellite Proxy"
  log "grep -E '(^  proxy_url|^  proxy_port|^  proxy_username|^  proxy_password)' $base_dir/etc/foreman-installer/scenarios.d/satellite-answers.yaml"
  log "---"
  log_cmd "grep -E '(^  proxy_url|^  proxy_port|^  proxy_username|^  proxy_password)' $base_dir/etc/foreman-installer/scenarios.d/satellite-answers.yaml"
  log "---"
  log

  log "// Virt-who Proxy"
  log "grep -i proxy $base_dir/etc/sysconfig/virt-who"
  log "---"
  log_cmd "grep -i proxy $base_dir/etc/sysconfig/virt-who"
  log "---"
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

  log "// duplicated hypervisors #"
  log "grep \"is assigned to 2 different systems\" $base_dir/var/log/rhsm/rhsm.log | awk '{print \$9}' | sed -e \"s/'//g\" | sort -u | wc -l"
  log "---"
  log_cmd "grep \"is assigned to 2 different systems\" $base_dir/var/log/rhsm/rhsm.log | awk '{print \$9}' | sed -e \"s/'//g\" | sort -u | wc -l"
  log "---"
  log

  log "// duplicated hypervisors list"
  log "grep \"is assigned to 2 different systems\" $base_dir/var/log/rhsm/rhsm.log | awk '{print \$9}' | sed -e \"s/'//g\" | sort -u"
  log "---"
  log_cmd "grep \"is assigned to 2 different systems\" $base_dir/var/log/rhsm/rhsm.log | awk '{print \$9}' | sed -e \"s/'//g\" | sort -u"
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

  log "// virt-who status"
  log "cat $base_dir/sos_commands/systemd/systemctl_list-units | grep virt-who"
  log "---"
  log_cmd "cat $base_dir/sos_commands/systemd/systemctl_list-units | grep virt-who"
  log "---"
  log

  log "// virt-who default configuration"
  log "cat $base_dir/etc/sysconfig/virt-who | grep -v ^# | grep -v ^$"
  log "---"
  log_cmd "cat $base_dir/etc/sysconfig/virt-who | grep -v ^# | grep -v ^$"
  log "---"
  log

  log "// virt-who configuration"
  log "ls -l $base_dir/etc/virt-who.d"
  log "---"
  log_cmd "ls -l $base_dir/etc/virt-who.d"
  log "---"
  log

  log "// duplicated server entries on virt-who configuration"
  log "grep -h ^server $base_dir/etc/virt-who.d/*.conf | sort | uniq -c"
  log "---"
  log_cmd "grep -h ^server $base_dir/etc/virt-who.d/*.conf | sort | uniq -c"
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
  log "cat $base_foreman/var/log/httpd/foreman-ssl_access_ssl.log  | grep \"cmd=virt-who\" | awk '{print \$1}' | sort | uniq -c"
  log "---"
  log_cmd "cat $base_foreman/var/log/httpd/foreman-ssl_access_ssl.log  | grep \"cmd=virt-who\" | awk '{print \$1}' | sort | uniq -c"
  log "---"
  log



  log_tee "## Hypervisors tasks"
  log

  log "// latest 30 hypervisors tasks"

  if [ "$sos_version" == "old" ];then
    cmd="cat $base_foreman/foreman_tasks_tasks.csv | grep -E '(^                  id|Hypervisors)' | sed -e 's/,/ /g' | sort -rk6 | head -n 30 | cut -d\| -f3,4,5,6,7"
  else
    cmd="cat $base_dir/sos_commands/foreman/foreman_tasks_tasks | grep -E '(^                  id|Hypervisors)' | sed -e 's/,/ /g' | sort -rk6 | head -n 30 | cut -d\| -f3,4,5,6,7"
  fi

  log "$cmd"
  log "---"
  log_cmd "$cmd"
  log "---"
  log


  log_tee "## Tomcat"
  log

  log "// Memory (Xms and Xmx)"
  log "grep tomcat $base_dir/ps"
  log "---"
  log_cmd "grep tomcat $base_dir/ps"
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

  log "// candlepin storage consumption"
  log "cat $base_dir/sos_commands/candlepin/du_-sh_.var.lib.candlepin"
  log "---"
  log_cmd "cat $base_dir/sos_commands/candlepin/du_-sh_.var.lib.candlepin"
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

  log_tee "## Tuning"
  log

  log "// prefork.conf configuration"
  log "cat $base_dir/etc/httpd/conf.modules.d/prefork.conf | grep 'ServerLimit\|StartServers'"
  log "---"
  log_cmd "cat $base_dir/etc/httpd/conf.modules.d/prefork.conf | grep 'ServerLimit\|StartServers'"
  log "---"
  log

  log "// 05-foreman.conf configuration"
  log "cat $base_dir/etc/httpd/conf.d/05-foreman.conf | grep 'KeepAlive\b\|MaxKeepAliveRequests\|KeepAliveTimeout\|PassengerMinInstances'"
  log "---"
  log_cmd "cat $base_dir/etc/httpd/conf.d/05-foreman.conf | grep 'KeepAlive\b\|MaxKeepAliveRequests\|KeepAliveTimeout\|PassengerMinInstances'"
  log "---"
  log

  log "// 05-foreman-ssl.conf configuration"
  log "cat $base_dir/etc/httpd/conf.d/05-foreman-ssl.conf | grep 'KeepAlive\b\|MaxKeepAliveRequests\|KeepAliveTimeout\|PassengerMinInstances'"
  log "---"
  log_cmd "cat $base_dir/etc/httpd/conf.d/05-foreman-ssl.conf | grep 'KeepAlive\b\|MaxKeepAliveRequests\|KeepAliveTimeout\|PassengerMinInstances'"
  log "---"
  log

  log "// katello.conf configuration"
  log "cat $base_dir/etc/httpd/conf.d/05-foreman-ssl.d/katello.conf | grep 'KeepAlive\b\|MaxKeepAliveRequests\|KeepAliveTimeout'"
  log "---"
  log_cmd "cat $base_dir/etc/httpd/conf.d/05-foreman-ssl.d/katello.conf | grep 'KeepAlive\b\|MaxKeepAliveRequests\|KeepAliveTimeout'"
  log "---"
  log

  log "// passenger.conf configuration - 6.3 or less"
  log "cat $base_dir/etc/httpd/conf.d/passenger.conf | grep 'MaxPoolSize\|PassengerMaxRequestQueueSize'"
  log "---"
  log_cmd "cat $base_dir/etc/httpd/conf.d/passenger.conf | grep 'MaxPoolSize\|PassengerMaxRequestQueueSize'"
  log "---"
  log

  log "// passenger-extra.conf configuration - 6.4+"
  log "cat $base_dir/etc/httpd/conf.modules.d/passenger_extra.conf | grep 'MaxPoolSize\|PassengerMaxRequestQueueSize'"
  log "---"
  log_cmd "cat $base_dir/etc/httpd/conf.modules.d/passenger_extra.conf | grep 'MaxPoolSize\|PassengerMaxRequestQueueSize'"
  log "---"
  log

  log "// pulp_workers configuration"
  log "cat $base_dir/etc/default/pulp_workers | grep '^PULP_MAX_TASKS_PER_CHILD\|^PULP_CONCURRENCY'"
  log "---"
  log_cmd "cat $base_dir/etc/default/pulp_workers | grep '^PULP_MAX_TASKS_PER_CHILD\|^PULP_CONCURRENCY'"
  log "---"
  log

  log "// foreman-tasks/dynflow configuration - 6.3 or less"
  log "cat $base_dir/etc/sysconfig/foreman-tasks | grep 'EXECUTOR_MEMORY_LIMIT\|EXECUTOR_MEMORY_MONITOR_DELAY\|EXECUTOR_MEMORY_MONITOR_INTERVAL'"
  log "---"
  log_cmd "cat $base_dir/etc/sysconfig/foreman-tasks | grep 'EXECUTOR_MEMORY_LIMIT\|EXECUTOR_MEMORY_MONITOR_DELAY\|EXECUTOR_MEMORY_MONITOR_INTERVAL'"
  log "---"
  log

  log "// foreman-tasks/dynflow configuration - 6.4+"
  log "cat $base_dir/etc/sysconfig/dynflowd | grep 'EXECUTOR_MEMORY_LIMIT\|EXECUTOR_MEMORY_MONITOR_DELAY\|EXECUTOR_MEMORY_MONITOR_INTERVAL'"
  log "---"
  log_cmd "cat $base_dir/etc/sysconfig/dynflowd | grep 'EXECUTOR_MEMORY_LIMIT\|EXECUTOR_MEMORY_MONITOR_DELAY\|EXECUTOR_MEMORY_MONITOR_INTERVAL'"
  log "---"
  log

  log "// postgres configuration"
  log "cat $base_dir/var/lib/pgsql/data/postgresql.conf | grep 'max_connections\|shared_buffers\|work_mem\|checkpoint_segments\|checkpoint_completion_target' | grep -v '^#'"
  log "---"
  log_cmd "cat $base_dir/var/lib/pgsql/data/postgresql.conf | grep 'max_connections\|shared_buffers\|work_mem\|checkpoint_segments\|checkpoint_completion_target' | grep -v '^#'"
  log "---"
  log

  log "// tomcat configuration"
  log "cat $base_dir/etc/tomcat/tomcat.conf | grep 'JAVA_OPTS'"
  log "---"
  log_cmd "cat $base_dir/etc/tomcat/tomcat.conf | grep 'JAVA_OPTS'"
  log "---"
  log

  log "// qpidd configuration"
  log "cat $base_dir/etc/qpid/qpidd.conf | grep 'mgmt_pub_interval'"
  log "---"
  log_cmd "cat $base_dir/etc/qpid/qpidd.conf | grep 'mgmt_pub_interval'"
  log "---"
  log

  log "// httpd|apache limits"
  log "cat $base_dir/etc/systemd/system/httpd.service.d/limits.conf | grep 'LimitNOFILE'"
  log "---"
  log_cmd "cat $base_dir/etc/systemd/system/httpd.service.d/limits.conf | grep 'LimitNOFILE'"
  log "---"
  log

  log "// qrouterd limits"
  log "cat $base_dir/etc/systemd/system/qdrouterd.service.d/90-limits.conf | grep 'LimitNOFILE'"
  log "---"
  log_cmd "cat $base_dir/etc/systemd/system/qdrouterd.service.d/90-limits.conf | grep 'LimitNOFILE'"
  log "---"
  log

  log "// qpidd limits"
  log "cat $base_dir/etc/systemd/system/qpidd.service.d/90-limits.conf | grep 'LimitNOFILE'"
  log "---"
  log_cmd "cat $base_dir/etc/systemd/system/qpidd.service.d/90-limits.conf | grep 'LimitNOFILE'"
  log "---"
  log

  log "// smart proxy dynflow core limits"
  log "cat $base_dir/etc/systemd/system/smart_proxy_dynflow_core.service.d/90-limits.conf | grep 'LimitNOFILE'"
  log "---"
  log_cmd "cat $base_dir/etc/systemd/system/smart_proxy_dynflow_core.service.d/90-limits.conf | grep 'LimitNOFILE'"
  log "---"
  log

  log "// sysctl configuration"
  log "cat $base_dir/etc/sysctl.conf | grep 'fs.aio-max-nr'"
  log "---"
  log_cmd "cat $base_dir/etc/sysctl.conf | grep 'fs.aio-max-nr'"
  log "---"
  log

  log "// dynflow executors - 6.3 or less"
  log "grep EXECUTORS_COUNT $base_dir/etc/sysconfig/foreman-tasks"
  log "---"
  log_cmd "grep EXECUTORS_COUNT $base_dir/etc/sysconfig/foreman-tasks"
  log "---"
  log

  log "// dynflow executors - 6.4 or greater"
  log "grep EXECUTORS_COUNT $base_dir/etc/sysconfig/dynflowd"
  log "---"
  log_cmd "grep EXECUTORS_COUNT $base_dir/etc/sysconfig/dynflowd"
  log "---"
  log


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
