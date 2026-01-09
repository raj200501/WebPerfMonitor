require "./spec_helper.cr"

TestSuite.test("monitor collects metrics") do
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
    "tmp/monitor",
    nil,
    WebPerfMonitor::Thresholds.new,
    WebPerfMonitor::ServerSettings.new
  )

  monitor = WebPerfMonitor::Monitor.new(settings)
  metrics = monitor.collect_metrics

  TestSuite.assert_equal(1, metrics.size)
  TestSuite.assert_equal(200, metrics.first.status_code)
ensure
  server.shutdown if server
end
