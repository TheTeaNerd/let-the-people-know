#!/bin/sh -l

echo "PWD:"
pwd
echo
echo "LS:"
ls
echo
echo "Params are: $*"
echo
echo "ruby ./entrypoint.rb $*"
ruby ./entrypoint.rb $*
