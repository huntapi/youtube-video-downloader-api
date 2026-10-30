// YouTube Metadata API – Node.js example (Node 18+, ES module)
// Usage: HUNTAPI_API_KEY=your-key node media_metadata.mjs

const headers = { "x-api-key": process.env.HUNTAPI_API_KEY, "Content-Type": "application/json" };

const params = new URLSearchParams({
  "query": "https://www.youtube.com/watch?v=Z5YP8kznWZs",
});
const response = await fetch(`https://api.huntapi.com/v1/media/metadata?${params}`, { headers });
if (!response.ok) {
  console.error(`HTTP ${response.status}: ${await response.text()}`);
  process.exit(1);
}

console.log(JSON.stringify(await response.json(), null, 2));
