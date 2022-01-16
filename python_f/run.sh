#!/bin/bash

python="$(eval conda info --base)/envs/md_comparison/bin/python"
$python "python_f/md.py"