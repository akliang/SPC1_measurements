#!/bin/bash

if [ "$1" == "" ]; then
  echo "needs an input file"
  exit
fi
if [ "$2" == "" ]; then
  echo "needs an output file"
  exit
fi


sed -e '1,6d' -e "s/,,,//g" "$1" > "$2"

