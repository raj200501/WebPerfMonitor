require "./spec_helper"
require "../src/report"

describe WebPerfMonitor::Report do
  it "generates a report" do
    report = WebPerfMonitor::Report.new
    analysis = {"https://example.com" => 0.123}
    report_content = report.generate(analysis)
    report_content.should include "timestamp"
  end
end
