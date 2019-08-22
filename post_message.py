#!/usr/bin/env python

import requests
import json
import sys
import os

# Get all variables from environment

params = dict()

requireds = ['ERROR_FILE', 
             'COMMENTS_URL', 
             'AUTH_HEADER', 
             'HEADER', 
             'API_VERSION',
             'GH_COMMENT_TOKEN']

for required in requireds:
    
    value = os.environ.get(required)
    if required == None:
        print('Missing environment variable %s' %required)
        sys.exit(1)

    params[required] = value


infile = params['ERROR_FILE']

if not os.path.exists(infile):
    print('Does not exist: %s' %infile)
    sys.exit(1)
    

with open(infile, 'r') as filey:
    all_errors = filey.read()

print(all_errors)

# Prepare request
accept = "application/vnd.github.%s+json;application/vnd.github.antiope-preview+json" % params['API_VERSION']
headers = {"Authorization": "token %s" % params['GH_COMMENT_TOKEN'],
           "Accept": accept,
           "Content-Type": "application/json; charset=utf-8" }

all_errors = ":red_circle: Vale lint errors: \n```\n" + all_errors + "```" 
data = {"body": all_errors }
print(data)
print(json.dumps(data).encode('utf-8'))
response = requests.post(params['COMMENTS_URL'],
                         data = json.dumps(data).encode('utf-8'), 
                         headers = headers)
print(response.json())
print(response.status_code)
