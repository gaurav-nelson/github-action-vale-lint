#!/usr/bin/env bash

touch output.txt
touch ignored.txt

MASTER_HASH=$(git rev-parse origin/master)
EXTENSION_ARRAY=(.md .adoc .rst .txt)

# ---- For PR comments START ----

## set variables
API_VERSION=v3
BASE=https://api.github.com
AUTH_HEADER="Authorization: token ${GH_COMMENT_TOKEN}"
HEADER="Accept: application/vnd.github.${API_VERSION}+json;"
## required for Checks API https://developer.github.com/v3/checks/runs/
HEADER="${HEADER}; application/vnd.github.antiope-preview+json"

## URLs
REPO_URL="${BASE}/repos/${GITHUB_REPOSITORY}"

check_events_json() {
    echo ">>>>>>>>>>>>>>> Inside check events <<<<<<<<<<<<<<<<<<<<<<<<"
    if [[ ! -f "${GITHUB_EVENT_PATH}" ]]; then
        echo "Cannot find Github events file at ${GITHUB_EVENT_PATH}";
        exit 1;
    fi
    echo "Found ${GITHUB_EVENT_PATH}";

}

## Delete comments if everything is fine.
clean_up() {
  echo ">>>>>>>>>>>>>>> Inside cleanup <<<<<<<<<<<<<<<<<<<<<<<<"
  COMMENTS_URL="${REPO_URL}/issues/${NUMBER}/comments"

  BODY=$(curl -sSL -H "${AUTH_HEADER}" -H "${HEADER}" "${COMMENTS_URL}")
    #Find if there are any comments
    if [ ${#BODY[@]} -eq 0 ]; then
      # Get all the comments for the pull request.
      COMMENTS=$(echo "$BODY" | jq --raw-output '.[] | {id: .id, body: .body} | @base64')
      for C in ${COMMENTS}; do
        COMMENT="$(echo "$C" | base64 --decode)"
        COMMENT_ID=$(echo "$COMMENT" | jq --raw-output '.id')
        COMMENT_BODY=$(echo "$COMMENT" | jq --raw-output '.body')
        # All comments starts with this tag
        if [[ "$COMMENT_BODY" == *":red_circle: Vale lint errors:"* ]]; then
          echo "Deleting old comment ID: $COMMENT_ID"
          curl -sSL -H "${AUTH_HEADER}" -H "${HEADER}" -X DELETE "${REPO_URL}/issues/comments/${COMMENT_ID}"
        fi
      done
    fi
}

## Function to post comments to the PR
post_message() {
    echo ">>>>>>>>>>>>>>> Inside post message <<<<<<<<<<<<<<<<<<<<<<<<"
    ERROR_FILE="output.txt"
    NO_ERROR="0 errors, 0 warnings and 0 suggestions"
    if grep -qF "$NO_ERROR" output.txt
    then
      # if found
      echo ">>>>>>>>>>>>>>> Inside Found <<<<<<<<<<<<<<<<<<<<<<<<"
      clean_up
    else
      # if not found
      # Comment with Python
      echo ">>>>>>>>>>>>>>> Inside not found <<<<<<<<<<<<<<<<<<<<<<<<"
      export AUTH_HEADER HEADER COMMENTS_URL API_VERSION GH_COMMENT_TOKEN ERROR_FILE
      python3 post_message.py
    fi   

}

## Function to run if there are errors and a GH_COMMENT_TOKEN exists
main () {
  echo ">>>>>>>>>>>>>>> Inside main <<<<<<<<<<<<<<<<<<<<<<<<"
  check_events_json;
  NUMBER=$(jq --raw-output .number "${GITHUB_EVENT_PATH}");
  echo "NUMBER: $NUMBER"
  clean_up;
  post_message;
}
# ---- For PR comments END ----

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
    /vale "${i}" >> output.txt
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
    echo "-------------------------"
    echo ""
  fi
  if [[ -z "${GH_COMMENT_TOKEN}" ]]; then
    echo "NOTE: If you want to add these errors as a comment on the original pull request, add a GH_COMMENT_TOKEN as an environment variable."
  else
    main;      
  fi
  exit 113
else
  check_events_json;
  NUMBER=$(jq --raw-output .number "${GITHUB_EVENT_PATH}");
  clean_up;
  echo "All good!"
fi
