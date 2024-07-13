require "./spec_helper"
require "../src/integration"
require "http/mock"

describe WebPerfMonitor::Integration do
  it "sends report to Apple tools" do
    report = "{\"timestamp\": \"2024-07-09T12:00:00Z\", \"analysis\": {\"https://example.com\": 0.123}}"

    HTTP::Mock.start do |request|
      request.post(WebPerfMonitor::Integration::APPLE_API_ENDPOINT, body: report).to_return(status_code: 200)
      response = WebPerfMonitor::Integration.send_to_apple_tools(report)
      response.should eq "Successfully sent report to Apple tools"
    end
  end

  it "handles failure when sending report to Apple tools" do
    report = "{\"timestamp\": \"2024-07-09T12:00:00Z\", \"analysis\": {\"https://example.com\": 0.123}}"

    HTTP::Mock.start do |request|
      request.post(WebPerfMonitor::Integration::APPLE_API_ENDPOINT, body: report).to_return(status_code: 500, body: "Internal Server Error")
      response = WebPerfMonitor::Integration.send_to_apple_tools(report)
      response.should eq "Failed to send report to Apple tools: 500 - Internal Server Error"
    end
  end
end
