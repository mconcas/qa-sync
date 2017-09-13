#!/bin/bash -e

## Script params
current_pid=$$
basename=$0
detector=$1
par=$2

## Origin paths
DATA_ORIGIN_DIR=/home/aliqaoperator/local/QAoutputperiod/$detector/data/
SIM_ORIGIN_DIR=/home/aliqaoperator/local/QAoutputperiod/$detector/sim/

## Destination paths
DATA_EOS_DIR=lxplus.cern.ch:/eos/user/a/aliqa$detector/www/data/
SIM_EOS_DIR=lxplus.cern.ch:/eos/user/a/aliqa$detector/www/sim/
PIDFILE=/tmp/qa-sync-$detector.pid

## Logfiles
LOGDIR_PREFIX=/tmp/qa-sync-logs
mkdir -p $LOGDIR_PREFIX || true
STDOUT_LOG=$LOGDIR_PREFIX/qa-sync-$detector.out
STDERR_LOG=$LOGDIR_PREFIX/qa-sync-$detector.err
logfiles_duration=86400 #seconds in a day

## Settings
password=`cat /home/aliqaoperator/qatest/opensesame.txt`
operator=aliqamod
dry_run=

## Delete PIDFILE at exit
function finish () {
  echo "removing PIDFILE: $PIDFILE"; rm -f $PIDFILE;
}

## Delete logifiles older than $LOGFILE_DURATION
function resetlogs () {
  local log_age_stdout=$( date -d "now - $(stat -c "%Y" $STDOUT_LOG) seconds" +%s )
  [[ "$log_age_stdout" -gt "$logfiles_duration" ]] && (rm -f $STDOUT_LOG && echo "$(date) Removed $STDOUT_LOG") || echo "$(date) Not deleting: $STDOUT_LOG"
  local log_age_stderr=$( date -d "now - $(stat -c "%Y" $STDERR_LOG) seconds" +%s )
  [[ "$log_age_stdout" -gt "$logfiles_duration" ]] && (rm -f $STDERR_LOG && echo "$(date) Removed $STDERR_LOG") || echo "$(date) Not deleting: $STDERR_LOG"
}

##### Main Process #####
[[ -e $STDOUT_LOG || -e $STDERR_LOG ]] && resetlogs
echo "Shell is $SHELL, pid is: $current_pid"

# Stale processes check and cleanup
[[ -e $PIDFILE ]] && (pid=$(cat $PIDFILE) && rm -f $PIDFILE && (kill -0 $pid 2>&1 && kill -9 $pid && echo "$(date) Removed stale sync process") || echo "$(date) No stale process found") || echo "No PIDFILE found"

## Pidfile creation
echo $current_pid > $PIDFILE
[[ "$par" == "--dry-run" ]] && (dry_run=$par && echo "$(date) dryrun requested") || true

#### The important part is below! #####
[[ "$par" != "--sim-only" ]] && echo -e "Processing detector: $detector" && echo -e "Synchronising directory: $DATA_ORIGIN_DIR"
[[ "$par" != "--sim-only" ]] && rsync -rltgoDvzuhP $DRY_RUN --rsh="sshpass -p $PASSWORD ssh -l $OPERATOR" $DATA_ORIGIN_DIR $DATA_EOS_DIR > >(tee $STDOUT_LOG) 2> >(tee $STDERR_LOG >&2) || true # data
[[ "$par" != "--sim-only" ]] && echo -e "Synchronisation of $DATA_ORIGIN_DIR for detector: $detector done" && echo -e "Logfiles at: $STDOUT_LOG and $STDERR_LOG"

[[ "$par" != "--data-only" ]] && echo -e "Synchronising directory: $SIM_ORIGIN_DIR\n"
[[ "$par" != "--data-only" ]] && rsync -rltgoDvzuhP $DRY_RUN --rsh="sshpass -p $PASSWORD ssh -l $OPERATOR" $SIM_ORIGIN_DIR $SIM_EOS_DIR > >(tee $STDOUT_LOG) 2> >(tee $STDERR_LOG >&2) || true  # sim
[[ "$par" != "--data-only" ]] && echo -e "Synchronisation of $SIM_ORIGIN_DIR for detector: $detector done" && echo -e "Logfiles at: $STDOUT_LOG and $STDERR_LOG"

# date | nail -s "Sync report for $detector" -a $STDOUT_LOG -a $STDERR_LOG mconcas@cern.ch || true
# rm -Rf $STDERR_LOG
# rm -Rf $STDOUT_LOG

trap finish EXIT
