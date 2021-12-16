#!/bin/bash
#Rsync setup on Ubuntu host
#Source host configuration
#------------------VARIABLES------------------------
#Set directory to backup
source=#Source directory
#Set file with connection credentials
secrets=#Path to credentials file/filename (e.g. /etc/rsyncd.secrets)
#Set auth user
auth_user=#Username
#Set auth user password
auth_pass=#Password
#Set backup resource name
bck_res=#Resource name (e.g. data)
#------------------MAIN-----------------------------
#Rsync setup
apt update
apt install -y rsync
#Enable rsync & backup existing configuration
sed -i.bac 's/RSYNC_ENABLE=false/RSYNC_ENABLE=true/' /etc/default/rsync
#Create rsync settings file
cat <<EOF | tee /etc/rsyncd.conf
#Rsync settings
pid file = /var/run/rsyncd.pid
log file = /var/log/rsyncd.log
transfer logging = true
munge symlinks = yes
#Backup source directory settings
[$bck_res]
path = $source
uid = root
read only = yes
list = yes
comment = Data for backup
auth users = $auth_user
secrets file = $secrets
EOF
#Create file with connection credentials
cat <<EOF | tee $secrets
$auth_user:$auth_pass
EOF
#Set permissions to connection credentials file
chmod 0600 $secrets
#Start and enable rsync
systemctl enable rsync --now
