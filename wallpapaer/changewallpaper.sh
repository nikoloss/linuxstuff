#!/bin/sh
function debug
{
    #debug函数用来调试，可以直接往标准输出打印也可以echo $@ > xx.log来打日志
    #发布正式版的时候还可以直接把此函数注释掉，避免打印调试信息
    echo $@
}

function downpaper
{
    local img=`curl -s http://www.topit.me/tag/PC%E5%A3%81%E7%BA%B8/hot \
              |grep -oP "http:[^>]*?m.jpg" \
              |sed -n $[$RANDOM%20+1]p\
              |sed 's/m.jpg/o.jpg/'`
    debug start downloading [$img]
    wget $img -O paper.jpg
    pcmanfm -w /home/$USER/workspace/linuxstuff/wallpapaer/paper.jpg
}

downpaper
