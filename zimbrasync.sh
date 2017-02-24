#!/bin/bash

#This script syncronizes 2 zimbra servers using rsync and dumping/restoring the ldap database, without shutting down the original zimbra server
#Exchange the ssh keys before launching this script!
#This script was thought to be started from the secondary/receiving zimbra server, due to NAT limitations in that environment

#You need to perform a dummy installation of zimbra on the secondary server for this script to work

#Tested with Zimbra8 


PATH=/usr/local/sbin:/usr/local/bin:/sbin:/bin:/usr/sbin:/usr/bin

remotehost=	# remote zimbra ip address
remoteport=	# remote ssh port
remoteuser=	# remote ssh user
remotepath=	# default installation path -> /opt/zimbra

exclude1=*data/ldap/mdb
exclude2=*backup

echo "Rsyncying zimbra"
su - zimbra -c 'zmcontrol stop'
rsync -avz --delete --progress --partial --exclude $exclude1 --exclude $exclude2 --exclude redo.log --exclude *.pid --exclude *.sock -e ssh $remoteuser@$remotehost:$remotepath /opt/.
echo "Zimbra rsynched"
echo "Backup ldap config"
ssh $remoteuser@$remotehost "su - zimbra -c '/opt/zimbra/libexec/zmslapcat -c /tmp/zimbra-ldap'"
echo "Backup ldap data"
ssh $remoteuser@$remotehost "su - zimbra -c '/opt/zimbra/libexec/zmslapcat /tmp/zimbra-ldap'"
echo "Copy ldap backup locally"
rsync -avz --progress --delete --partial -e ssh $remoteuser@$remotehost:/tmp/zimbra-ldap /tmp/.
rsync -avz --progress --delete --partial -e ssh $remoteuser@$remotehost:/var/spool/cron/crontabs/zimbra /var/spool/cron/crontabs/zimbra

echo "Importing ldap config"

su - zimbra -c '/opt/zimbra/libexec/zmslapadd -c /tmp/zimbra-ldap/ldap-config.bak'

echo "Importing ldap database"
su - zimbra -c '/opt/zimbra/libexec/zmslapadd /tmp/zimbra-ldap/ldap.bak'
