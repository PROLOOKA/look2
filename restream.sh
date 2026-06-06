#!/bin/bash

mkdir -p hls
rm -rf hls/*

SOURCE_URL="http://vlue.vip/live/778047230676/806944331192/789897.m3u8"
LOGO_URL="https://up6.cc/2026/06/178065057949411.png"

wget -O logo.png "$LOGO_URL"

# إنشاء فيديو أسود احتياطي (شاشة سوداء ثابتة 24 ساعة)
ffmpeg -f lavfi -i color=c=black:s=1280x720:r=25:d=864000 -f lavfi -i anullsrc=channel_layout=stereo:sample_rate=48000 -shortest -c:v libx264 -c:a aac -t 864000 backup.mp4

while true; do
    echo "بدء البث مع Backup..."
    
    ffmpeg -re \
           -stream_loop -1 -i backup.mp4 \
           -user_agent "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36" \
           -i "$SOURCE_URL" \
           -i logo.png \
           -filter_complex \
           "[1:v]scale=1280:720:force_original_aspect_ratio=decrease,pad=1280:720:(ow-iw)/2:(oh-ih)/2[source]; \
            [0:v]scale=1280:720[backup]; \
            [source][backup]blend=all_expr='A*(gte(T,2))+B*(lt(T,2))'[video_clean]; \
            [video_clean]split=3[v1][v2][v3]; \
            [2:v]scale=100:-1[logo]; \
            [v1][logo]overlay=10:main_h-overlay_h-10[v1out]; \
            [v2][logo]overlay=10:main_h-overlay_h-10[v2out]; \
            [v3][logo]overlay=10:main_h-overlay_h-10[v3out]; \
            [v1out]scale=1280:720[v1final]; \
            [v2out]scale=854:480[v2final]; \
            [v3out]scale=640:360[v3final]" \
           -map "[v1final]" -c:v:0 libx264 -b:v:0 2500k -preset superfast -g 50 \
           -map "[v2final]" -c:v:1 libx264 -b:v:1 1000k -preset superfast -g 50 \
           -map "[v3final]" -c:v:2 libx264 -b:v:2 600k -preset superfast -g 50 \
           -map 1:a -c:a:0 aac -b:a:0 128k \
           -map 1:a -c:a:1 aac -b:a:1 128k \
           -map 1:a -c:a:2 aac -b:a:2 64k \
           -f hls \
           -hls_time 6 \
           -hls_list_size 10 \
           -hls_flags delete_segments+omit_endlist \
           -master_pl_name master.m3u8 \
           -var_stream_map "v:0,a:0 v:1,a:1 v:2,a:2" \
           hls/v%v.m3u8
    
    echo "⚠️ انقطاع، إعادة المحاولة بعد 3 ثواني..."
    sleep 3
done
