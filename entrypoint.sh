#!/usr/bin/env bash

# to avoid continuing when errors or undefined variables are present
set -eu

# Download and extract vale
wget https://github.com/errata-ai/vale/releases/download/v1.3.2/vale_1.3.2_Linux_64-bit.tar.gz
tar -xvzf vale_1.3.2_Linux_64-bit.tar.gz vale

#find modified files in last commit and only run vale on modified files

for i in $(git diff --name-only "$(git rev-parse HEAD~1)") ; do
#  fileList[$N]="$i"
  if [ "${i: -3}" == ".md" ] ; then
    echo -e "CHECKING REFERENCES for ${i}"
    ./vale "${i}"
    echo $'\n'
    (( N= N + 1 ))
  else
    echo "No modified markdown files to check."
  fi
done
