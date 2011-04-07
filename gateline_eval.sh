#!/bin/bash

for F in ../measurements/environment/*DL*gateline; do
	echo -n $( echo $F | sed -r -e 's/.*(DL..).*(GL..).*\./\1 \2 /' );
	tail -n 5 $F | head -n 1 | \
        gawk '{ printf "\t%s\t%4.1f\t%4.1f\t%4.0f\t%.3f\n", $2, $12, $10, $11*1E6, 0 }';
        #gawk '{ printf "\t%s\t%4.1f\t%4.0f\t%.3f\n", $2, $10, $11*1E6, (9-$10)*$11*1E3 }';
done

