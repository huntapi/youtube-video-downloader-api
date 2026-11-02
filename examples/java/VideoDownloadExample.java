// YouTube Video Download API – Java example (Java 15+)
// Usage: HUNTAPI_API_KEY=your-key java VideoDownloadExample.java
import java.net.URI;
import java.net.URLEncoder;
import java.net.http.HttpClient;
import java.net.http.HttpRequest;
import java.net.http.HttpResponse;
import java.nio.charset.StandardCharsets;
import java.nio.file.Files;
import java.nio.file.Path;
import java.time.Duration;
import java.util.Set;
import java.util.regex.Matcher;
import java.util.regex.Pattern;

public class VideoDownloadExample {
    static final HttpClient CLIENT = HttpClient.newHttpClient();
    static final String KEY = System.getenv("HUNTAPI_API_KEY");

    static String enc(String v) {
        return URLEncoder.encode(v, StandardCharsets.UTF_8);
    }

    static HttpResponse<byte[]> call(String method, String url, String body) throws Exception {
        HttpRequest.Builder b = HttpRequest.newBuilder().uri(URI.create(url)).header("x-api-key", KEY)
            .timeout(Duration.ofSeconds(120));
        b = body == null ? b.method(method, HttpRequest.BodyPublishers.noBody())
            : b.header("Content-Type", "application/json").method(method, HttpRequest.BodyPublishers.ofString(body));
        HttpResponse<byte[]> r = CLIENT.send(b.build(), HttpResponse.BodyHandlers.ofByteArray());
        if (r.statusCode() >= 400) {
            System.err.println("HTTP " + r.statusCode() + ": " + new String(r.body(), StandardCharsets.UTF_8));
            System.exit(1);
        }
        return r;
    }

    static String field(String json, String name) {
        Matcher m = Pattern.compile("\"" + name + "\"\\s*:\\s*\"([^\"]*)\"").matcher(json);
        return m.find() ? m.group(1) : "";
    }

    public static void main(String[] args) throws Exception {
        String query = "query=" + enc("https://www.youtube.com/watch?v=Z5YP8kznWZs") + "&"
            + "video_quality=" + enc("720p") + "&"
            + "video_format=" + enc("mp4");
        HttpResponse<byte[]> response = call("GET", "https://api.huntapi.com/v1/video/download" + (query.isEmpty() ? "" : "?" + query), null);
        String jobId = field(new String(response.body(), StandardCharsets.UTF_8), "job_id");
        Set<String> done = Set.of("CompletedJob", "Error", "NotFound", "BadRequest");
        String job = "";
        String status = "";
        for (int i = 0; i < 4320 && !done.contains(status); i++) { // give up after 12 hours
            Thread.sleep(10000);
            job = new String(call("GET", "https://api.huntapi.com/v1/jobs/" + jobId + "", null).body(), StandardCharsets.UTF_8);
            status = field(job, "status");
            System.out.println(status);
        }
        System.out.println(job);
        if (!status.equals("CompletedJob")) {
            System.err.println("Job " + jobId + " not completed: " + status);
            System.exit(1);
        }
    }
}
