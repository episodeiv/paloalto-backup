#!/usr/bin/env bash

# Preparation:
# - add user backup to firewall with superuser (readonly) rights
# - create api key:
#   https://[HOSTNAME/IP ADDRESS]/api/?type=keygen&user=[username]&password=[password]
# - put the following into a file called .env in the same folder as this script:
#   KEY="[API KEY GENERATED ABOVE]"
#
# Usage:
# backup.sh [HOSTNAME/IP ADDRESS]

set -o allexport
source .env
set +o allexport

HOST="172.16.80.21"
FIREWALLNAME="th-fw-jkha"

DATE=$(date +%Y%m%d)
TARGET="/home/TANNENHOF/dv_lichten/fw"
BACKUPFILE="${TARGET}/${FIREWALLNAME}-${HOST}-${DATE}.xml"

mkdir ${TARGET} > /dev/null

URL="https://${HOST}/api/?type=op&cmd=<show><config><running></running></config></show>&key=${KEY}"

curl --output ${BACKUPFILE} --insecure $URL > /dev/null

sed  -i 's/<response status="success"><result>//' ${BACKUPFILE}
sed  -i 's/<\/result><\/response>//' ${BACKUPFILE}
