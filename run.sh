#!/bin/bash

function _time {
  echo -e "$1 ...\t"
  time $2
}

export TIMEFORMAT='%3R'
python="$(eval conda info --base)/envs/md_comparison/bin/python"

_time "Python_OO" "$python python_oo/md.py"
