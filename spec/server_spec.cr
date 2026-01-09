require "./spec_helper.cr"

TestSuite.test("report server serves health and latest report") do
  output_dir = "tmp/spec-server"
  Support::FileUtil.mkdir_p(output_dir)
  store = WebPerfMonitor::FileStore.new(output_dir)
  store.write("{\"ok\": true}", "2024-01-01T00:00:00Z")

  port = Support::PortFinder.available_port
  settings = WebPerfMonitor::Settings.new(
    ["https://example.com"],
    1,
    1.0,
    output_dir,
    nil,
    WebPerfMonitor::Thresholds.new,
    WebPerfMonitor::ServerSettings.new(true, "127.0.0.1", port)
  )

  server = WebPerfMonitor::ReportServer.new(settings, store)
  server.start_in_background

  health = Support::HttpClient.get("http://127.0.0.1:#{port}/health", 2.0)
  TestSuite.assert_equal(200, health.status_code)
  TestSuite.assert_equal("ok", health.body)

  latest = Support::HttpClient.get("http://127.0.0.1:#{port}/latest", 2.0)
  TestSuite.assert_equal(200, latest.status_code)
  TestSuite.assert_includes(latest.body, "ok")
ensure
  server.shutdown if server
end
