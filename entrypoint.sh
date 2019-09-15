#!/bin/sh -l

echo "Hello $1"
time=$(date)
echo ::set-output name=time::$time
env
cat ${GITHUB_EVENT_PATH}
echo "Done"

