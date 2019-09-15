#!/bin/sh -l

echo "PWD:"
pwd
echo
echo "LS:"
ls
echo
echo "Params are: $*"
echo
ruby /usr/src/app/entrypoint.rb $*
