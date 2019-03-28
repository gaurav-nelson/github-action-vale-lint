#!/usr/bin/env bash

# to avoid continuing when errors or undefined variables are present
set -eu

# Download and extract vale
wget https://github.com/errata-ai/vale/releases/download/v1.3.2/vale_1.3.2_Linux_64-bit.tar.gz
tar -xvzf vale_1.3.2_Linux_64-bit.tar.gz vale

# Save output in a file
touch output.txt

# git test
git branch
git status

#find modified files in last commit and only run vale on modified files
for i in $(git diff --name-only "$(git rev-parse HEAD~1)") ; do
#  fileList[$N]="$i"
  if [ "${i: -3}" == ".md" ] ; then
    echo -e "CHECKING REFERENCES for ${i}"
    ./vale "${i}" >> output.txt
    echo $'\n'
    (( N= N + 1 ))
  else
    echo "Ignored ${i}, not a markdown file."
  fi
done

if [ -s output.txt ] 
then
 cat output.txt
fi
