name: 24/7 Live Stream

on:
  workflow_dispatch:
  schedule:
    - cron: '0 */5 * * *'

permissions:
  contents: write

jobs:
  stream:
    runs-on: ubuntu-latest
    timeout-minutes: 350
    
    steps:
      - uses: actions/checkout@v4

      - name: تثبيت FFmpeg
        run: |
          sudo apt-get update
          sudo apt-get install -y ffmpeg

      - name: إعداد Git
        run: |
          git config user.name "StreamBot"
          git config user.email "bot@github.com"

      - name: تشغيل البث والرفع التلقائي
        run: |
          chmod +x restream.sh
          
          # تشغيل البث في الخلفية
          bash restream.sh &
          
          # رفع الملفات كل 30 ثانية
          while true; do
            sleep 30
            
            # إضافة جميع ملفات HLS
            git add hls/*.ts hls/*.m3u8 2>/dev/null
            
            # commit و push إذا وجدت تغييرات
            if ! git diff --cached --quiet; then
              git commit -m "تحديث البث المستمر $(date '+%Y-%m-%d %H:%M:%S')"
              git push origin main
              echo "✅ تم رفع الملفات - $(date)"
            fi
          done
