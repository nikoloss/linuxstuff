#!/bin/bash

declare -a songs
declare -i size=0
declare -i cursor=-1
declare vol
declare title

SELECTED="\033[31;44m"
NORMAL="\033[37;44m"

function debug {
    echo `date +%T:` $@ >> luoo.log
}

function init {
    vol=$1
    local html=$(curl -s http://www.luoo.net/music/$1)
    title=$(echo $html \
                    |grep -oP "vol-title\">[^<]+<" \
                    |grep -oP ">[^<]+<")
    title=${title:1:-1}
    local body=$(echo $html \
                |grep -oP "trackname btn-play\">[^<]+<" \
                |grep -oP ">[^<]+<")
    while read -r line;
    do
        let size=$size+1
        songs[$size]=${line:1:-1}
    done<<EOF
    $body
EOF
}

function draw {
    clear
    cat <<EOF

    <vol.$vol>$title

EOF
    for index in ${!songs[@]} ;do
        printf "\t"
        if [ $cursor -eq $index ] ;then
            echo -e $SELECTED${songs[$index]}$NORMAL
        else
            echo -e $NORMAL${songs[$index]}$NORMAL
        fi
    done
}

function keymap {
    read -sn 1 key
    case $key in
        '>') debug "push >" ;;
        '<') debug "push <" ;;
        'p') debug "push play" ;;
    esac
}

function quitluoo {
    tput rmcup
    clear
    exit
}

tput init
tput smcup
echo -e $NORMAL
trap quitluoo INT
init $1
while true; do
    draw
    keymap
done
quitluoo

