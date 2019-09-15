#!/bin/sh -l

echo "Hello $1"
time=$(date)
echo ::set-output name=time::$time
env
cat ${GITHUB_EVENT_PATH}
echo "Done"

cat ${GITHUB_EVENT_PATH} | jq -r '.commits[].message,.commits[].author.name' |  (
    while read line; do
        read message
        read author
        echo "${message} (_${author}_)"
    done
)
