# YouTube Video Download API – Ruby example (stdlib only)
# Usage: HUNTAPI_API_KEY=your-key ruby video_download.rb
require "json"
require "net/http"
require "uri"

def call(method, url, body = nil)
  uri = URI(url)
  klass = { "GET" => Net::HTTP::Get, "POST" => Net::HTTP::Post, "PUT" => Net::HTTP::Put, "PATCH" => Net::HTTP::Patch }[method]
  req = klass.new(uri)
  req["x-api-key"] = ENV.fetch("HUNTAPI_API_KEY")
  if body
    req["Content-Type"] = "application/json"
    req.body = body
  end
  res = Net::HTTP.start(uri.host, uri.port, use_ssl: true, read_timeout: 120) { |http| http.request(req) }
  abort "HTTP #{res.code}: #{res.body}" unless res.is_a?(Net::HTTPSuccess)
  res.body
end

uri = URI("https://api.huntapi.com/v1/video/download")
uri.query = URI.encode_www_form('query' => 'https://www.youtube.com/watch?v=Z5YP8kznWZs', 'video_quality' => '720p', 'video_format' => 'mp4')
response = call("GET", uri.to_s)

job_id = JSON.parse(response).fetch("job_id")
job = {}
4320.times do # give up after 12 hours
  sleep 10
  job = JSON.parse(call("GET", "https://api.huntapi.com/v1/jobs/#{job_id}"))
  puts "#{job['status']} #{job['progress']}"
  break if ["CompletedJob", "Error", "NotFound", "BadRequest"].include?(job["status"])
end

puts JSON.pretty_generate(job["result"] || {})
abort "Job #{job_id} not completed: #{job['status']}" unless job["status"] == "CompletedJob"
