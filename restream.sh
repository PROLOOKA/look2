#!/bin/bash

# إعداد المجلدات
mkdir -p hls
rm -rf hls/*

# الروابط الخاصة بك (ضع روابطك هنا)
SOURCE_URL="http://vlue.vip/live/778047230676/806944331192/789897.m3u8"
LOGO_URL="https://up6.cc/2026/06/178065057949411.png"

# تحميل الشعار
wget -O logo.png "$LOGO_URL"

# تشغيل ffmpeg بجودات متعددة
ffmpeg -re -i "$SOURCE_URL" -i logo.png \
-filter_complex \
"[1:v]scale=100:-1[logo]; \
 [0:v][logo]overlay=10:main_h-overlay_h-10[v_logo]; \
 [v_logo]split=3[v1][v2][v3]; \
 [v1]scale=1280:720[v1out]; \
 [v2]scale=854:480[v2out]; \
 [v3]scale=640:360[v3out]" \
-map "[v1out]" -c:v:0 libx264 -b:v:0 2500k -preset superfast -g 50 \
-map "[v2out]" -c:v:1 libx264 -b:v:1 1000k -preset superfast -g 50 \
-map "[v3out]" -c:v:2 libx264 -b:v:2 600k -preset superfast -g 50 \
-map 0:a -c:a:0 aac -b:a:0 128k \
-map 0:a -c:a:1 aac -b:a:1 128k \
-map 0:a -c:a:2 aac -b:a:2 64k \
-f hls \
-hls_time 6 \
-hls_list_size 5 \
-hls_flags delete_segments \
-master_pl_name master.m3u8 \
-var_stream_map "v:0,a:0 v:1,a:1 v:2,a:2" \
hls/v%v.m3u8
