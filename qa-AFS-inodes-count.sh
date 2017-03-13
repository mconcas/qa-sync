#! /bin/bash -e

# Parameters
detector=$1
mailto=$2

# Check detector name and path
: ${detector:?"Detector must specified!"}
dest_path="/afs/cern.ch/work/a/aliqa$detector/www"
registry_file="/afs/cern.ch/user/a/aliqamod/inodes-$detector.txt"
stat $dest_path

### Main
date=$(date +%s)
inodes=$(find "$afs_path"/ | wc -l)
echo -e "$date\t$inodes" >> $registry_file
echo $inodes | nail -s "Inode count for $detector" $mailto
