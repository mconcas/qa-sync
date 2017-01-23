SIM_EOS_DIR=lxplus.cern.ch:/eos/user/a/aliqa$detector/www/sim/
pidfile=/tmp/qa-sync-$detector.pid

## Logfiles
STDOUT_LOG=/tmp/qa-sync-logs/qa-sync-$detector.out
STDERR_LOG=/tmp/qa-sync-logs/qa-sync-$detector.err
LOGFILES_DURATION=86400 #seconds in a day

## Settings
PASSWORD=`cat /home/aliqaoperator/qatest/opensesame.txt`
OPERATOR=aliqamod
DRY_RUN=

## Delete pidfile at exit
function finish () {
  echo "removing pidfile: $pidfile"; rm -f $pidfile;
}

## Delete logifiles older than $LOGFILE_DURATION
function resetlogs () {
  local log_age_stdout=$( date -d "now - $(stat -c "%Y" $STDOUT_LOG) seconds" +%s )
  [[ "$log_age_stdout" -gt "$LOGFILES_DURATION" ]] && (rm -f $STDOUT_LOG && echo "$(date) Removed $STDOUT_LOG") || echo "$(date) Not deleting: $STDOUT_LOG"
  local log_age_stderr=$( date -d "now - $(stat -c "%Y" $STDERR_LOG) seconds" +%s )
  [[ "$log_age_stdout" -gt "$LOGFILES_DURATION" ]] && (rm -f $STDERR_LOG && echo "$(date) Removed $STDERR_LOG") || echo "$(date) Not deleting: $STDERR_LOG"
}

##### Main Process #####
[[ -e $STDOUT_LOG || -e $STDERR_LOG ]] && resetlogs
echo "Shell is $SHELL, pid is: $current_pid"

# Stale processes check and cleanup
[[ -e $pidfile ]] && (pid=$(cat $pidfile) && rm -f $pidfile && (kill -0 $pid 2>&1 && kill -9 $pid && echo "$(date) Removed stale sync process") || echo "$(date) No stale process found") || echo "No pidfile found"

## Pidfile creation
echo $current_pid > $pidfile
[[ "$dry_run" == "--dry-run" ]] && (DRY_RUN=$dry_run && echo "$(date) dryrun requested") || true

#### The important part is below! #####
echo -e "Processing detector: $detector" && echo -e "Synchronising directory: $DATA_ORIGIN_DIR"
[[ "$custom_par" != "--sim-only" ]] && rsync -rltgoDvzuhP $DRY_RUN --rsh="sshpass -p $PASSWORD ssh -l $OPERATOR" $DATA_ORIGIN_DIR $DATA_EOS_DIR > >(tee $STDOUT_LOG) 2> >(tee $STDERR_LOG >&2) || true # data
echo -e "Synchronisation of $DATA_ORIGIN_DIR for detector: $detector done." && echo -e "Logfiles at: $STDOUT_LOG and $STDERR_LOG"

echo -e "Synchronising directory: $SIM_ORIGIN_DIR\n"
[[ "$custom_par" != "--data-only" ]] && rsync -rltgoDvzuhP $DRY_RUN --rsh="sshpass -p $PASSWORD ssh -l $OPERATOR" $SIM_ORIGIN_DIR $SIM_EOS_DIR > >(tee $STDOUT_LOG) 2> >(tee $STDERR_LOG >&2) || true  # sim
echo -e "Synchronisation of $SIM_ORIGIN_DIR for detector: $detector done." && echo -e "Logfiles at: $STDOUT_LOG and $STDERR_LOG"

trap finish EXIT
