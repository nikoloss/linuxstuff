#!/bin/bash
function debug
{
    #debug函数用来调试，可以直接往标准输出打印也可以echo $@ > xx.log来打日志
    #发布正式版的时候还可以直接把此函数注释掉，避免打印调试信息
    echo $@
}

function downpaper
{
    local img=`curl -s http://www.topit.me/tag/pc壁纸 \

              |grep -oP "http:[^>]*?m.jpg" \
              |sed -n $[$RANDOM%20+1]p\
              |sed 's/m.jpg/o.jpg/'`
    debug start downloading [$img]
    wget $img -O paper.jpg

}

function widgify
{
    local weatherbody=`curl -s www.baidu.com/s?wd=天气`
    local temp=$(echo $weatherbody \
		     |grep -oP "twoicon_shishi_title\">[^<]*?<" \
		     |grep -oP "\d+")
    local status=$(echo $weatherbody\
                  |grep -oP "twoicon_shishi_sub\">[^<]*?<"\
                  |grep -oE ">([^<])*\(")
    local status=${status:1:-1}   #截取字符串，从第1到倒数第1个字节（去头尾）
    debug temp=$temp status=$status
    #开始合图 如果你不知道自己计算机里面有哪些字体
    #使用convert -list font查看并选择一个字体
    convert paper.jpg \
	    -resize 1980x \
	    -fill skyblue \
	    -pointsize 60 \
	    -font 文泉驿等宽正黑 \
	    -draw "fill-opacity 0.6 roundrectangle 180,170 650,550 10,10" \
	    -fill white \
	    -draw "text 200,250 '$temp℃ /$status'" \
	    -pointsize 40  \
	    -draw "text 200,300 '`env LC_ALL=en_US.UTF-8 date "+%a %B"`'" dest.jpg
    #把修改壁纸的语句从downpaper函数挪过来！记住图片名字换成合成图dest而非papaer
    pcmanfm -w `pwd`/dest.jpg
}

downpaper
widgify
