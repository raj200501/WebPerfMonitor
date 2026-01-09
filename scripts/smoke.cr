require "../src/web_perf_monitor.cr"

module WebPerfMonitor
  class SmokeTest
    def run
      target_port = Support::PortFinder.available_port
      webhook_port = Support::PortFinder.available_port
      report_dir = "tmp/smoke-reports"

      target_server = Support::HttpServer.new("127.0.0.1", target_port) do |method, path|
        if method == "GET" && path == "/"
          Support::ServerResponse.new(200, "ok", {"Content-Type" => "text/plain"})
        else
          Support::ServerResponse.new(404, "Not Found", {"Content-Type" => "text/plain"})
        end
      end

      webhook_server = Support::HttpServer.new("127.0.0.1", webhook_port) do |method, path|
        if method == "POST" && path == "/webhook"
          Support::ServerResponse.new(200, "received", {"Content-Type" => "text/plain"})
        else
          Support::ServerResponse.new(404, "Not Found", {"Content-Type" => "text/plain"})
        end
      end

      target_server.start_in_background
      webhook_server.start_in_background

      settings = Settings.new(
        ["http://127.0.0.1:#{target_port}"],
        1,
        2.0,
        report_dir,
        "http://127.0.0.1:#{webhook_port}/webhook",
        Thresholds.new(0.1, 1.0),
        ServerSettings.new(false, "127.0.0.1", 4001)
      )

      runner = Runner.new(settings)
      result = runner.run_once

      unless Support::FileUtil.file_exists?(result.output.path)
        raise "Expected report at #{result.output.path}, but file is missing"
      end

      parsed = Support::JsonUtil.parse(File.read(result.output.path))
      url_value = Support::JsonUtil.value_at(parsed, ["metrics", 0, "url"])
      url = Support::JsonUtil.to_string(url_value)
      if url != "http://127.0.0.1:#{target_port}"
        raise "Unexpected URL in report: #{url}"
      end

      webhook = result.webhook_result
      if webhook.nil? || !webhook.success
        raise "Expected webhook to be delivered"
      end

      puts "Smoke test passed"
    ensure
      target_server.shutdown if target_server
      webhook_server.shutdown if webhook_server
    end
  end
end

WebPerfMonitor::SmokeTest.new.run
