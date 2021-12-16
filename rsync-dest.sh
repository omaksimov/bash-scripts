#!/bin/bash
#Rsync setup on Ubuntu host
#Destination host configuration
#------------------VARIABLES------------------------
#Set directory to place backups into
dest=#Destination directory
#Set source server ip address
src_addr=#Source server ip
#Set file with connection credentials
secrets=#Path to credentials file/filename (e.g. /etc/rsyncd.secrets)
#Set auth users
auth_user=#Username (the same name as in the source host configuration)
#Set auth user password
auth_pass=#Password (the same password as in the source host configuration)
#Set backup resource name
bck_res=#Resource name (the same name as in the source host configuration)
#------------------MAIN-----------------------------
#Rsync setup
apt update
apt install -y rsync
#Enable rsync & backup existing configuration
sed -i.bac 's/RSYNC_ENABLE=false/RSYNC_ENABLE=true/' /etc/default/rsync
#Create backup *.sh script
cat <<EOF | tee ./${bck_res}-${src_addr}-backup.sh
#!/bin/bash
date
echo "Start backup \"${bck_res}\" from ${src_addr}"
#Create folder for full backup
mkdir -p ${dest}/${bck_res}-${src_addr}-backup/current/
#Create folder for incremental backups
mkdir -p ${dest}/${bck_res}-${src_addr}-backup/increment/
#Start backup
/usr/bin/rsync -avz --progress --delete --password-file=$secrets ${auth_user}@${src_addr}::${bck_res} ${dest}/${bck_res}-${src_addr}-backup/current/ --backup --backup-dir=${dest}/${bck_res}-${src_addr}-backup/increment/`date +%Y-%m-%d`/
#Delete incremental archives older than 30 days
/usr/bin/find ${dest}/${src_addr}/increment/ -maxdepth 1 -type d -mtime +30 -exec rm -rf {} \;
date
echo "\"${bck_res}\" backup from ${src_addr} is finished"
EOF
#Make script file executable
chmod 0744 ./${bck_res}-${src_addr}-backup.sh
#Create file with connection credentials
cat <<EOF | tee $secrets
$auth_pass
EOF
#Set permissions to connection credentials file
chmod 0600 $secrets
#Start and enable rsync
systemctl enable rsync --now
