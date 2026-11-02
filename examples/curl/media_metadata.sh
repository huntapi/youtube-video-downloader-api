#!/usr/bin/env bash
# YouTube Metadata API – cURL example
# Usage: HUNTAPI_API_KEY=your-key bash media_metadata.sh
set -euo pipefail

curl -sS --fail-with-body -G "https://api.huntapi.com/v1/media/metadata" \
  -H "x-api-key: ${HUNTAPI_API_KEY}" \
  --data-urlencode 'query=https://www.youtube.com/watch?v=Z5YP8kznWZs'
