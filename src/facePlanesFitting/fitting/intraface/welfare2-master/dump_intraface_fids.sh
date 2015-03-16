#!/bin/bash

i=0
while read line
do
    echo -e "$line\n"
    i=$((i+1))
    output=$2/$i.txt
    ./bin/faceDetect $line > $output

done < $1 
