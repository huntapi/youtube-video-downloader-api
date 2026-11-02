// YouTube Video Download API – C# example (.NET 6+, top-level statements)
// Usage: dotnet new console -n Example && copy this file to Program.cs, then HUNTAPI_API_KEY=your-key dotnet run
using System.Text;
using System.Text.Json;

var apiKey = Environment.GetEnvironmentVariable("HUNTAPI_API_KEY") ?? throw new InvalidOperationException("Set HUNTAPI_API_KEY");
using var http = new HttpClient { Timeout = TimeSpan.FromSeconds(120) };
http.DefaultRequestHeaders.Add("x-api-key", apiKey);

var query = "query=" + Uri.EscapeDataString("https://www.youtube.com/watch?v=Z5YP8kznWZs") + "&" +
    "video_quality=" + Uri.EscapeDataString("720p") + "&" +
    "video_format=" + Uri.EscapeDataString("mp4");
var response = await http.GetAsync("https://api.huntapi.com/v1/video/download" + (query.Length > 0 ? "?" + query : ""));
if (!response.IsSuccessStatusCode)
{
    Console.Error.WriteLine($"HTTP {(int)response.StatusCode}: {await response.Content.ReadAsStringAsync()}");
    return;
}

var jobId = JsonDocument.Parse(await response.Content.ReadAsStringAsync()).RootElement.GetProperty("job_id").GetString();
var done = new HashSet<string> { "CompletedJob", "Error", "NotFound", "BadRequest" };
JsonElement job = default;
var status = "";
for (var i = 0; i < 4320 && !done.Contains(status); i++) // give up after 12 hours
{
    await Task.Delay(10000);
    job = JsonDocument.Parse(await http.GetStringAsync($"https://api.huntapi.com/v1/jobs/{jobId}")).RootElement; // throws on HTTP errors
    status = job.GetProperty("status").GetString()!;
    Console.WriteLine(status);
}
if (status != "CompletedJob")
{
    Console.Error.WriteLine($"Job {jobId} not completed: {status}");
    Environment.Exit(1);
}
Console.WriteLine(job.GetProperty("result"));
