#!/bin/bash
declare -a songs
declare -i curr=0
declare -i size=0
declare title=""

BOLD="^[[40;32m"
REV="\033[31;44m"
NORMAL="\033[37;44m"

function draw {
    for index in ${!songs[@]} ;do
        if [ ! $index -eq $curr ] ;then
            echo -e $NORMAL${songs[$index]}$NORMAL
        else
            echo -e $REV${songs[$index]}$NORMAL
        fi
    done
}

function apply_key {
    let curr=($curr+1)%$size

}

function key_react {
    read -sn 1 key
    case $key in
        '>') apply_key next ;;
        '<') apply_key prev ;;
        '
') apply_key prev ;;
    esac
}

function help {
  cat <<END_HELP


        $title


END_HELP
}

function init {
    local html=$(curl -s http://www.luoo.net/music/$1)
    local title_t=$(echo $html \
                    |grep -oP "vol-title\">[^<]+<" \
                    |grep -oP ">[^<]+<")
    title="<vol.$1>"${title_t:1:-1}
    local body=$(echo $html \
                |grep -oP "trackname btn-play\">[^<]+<" \
                |grep -oP ">[^<]+<")
    while read -r line;
    do
        songs[$size]="\t[-]"${line:1:-1}
        let size=$size+1
    done<<EOF
    $body
EOF
}


tput init
tput smcup
echo -e "\033[37;44m"


init 902
while true; do
    clear
    help
    draw
    key_react
done
clear
tput rmcup

