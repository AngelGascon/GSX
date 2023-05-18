#!/bin/bash
#autor: Àngel Gascón.

apt update
apt install snmp snmpd smistrip patch snmp-mibs-downloader

mkdir -p /root/router/
cp /etc/snmp/snmp.conf /root/router/snmp.conf
cp /etc/snmp/snmp.conf /root/router/snmpd.conf

truncate -s 0 /root/router/snmp.conf
echo 'mibdirs + /usr/share/mibs
#mibs: #sinó no es poden utilitzar ni mostrar els noms en text
mibs +All' >> /root/router/snmp.conf

truncate -s 0 /root/router/snmpd.conf
echo '###########################################################################
#
# snmpd.conf
# An example configuration file for configuring the Net-SNMP agent ('snmpd')
# See snmpd.conf(5) man page for details
#
###########################################################################
# SECTION: System Information Setup
#

# syslocation: The [typically physical] location of the system.
#   Note that setting this value here means that when trying to
#   perform an snmp SET operation to the sysLocation.0 variable will make
#   the agent return the "notWritable" error code.  IE, including
#   this token in the snmpd.conf file will disable write access to
#   the variable.
#   arguments:  location_string
sysLocation    Amposta
sysContact     AngelGascon <angel.gascon@estudiants.urv.cat>

# sysservices: The proper value for the sysServices object.
#   arguments:  sysservices_number
sysServices    72



###########################################################################
# SECTION: Agent Operating Mode
#
#   This section defines how the agent will operate when it
#   is running.

# master: Should the agent operate as a master agent or not.
#   Currently, the only supported master agent type for this token
#   is "agentx".
#   
#   arguments: (on|yes|agentx|all|off|no)

master  agentx

# agentaddress: The IP address and port number that the agent will listen on.
#   By default the agent listens to any and all traffic from any
#   interface on the default SNMP port (161).  This allows you to
#   specify which address, interface, transport type and port(s) that you
#   want the agent to listen on.  Multiple definitions of this token
#   are concatenated together (using ':'s).
#   arguments: [transport:]port[@interface/address],...

agentaddress  udp:161

###########################################################################
# SECTION: Access Control Setup
#
#   This section defines who is allowed to talk to your running
#   snmp agent.

# Views 
#   arguments viewname included [oid]

#  system + hrSystem groups only
view   systemonly  included   .1.3.6.1.2.1.1
view   systemonly  included   .1.3.6.1.2.1.25.1
view vistagsx included .1.3.6.1.2.1.2
view vistagsx included .1.3.6.1.2.1.4
view vistagsx included .1.3.6.1.2.1.5
view vistagsx included .1.3.6.1.4.1.2021
view vistagsx included .1.3.6.1.6

# rocommunity: a SNMPv1/SNMPv2c read-only access community name
#   arguments:  community [default|hostname|network/bits] [oid | -V view]

# Read-only access to everyone to the systemonly view
rocommunity  public default -V systemonly
rocommunity6 public default -V systemonly
rocommunity 47861858P 203.0.113.32/27 -V vistagsx
rocommunity 47861858P 192.168.58.0/25 -V vistagsx

# SNMPv3 does not use communities, but users with (optionally) an
# authentication and encryption string. This user needs to be created
# with what they can view with rouser/rwuser lines in this file.
#
# createUser username (MD5|SHA|SHA-512|SHA-384|SHA-256|SHA-224) authpassphrase [DES|AES] [privpassphrase]
# e.g.
# createuser authPrivUser SHA-512 myauthphrase AES myprivphrase
#
createUser gsxViewer SHA aut47861858P
createUser gsxAdmin SHA aut47861858P DES secP85816874 

# This should be put into /var/lib/snmp/snmpd.conf 
#
# rouser: a SNMPv3 read-only access username
#    arguments: username [noauth|auth|priv [OID | -V VIEW [CONTEXT]]]
rouser authPrivUser authpriv -V systemonly
rouser gsxViewer authNoPriv
rwuser gsxAdmin authPriv

includeAllDisks 10
' >> /root/router/snmpd.conf

cp /root/router/snmp.conf /etc/snmp/snmp.conf
cp /root/router/snmpd.conf /etc/snmp/snmpd.conf

chmod 644 /etc/snmp/snmp.conf
chmod 600 /etc/snmp/snmpd.conf
chown root:root /etc/snmp/snmp.conf
chown root:root /etc/snmp/snmpd.conf

systemctl restart snmpd

#########
# locals
# snmpwalk -v 2c -c public localhost system
# nmpwalk -v 2c -c public localhost system
# snmptranslate -Td -OS UCD-SNMP-MIB::ucdavis.dskTable
#########
# remotes
# snmpget -v3 -u gsxAdmin -l authPriv -a SHA -A aut47861858P -x DES -X secP85816874 router  icmpMsgStatsInPkts.ipv4.8
# snmpget -v3 -u gsxAdmin -l authPriv -a SHA -A aut47861858P -x DES -X secP85816874 router  system.sysDescr.0