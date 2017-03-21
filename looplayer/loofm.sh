#!/bin/bash

function key_map {
    read -sn 1 key
    echo got $key
}


tput smcup

while true ;do
    key_map
done

tput rmcup
