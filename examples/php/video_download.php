<?php
// YouTube Video Download API – PHP example (ext-curl)
// Usage: HUNTAPI_API_KEY=your-key php video_download.php

function call(string $method, string $url, ?string $body = null): string
{
    $ch = curl_init($url);
    $headers = ['x-api-key: ' . getenv('HUNTAPI_API_KEY')];
    if ($body !== null) {
        $headers[] = 'Content-Type: application/json';
        curl_setopt($ch, CURLOPT_POSTFIELDS, $body);
    }
    curl_setopt_array($ch, [
        CURLOPT_CUSTOMREQUEST => $method,
        CURLOPT_RETURNTRANSFER => true,
        CURLOPT_TIMEOUT => 120,
        CURLOPT_HTTPHEADER => $headers,
    ]);
    $res = curl_exec($ch);
    $status = curl_getinfo($ch, CURLINFO_HTTP_CODE);
    curl_close($ch);
    if ($status >= 400) {
        fwrite(STDERR, "HTTP $status: $res\n");
        exit(1);
    }
    return $res;
}

$query = http_build_query([
    'query' => 'https://www.youtube.com/watch?v=Z5YP8kznWZs',
    'video_quality' => '720p',
    'video_format' => 'mp4'
]);
$response = call('GET', 'https://api.huntapi.com/v1/video/download' . ($query ? '?' . $query : ''));

$jobId = json_decode($response, true)['job_id'];
$job = null;
for ($i = 0; $i < 4320; $i++) { // give up after 12 hours
    sleep(10);
    $job = json_decode(call('GET', 'https://api.huntapi.com/v1/jobs/' . $jobId . ''), true);
    echo $job['status'], ' ', $job['progress'] ?? '', PHP_EOL;
    if (in_array($job['status'], ['CompletedJob', 'Error', 'NotFound', 'BadRequest'], true)) break;
}

echo json_encode($job['result'] ?? null, JSON_PRETTY_PRINT | JSON_UNESCAPED_SLASHES), PHP_EOL;
if (($job['status'] ?? '') !== 'CompletedJob') {
    fwrite(STDERR, "Job $jobId not completed: " . ($job['status'] ?? 'unknown') . "\n");
    exit(1);
}
