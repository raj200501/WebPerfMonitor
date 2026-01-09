require "./spec_helper.cr"

TestSuite.test("webhook client delivers report") do
  port = Support::PortFinder.available_port
  server = Support::HttpServer.new("127.0.0.1", port) do |method, path|
    if method == "POST" && path == "/webhook"
      Support::ServerResponse.new(200, "ok", {"Content-Type" => "text/plain"})
    else
      Support::ServerResponse.new(404, "Not Found", {"Content-Type" => "text/plain"})
    end
  end
  server.start_in_background

  client = WebPerfMonitor::WebhookClient.new("http://127.0.0.1:#{port}/webhook")
  result = client.send("{}")

  TestSuite.assert(result.success)
  TestSuite.assert_equal(200, result.status_code)
ensure
  server.shutdown if server
end
