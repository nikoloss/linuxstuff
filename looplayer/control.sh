#!/bin/bash
declare -x CONTROL_FILE  #-x为导出变量，全局变量
declare -x PLAYING_FILE  #playing共享变量文件

function mplayerpause {
    local playerpid=`ps -ef|grep mplayer \
                        |grep -v grep \
                        |awk '{print $2}' \
                        |head -n1`
    if [ -n "$playerpid" ] ;then
        echo pause > $CONTROL_FILE
    fi
}

function mplayersetvolume {
    local playerpid=`ps -ef|grep mplayer \
                        |grep -v grep \
                        |awk '{print $2}' \
                        |head -n1`
    if [ -n "$playerpid" ] ;then
        echo "volume $1 1"> $CONTROL_FILE
    fi
}

function mplayerquit {
    local playerpid=`ps -ef|grep mplayer \
                        |grep -v grep \
                        |awk '{print $2}' \
                        |head -n1`
    if [ -n "$playerpid" ] ;then
        echo quit > $CONTROL_FILE
    fi
}

function mplayerplay {
    #接受参数$1为音乐地址
    local playerpid=`ps -ef|grep mplayer \
                        |grep -v grep \
                        |awk '{print $2}' \
                        |head -n1`
    if [ -z "$playerpid" ] ;then
        #检查mplayer进程是否存在，如果不存在则启动mplayer
        echo $CONTROL_FILE >> luoo.log
        mplayer -input file=$CONTROL_FILE $1 > /dev/null 2>&1
        echo -1 > $PLAYING_FILE   #播放结束需修改“当前播放”
    else
        #如果存在，则写入操作指令到控制文件
        echo "load $1" > $CONTROL_FILE
    fi
}

