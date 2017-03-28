#!/bin/bash

declare -a songs #-a定义songs为Array结构
declare -i size=0 #-i定义size为数字类型 songs的长度
declare -i cursor=0 #定义选中光标
declare -i volume=5 #音量
declare vol #什么参数都不加，默认为字符串
declare title
declare CONTROL_FILE=/tmp/control
declare PLAYING_FILE=/tmp/playing

. ./control.sh

SELECTED="\033[31;44m"   #选中的时候前景色为红，背景色青蓝
NORMAL="\033[37;44m"     #非选中请景色为白，背景色仍是青蓝

function debug {
    #日志功能，带上时间点打印到luoo.log文件中去，方便调试
    echo `date +%T:` $@ >> luoo.log
}

#loadsongs(vol),加载某一期的歌曲专辑
function loadsongs {
    if [ -z $1 ] ;then
        #如果没有参数则自动获取最新专辑编号
        vol=`curl -s www.luoo.net \
            |grep -oP "http://www.luoo.net/music/\d+" \
            |grep -oP "\d+"|head -n1`
    else
        #如果有参数则加载指定专辑
        vol=$1
    fi
    local html=$(curl -s http://www.luoo.net/music/$vol)
    title=$(echo $html \
                    |grep -oP "vol-title\">[^<]+<" \
                    |grep -oP ">[^<]+<")
    title=${title:1:-1}
    local body=$(echo $html \
                |grep -oP "trackname btn-play\">[^<]+<" \
                |grep -oP ">[^<]+<")
    #read -r 意思是每次读一行！否则每次读一个字符串，读到line变量中！
    while read -r line;
    do
        songs[$size]=${line:1:-1}
        ((size++))
    done<<EOF
    $body
EOF
}

function draw {
    read playing < $PLAYING_FILE
    clear
    cat <<EOF

    <vol.$vol>$title      volume:$volume (max:10)

EOF
    for index in ${!songs[@]} ;do
        printf "\t"
        if [ $playing -eq $index ] ;then
            printf "["$BOLD"playing"$NORMAL"]"
        else
            printf "[-------]"
        fi
        if [ $cursor -eq $index ] ;then
            echo -e $SELECTED${songs[$index]}$NORMAL
        else
            echo -e $NORMAL${songs[$index]}$NORMAL
        fi
    done
    cat<<EOF

        操作说明:"w/s"    选择歌曲
                 "+/-"    调节音量
                 "p"      播放/暂停
                 "ctrl+c" 退出
    《落网》音乐播放器v0.9 powed by Rowland(rowland.lan@163.com)

EOF
}

function keymap {
    read -sn 1 key
    case $key in
        's') choose next ;;
        'w') choose prev ;;
        'p') enjoy ;;
        '+') setvolume up ;;
        '=') setvolume up ;;
        '-') setvolume down ;;
    esac
}

function choose {
    if [ $1 = next ] ;then
        let cursor=($cursor+1)%$size
    elif [ $1 = prev ]; then
        let move=$cursor-1
        let cursor=$move==-1?$size-1:$move
    fi
}

function enjoy {
    read playing < $PLAYING_FILE
    local url=`printf http://mp3-cdn.luoo.net/low/luoo/radio%s/%02d.mp3 \
                $vol $[cursor+1]` > /dev/null
    if [ ! $playing -eq $cursor ] ;then
        #播放结束后需要触发一次重绘所以在play之后紧接着draw
        (mplayerplay $url && draw) &
        echo $cursor > $PLAYING_FILE
    else
        mplayerpause
    fi
}

function setvolume {
    if [[ $1 = up ]]&&[[ $volume -lt 10 ]] ;then
        ((volume++))
    elif [[ $1 = down ]]&&[[ $volume -gt 1 ]]; then
        ((volume--))
    fi
    mplayersetvolume $[$volume*10]
}

function initialize {
    #初始化函数
    if [ -p $CONTROL_FILE ] ;then
        #如果存在mplayer控制管道，则删掉先
        rm $CONTROL_FILE
    fi
    #创建mplayer控制管道
    mkfifo $CONTROL_FILE
    #初始化“正在播放”变量为-1
    echo -1 > $PLAYING_FILE
}

function quitluoo {
    mplayerquit
    sleep 0.5 #给予mplayer进程退出一点时间
    tput rmcup
    clear
    exit
}

#main
tput init
tput smcup
initialize
echo -e $NORMAL
trap 'quitluoo' INT   #捕获ctrl+c信号，调用quitluoo函数
loadsongs $1
while true; do
    draw
    keymap
done
quitluoo

