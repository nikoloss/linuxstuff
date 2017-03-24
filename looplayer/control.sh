#!/bin/bash
declare -x CONTROL_FILE  #-x为导出变量，形成全局变量

function pause {
    echo pause > $CONTROL_FILE
}

function quit {
    echo quit > $CONTROL_FILE
}

function play {
    #接受参数$1为音乐地址
    local playerpid=`ps -ef|grep mplayer \
                        |grep -v grep \
                        |awk '{print $2}' \
                        |head -n1`
    if [ -n "$playerpid" ] ;then
        #检查mplayer进程是否存在，如果不存在则启动mplayer
        mplayer -input file=$CONTROL_FILE $1 &
    else
        #如果存在，则写入操作指令到控制文件
        echo "load $1" > $CONTROL_FILE
    fi
}
