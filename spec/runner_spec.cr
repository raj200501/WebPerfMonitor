require "./spec_helper.cr"

TestSuite.test("runner executes a monitoring cycle") do
  port = Support::PortFinder.available_port
  server = Support::HttpServer.new("127.0.0.1", port) do |method, path|
    if method == "GET" && path == "/"
      Support::ServerResponse.new(200, "ok", {"Content-Type" => "text/plain"})
    else
      Support::ServerResponse.new(404, "Not Found", {"Content-Type" => "text/plain"})
    end
  end
  server.start_in_background

  settings = WebPerfMonitor::Settings.new(
    ["http://127.0.0.1:#{port}"],
    1,
    2.0,
    "tmp/runner",
    nil,
    WebPerfMonitor::Thresholds.new,
    WebPerfMonitor::ServerSettings.new
  )

  runner = WebPerfMonitor::Runner.new(settings)
  result = runner.run_once

  TestSuite.assert(Support::FileUtil.file_exists?(result.output.path))
ensure
  server.shutdown if server
end
