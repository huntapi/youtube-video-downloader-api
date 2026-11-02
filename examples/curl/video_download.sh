#!/usr/bin/env bash
# YouTube Video Download API – cURL example
# Usage: HUNTAPI_API_KEY=your-key bash video_download.sh
set -euo pipefail

RESPONSE=$(curl -sS --fail-with-body -G "https://api.huntapi.com/v1/video/download" \
  -H "x-api-key: ${HUNTAPI_API_KEY}" \
  --data-urlencode 'query=https://www.youtube.com/watch?v=Z5YP8kznWZs' \
  --data-urlencode video_quality=720p \
  --data-urlencode video_format=mp4) || { echo "$RESPONSE" >&2; exit 1; }
JOB_ID=$(echo "$RESPONSE" | sed -E 's/.*"job_id" *: *"([^"]+)".*/\1/')
echo "job: $JOB_ID"

STATUS=""
for _ in $(seq 4320); do  # give up after 12 hours
  sleep 10
  JOB=$(curl -sS --fail-with-body "https://api.huntapi.com/v1/jobs/$JOB_ID" -H "x-api-key: ${HUNTAPI_API_KEY}") || { echo "$JOB" >&2; exit 1; }
  STATUS=$(echo "$JOB" | sed -E 's/.*"status" *: *"([^"]+)".*/\1/')
  echo "status: $STATUS"
  case "$STATUS" in CompletedJob|Error|NotFound|BadRequest) break ;; esac
done

echo "$JOB"
[ "$STATUS" = "CompletedJob" ] || { echo "Job $JOB_ID not completed: $STATUS" >&2; exit 1; }
