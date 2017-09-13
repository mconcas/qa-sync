#!/bin/bash -e

detectors=( ad emc evs fmd hmp its mu pho pid t0 tks tof tpc trd v0 zdc )

for i in "${detectors[@]}"
  do fori j in {c..t}
    do ls /eos/user/a/aliqa$i/www/data/2016/LHC16$j
done
