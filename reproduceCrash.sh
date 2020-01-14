#!/bin/bash

# Reproduces the issue reported in https://github.com/balderdashy/sails/issues/6933
# Can be used to verify if a certain patch fixes the issue reported

# Remove local database created with sails-disk (if any)
rm -rf $(dirname '$0')/.tmp

# Lift sails in the background
( sails lift ) &

# Wait until sails is up on port 1337
while ! nc -q0 localhost 1337 < /dev/null > /dev/null 2>&1; do
    sleep 1
done

# Insert model instances
curl -X POST 'http://localhost:1337/Post' > /dev/null 2>&1
curl -X POST 'http://localhost:1337/Tag' > /dev/null 2>&1
curl -X POST -H 'Content-Type: application/json' -d '{ "post": 1, "tag": 1 }' 'http://localhost:1337/TagAssignment' > /dev/null 2>&1

# This command will kill the server as long as the bug exists
curl -X DELETE 'http://localhost:1337/Post/1' > /dev/null 2>&1

# Kill sails at the end (if the fix worked and sails is still running)
kill $(jobs -p) 2> /dev/null
