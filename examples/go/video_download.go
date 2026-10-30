// YouTube Video Download API – Go example
// Usage: HUNTAPI_API_KEY=your-key go run video_download.go
package main

import (
	"bytes"
	"encoding/json"
	"fmt"
	"io"
	"net/http"
	"net/url"
	"os"
	"time"
)

var client = &http.Client{Timeout: 120 * time.Second}

func call(method, target string, body []byte) []byte {
	var reader io.Reader
	if body != nil {
		reader = bytes.NewReader(body)
	}
	req, _ := http.NewRequest(method, target, reader)
	req.Header.Set("x-api-key", os.Getenv("HUNTAPI_API_KEY"))
	if body != nil {
		req.Header.Set("Content-Type", "application/json")
	}
	resp, err := client.Do(req)
	if err != nil {
		panic(err)
	}
	defer resp.Body.Close()
	data, _ := io.ReadAll(resp.Body)
	if resp.StatusCode >= 400 {
		fmt.Fprintf(os.Stderr, "HTTP %d: %s\n", resp.StatusCode, data)
		os.Exit(1)
	}
	return data
}

func main() {
	_ = url.Values{}
	_ = json.Valid
	params := url.Values{}
	params.Set("query", "https://www.youtube.com/watch?v=Z5YP8kznWZs")
	params.Set("video_quality", "720p")
	params.Set("video_format", "mp4")
	target := "https://api.huntapi.com/v1/video/download"
	if len(params) > 0 {
		target += "?" + params.Encode()
	}
	data := call("GET", target, nil)

	var submitted map[string]any
	json.Unmarshal(data, &submitted)
	jobID := fmt.Sprint(submitted["job_id"])
	var job map[string]any
	for {
		time.Sleep(5 * time.Second)
		json.Unmarshal(call("GET", "https://api.huntapi.com/v1/jobs/"+jobID+"", nil), &job)
		status := fmt.Sprint(job["status"])
		fmt.Println(status, job["progress"])
		if status == "CompletedJob" || status == "Error" || status == "NotFound" || status == "BadRequest" {
			break
		}
	}
	out, _ := json.MarshalIndent(job["result"], "", "  ")
	fmt.Println(string(out))
}
