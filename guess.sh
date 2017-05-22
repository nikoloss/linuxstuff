#!/bin/bash
function guess
{
    local dice=$(($RANDOM % 6))
    local result="you lose!"
    echo your choice is $1 the dice is $dice
    if [ $dice -ge 3 -a $1 = "m" ] ;then
	result="you win!"
    elif [ $dice -lt 3 -a $1 = "s" ] ;then
	result="you win!"
    fi
    echo $result
}
guess $1
