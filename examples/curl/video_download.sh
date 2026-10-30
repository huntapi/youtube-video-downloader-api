#!/usr/bin/env bash
# YouTube Video Download API – cURL example
# Usage: HUNTAPI_API_KEY=your-key bash video_download.sh
set -euo pipefail

RESPONSE=$(curl -sS -G "https://api.huntapi.com/v1/video/download" \
  -H "x-api-key: ${HUNTAPI_API_KEY}" \
  --data-urlencode 'query=https://www.youtube.com/watch?v=Z5YP8kznWZs' \
  --data-urlencode video_quality=720p \
  --data-urlencode video_format=mp4)
JOB_ID=$(echo "$RESPONSE" | sed -E 's/.*"job_id" *: *"([^"]+)".*/\1/')
echo "job: $JOB_ID"

while true; do
  sleep 5
  JOB=$(curl -sS "https://api.huntapi.com/v1/jobs/$JOB_ID" -H "x-api-key: ${HUNTAPI_API_KEY}")
  STATUS=$(echo "$JOB" | sed -E 's/.*"status" *: *"([^"]+)".*/\1/')
  echo "status: $STATUS"
  case "$STATUS" in CompletedJob|Error|NotFound|BadRequest) break ;; esac
done

echo "$JOB"
