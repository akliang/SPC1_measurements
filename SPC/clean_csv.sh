#!/bin/bash

if [ "$1" == "" ]; then
  echo "needs an input file"
  exit
fi

sed -i -e '1,6d' -e "s/,,,//g" "$1"
