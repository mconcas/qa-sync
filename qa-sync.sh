#!/bin/bash

echo "Shell is $SHELL"
basename=$0
detector=$1
dry_run=$2
# echo ">>> $basename $detector $dry_run"
# STDOUT_LOG="/tmp/qa-sync-$detector.out"
STDOUT_LOG=/dev/null
STDERR_LOG="/tmp/qa-sync-$detector.err"
PASSWORD=`cat /home/aliqaoperator/qatest/opensesame.txt`
OPERATOR=aliqamod
DRY_RUN=

[[ "$dry_run" == "--dry-run" ]] && DRY_RUN=$dry_run && echo ">>>>> dryrun requested <<<<<"

# Origin
DATA_ORIGIN_DIR=/home/aliqaoperator/local/QAoutputperiod/$detector/data/
SIM_ORIGIN_DIR=/home/aliqaoperator/local/QAoutputperiod/$detector/sim/

# Destination
DATA_EOS_DIR=lxplus.cern.ch:/eos/user/a/aliqa$detector/www/data/
SIM_EOS_DIR=lxplus.cern.ch:/eos/user/a/aliqa$detector/www/sim/

echo ">>>>> Processing detector: $detector <<<<<"
echo -e "Synchronising directory: $DATA_ORIGIN_DIR\n"

rsync -rltgoDvzuhP $DRY_RUN --rsh="sshpass -p $PASSWORD ssh -l $OPERATOR" $DATA_ORIGIN_DIR $DATA_EOS_DIR > >(tee $STDOUT_LOG) 2> >(tee $STDERR_LOG >&2) # data
echo "Synchronisation of $DATA_ORIGIN_DIR for $detector done."
echo -e "Logfiles at: $STDOUT_LOG and $STDERR_LOG\n"

echo -e "Synchronising directory: $SIM_ORIGIN_DIR\n"
rsync -rltgoDvzuhP $DRY_RUN --rsh="sshpass -p $PASSWORD ssh -l $OPERATOR" $SIM_ORIGIN_DIR $SIM_EOS_DIR > >(tee $STDOUT_LOG) 2> >(tee $STDERR_LOG >&2)   # sim
echo "Synchronisation of $SIM_ORIGIN_DIR for $detector done."
echo "Logfiles at: $STDOUT_LOG and $STDERR_LOG"