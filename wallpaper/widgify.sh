#!/bin/sh

#图片所在目录路径
PIC_DIR=/home/$USER/Pictures
#脚本所在路径
SCRIPT_DIR=/home/$USER/workspace/linuxstuff/wallpaper

function debug
{
    echo $@
}

function widgify
{
    #下面这个很复杂的判断是如果目录不存在或者（||）文件不存在
    #而使用||，&&需要使用双中括号！（[[]]）
    if [[ ! -d $PIC_DIR ]]||[[ ! -f $PIC_DIR/paper.jpg ]]; then
	#如果~/Pictures/paper.jpg不存在，则调用downpaper.sh
	$SCRIPT_DIR/downpaper.sh
    fi
    local weatherbody=`curl -s www.baidu.com/s?wd=天气`
    local temp=$(echo $weatherbody \
                     |grep -oP "twoicon_shishi_title\">[^<]*?<" \
                     |grep -oP "\d+")
    local status=$(echo $weatherbody \
                  |grep -oP "twoicon_shishi_sub\">[^<]*?<" \
                  |grep -oE ">([^<])*\(")
    local status=${status:1:-1}   #截取字符串，从第1到倒数第1个字节 
    debug temp=$temp status=$status
    #开始合图 如果你不知道自己计算机里面有哪些字体     
    #使用convert -list font查看并选择一个字体   
    convert $PIC_DIR/paper.jpg \
            -resize 1980x \
            -fill skyblue \
            -pointsize 60 \
            -font 文泉驿等宽正黑 \
            -draw "fill-opacity 0.6 roundrectangle 180,150 650,550 10,10" \
            -fill white \
            -draw "text 200,220 '$temp℃ /$status'" \
            -pointsize 40  \
            -draw "text 220,300 '`env LC_ALL=en_US.UTF-8 date "+%a %B"`'" $PIC_DIR/dest.jpg
    #把修改壁纸的语句从downpaper函数挪过来！记住图片名字换成合成图dest而非papaer
    pcmanfm -w $PIC_DIR/dest.jpg
}
#main函数
widgify
