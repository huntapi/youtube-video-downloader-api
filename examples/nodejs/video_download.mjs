// YouTube Video Download API – Node.js example (Node 18+, ES module)
// Usage: HUNTAPI_API_KEY=your-key node video_download.mjs

const headers = { "x-api-key": process.env.HUNTAPI_API_KEY, "Content-Type": "application/json" };

const params = new URLSearchParams({
  "query": "https://www.youtube.com/watch?v=Z5YP8kznWZs",
  "video_quality": "720p",
  "video_format": "mp4",
});
const response = await fetch(`https://api.huntapi.com/v1/video/download?${params}`, { headers });
if (!response.ok) {
  console.error(`HTTP ${response.status}: ${await response.text()}`);
  process.exit(1);
}

const { job_id: jobId } = await response.json();
const done = new Set(["CompletedJob", "Error", "NotFound", "BadRequest"]);
let job;
for (let i = 0; i < 4320; i++) { // give up after 12 hours
  await new Promise((r) => setTimeout(r, 10000));
  const poll = await fetch(`https://api.huntapi.com/v1/jobs/${jobId}`, { headers });
  if (!poll.ok) {
    console.error(`HTTP ${poll.status}: ${await poll.text()}`);
    process.exit(1);
  }
  job = await poll.json();
  console.log(job.status, job.progress);
  if (done.has(job.status)) break;
}

console.log(JSON.stringify(job?.result, null, 2));
if (job?.status !== "CompletedJob") {
  console.error(`Job ${jobId} not completed: ${job?.status}`);
  process.exit(1);
}
