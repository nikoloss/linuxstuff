#!/bin/bash

#定义图片目录路径
DIR_PIC=/home/$USER/Pictures

function debug
{
    echo $@
}

function downpaper
{
    local img=$(curl -s http://www.topit.me/tag/PC壁纸/ \
              |grep -oP "http:[^>]*?m.jpg" \
              |sed -n $[$RANDOM%20+1]p \
              |sed 's/m.jpg/o.jpg/')
    debug start downloading [$img]
    # test的-d是用来检测目录是否存在，前面的!是取反（如果不存在的话）
    if [ ! -d $DIR_PIC ]; then
	#如果不存在这个目录就创建它
	mkdir -p $DIR_PIC
    fi
    wget $img -O $DIR_PIC/paper.jpg
}
#main函数
downpaper
