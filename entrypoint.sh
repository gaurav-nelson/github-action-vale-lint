#!/usr/bin/env bash

touch output.txt
touch ignored.txt

NC='\033[0m' # No Color
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
BLUE='\033[0;34m'

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
  echo -e "${YELLOW}==== CHECKING EVENTS FILE ====${NC}"
    if [[ ! -f "${GITHUB_EVENT_PATH}" ]]; then
        echo -e "${RED}Cannot find Github events file at ${GITHUB_EVENT_PATH}${NC}";
        exit 1;
    fi
    echo -e "${GREEN}Found ${GITHUB_EVENT_PATH}${NC}";
}

## Delete previous comments containing errors
clean_up() {
  echo -e "${YELLOW}==== CHECKING PREVIOUS FAILED COMMENTS ====${NC}"
  COMMENTS_URL="${REPO_URL}/issues/${NUMBER}/comments"
  # Store comments id, url, and body
  COMMENT_ID_TO_DELETE=$(curl "${COMMENTS_URL}" | jq '.[] | {id: .id, body: .body}' | jq -r '. | select(.body|test(":red_circle: Vale lint errors:.")) | .id')
  
  if [ -z "$COMMENT_ID_TO_DELETE" ]
  then
        echo -e "${GREEN}No previous failed comment.${NC}"
  else
        echo -e "${GREEN}Deleting old comment ID: $COMMENT_ID_TO_DELETE${NC}"
        curl -sSL -H "${AUTH_HEADER}" -H "${HEADER}" -X DELETE "${REPO_URL}/issues/comments/${COMMENT_ID_TO_DELETE}"
  fi
}

## Function to post comments to the PR
post_message() {
    ERROR_FILE="output.txt"
    NO_ERROR="0 errors, 0 warnings and 0 suggestions"
    if grep -qF "$NO_ERROR" output.txt
    then
      # if found
      clean_up
    else
      # if not found
      # Comment with Python
      echo -e "${YELLOW}==== ADDING FAIL COMMENT ====${NC}"
      export AUTH_HEADER HEADER COMMENTS_URL API_VERSION GH_COMMENT_TOKEN ERROR_FILE
      python3 post_message.py
    fi   

}

## Function to run if there are errors and a GH_COMMENT_TOKEN exists
main () {
  check_events_json;
  NUMBER=$(jq --raw-output .number "${GITHUB_EVENT_PATH}");
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
  echo -e "${YELLOW}=========================> ERRORS <========================="
  cat output.txt
  echo -e "============================================================${NC}"
  if [ -s ignored.txt ] ; then
    echo ""
    echo -e "${YELLOW}----> IGNORED FILES <----${NC}"
    cat ignored.txt
    echo -e "${YELLOW}-------------------------${NC}"
    echo ""
  fi
  if [[ -z "${GH_COMMENT_TOKEN}" ]]; then
    echo -e "${BLUE}NOTE: If you want to add these errors as a comment on the original pull request, add a GH_COMMENT_TOKEN as an environment variable.${NC}"
    echo -e "${BLUE}To add a new Secret, go to Repository Settings > Secrets > Add a new secret${NC}"
  else
    NO_ERROR="0 errors, 0 warnings and 0 suggestions"
    if grep -qF "$NO_ERROR" output.txt
    then
      check_events_json;
      NUMBER=$(jq --raw-output .number "${GITHUB_EVENT_PATH}");
      clean_up;
      exit 0
    else
      main;    
    fi  
  fi
  exit 113
else
  if [[ -z "${GH_COMMENT_TOKEN}" ]]; then
    echo -e "${BLUE}NOTE: If you want to add these errors as a comment on the original pull request, add a GH_COMMENT_TOKEN as an environment variable.${NC}"
    echo -e "${BLUE}To add a new Secret, go to Repository Settings > Secrets > Add a new secret${NC}"
    echo -e "${GREEN}All good!${NC}"
  else
  check_events_json;
  NUMBER=$(jq --raw-output .number "${GITHUB_EVENT_PATH}");
  clean_up;
  echo -e "${GREEN}All good!${NC}"
  fi
fi
