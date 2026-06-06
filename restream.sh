#!/bin/bash

mkdir -p hls
mkdir -p hls_archive

SOURCE_URL="http://vlue.vip/live/778047230676/806944331192/789897.m3u8"
LOGO_URL="https://up6.cc/2026/06/178065057949411.png"

wget -O logo.png "$LOGO_URL"

# مراقبة مجلد hls ورفع الملفات فوراً
upload_segment() {
    local file=$1
    git add "$file" 2>/dev/null && git commit -m "رفع $file $(date +%H:%M:%S)" --quiet
}

export -f upload_segment

while true; do
    echo "بدء البث..."
    
    # تشغيل ffmpeg مع إعادة تعيين الملفات القديمة
    ffmpeg -re \
           -user_agent "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36" \
           -i "$SOURCE_URL" \
           -i logo.png \
           -filter_complex \
           "[1:v]scale=100:-1[logo];[0:v][logo]overlay=10:main_h-overlay_h-10[vout]" \
           -map "[vout]" -c:v libx264 -b:v 2000k -preset superfast -g 50 \
           -map 0:a -c:a aac -b:a 128k \
           -f hls -hls_time 2 -hls_list_size 0 -hls_flags append_list+delete_segments+omit_endlist \
           -hls_segment_filename "hls/segment_%06d.ts" \
           hls/master.m3u8 &
    
    FFMPEG_PID=$!
    
    # مراقبة الملفات الجديدة ورفعها فوراً
    inotifywait -m hls -e close_write -e moved_to --format '%f' . 2>/dev/null | while read filename; do
        if [[ "$filename" =~ ^(segment_.*\.ts|master\.m3u8)$ ]]; then
            git add "hls/$filename"
            git commit -m "رفع $filename $(date +%H:%M:%S)" --quiet
            git push origin main --quiet
        fi
    done
    
    wait $FFMPEG_PID
    
    echo "البث توقف، إعادة تشغيل بعد 10 ثواني..."
    sleep 10
done
