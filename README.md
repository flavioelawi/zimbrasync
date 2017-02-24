This script syncronizes 2 zimbra servers using rsync and dumping/restoring the ldap database, without shutting down the original zimbra server
Exchange the ssh keys before launching this script!
This script was thought to be started from the secondary/receiving zimbra server, due to NAT limitations in that environment

You need to perform a dummy installation of zimbra on the secondary server for this script to work

Tested with Zimbra8 