#! /bin/bash -e

type stat eos > /dev/null

detector=$1
mailto=mconcas@cern.ch

: ${detector:?"Must Specify a detector!"}

eos_path=/eos/user/a/aliqa$detector/www
eos_quota_logfile=/eos/user/a/aliqa$detector/www/eos-quota-res-$detector.txt
stat $eos_path > /dev/null

### Main
date=$(date +%s)
export EOS_MGM_URL=root://eosuser.cern.ch
echo -e "$date" >> $eos_quota_logfile && eos quota $eos_path -m >> $eos_quota_logfile && echo >> $eos_quota_logfile
eos quota $eos_path -m | nail -s "EOS quota for $detector" $mailto 2>&1 > /dev/null
