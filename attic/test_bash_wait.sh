#!/bin/bash

while true; do

sleep 1 &
SPID=$!
echo "Waiting for $SPID..."
wait $SPID
echo "...done!"

done

