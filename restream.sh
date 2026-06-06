#!/bin/bash

mkdir -p hls
rm -rf hls/*

SOURCE_URL="http://gooon.tv:8080/play/link/6aa38f85-dafa-426e-bbd3-20ca86d89ac1/eyJpdiI6Ino0ZnNJZUs3UERoUmFqclBVVDRTUFE9PSIsInZhbHVlIjoiMEpDWlRPaDlXbktiR01IUmVVTitKNW45V1kxWkxKQlVXTGtJWHRRZU1QSnFieXpOSXVKaFd1MXBJV2l4ZjhuUCIsIm1hYyI6IjhhYTljM2E4NTUyZGExZWMxNGYwNGRhNzA4ZjY5MGZiYjBkNWZjYmVhMjQwNjdjZGMyOWI0YmNhN2MyMTQ0ZDciLCJ0YWciOiIifQ==.m3u8"
LOGO_URL="https://up6.cc/2026/06/178065057949411.png"

wget -O logo.png "$LOGO_URL"

while true; do
    echo "بدء البث..."
    ffmpeg -re \
           -user_agent "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36" \
           -i "$SOURCE_URL" \
           -i logo.png \
           -filter_complex \
           "[1:v]scale=100:-1[logo];[0:v][logo]overlay=10:main_h-overlay_h-10[vout]" \
           -map "[vout]" -c:v libx264 -b:v 2000k -preset superfast -g 50 \
           -map 0:a -c:a aac -b:a 128k \
           -f hls -hls_time 2 -hls_list_size 300 -hls_flags delete_segments+omit_endlist \
           -hls_segment_filename "hls/segment_%03d.ts" \
           hls/master.m3u8
    echo "البث توقف، إعادة تشغيل بعد 30 ثانية..."
    sleep 30
done
