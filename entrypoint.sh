#!/usr/bin/env bash

touch output.txt
touch ignored.txt

MASTER_HASH=$(git rev-parse origin/master)

EXTENSION_ARRAY=(.md .adoc .rst .txt)

containsElement () {
  local e match="$1"
  shift
  for e; do [[ "$e" == "$match" ]] && return 0; done
  return 1
}

mapfile -t FILE_ARRAY < <( git diff --name-only "$MASTER_HASH" )

for i in "${FILE_ARRAY[@]}"
do
  if ( containsElement "${i: -3}" "${EXTENSION_ARRAY[@]}" ) || ( containsElement "${i: -4}" "${EXTENSION_ARRAY[@]}" ) || ( containsElement "${i: -5}" "${EXTENSION_ARRAY[@]}" ) ; then
    ../../vale "${i}" >> output.txt
  else
    echo "${i}" >> ignored.txt
  fi
done

if [ -s output.txt ] ; then
  echo "=========================> ERRORS <========================="
  cat output.txt
  echo "============================================================"
  if [ -s ignored.txt ] ; then
    echo ""
    echo "----> IGNORED FILES <----"
    cat ignored.txt
  fi
  exit 113
else
  echo "All good!"
fi
