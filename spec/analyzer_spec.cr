require "./spec_helper"
require "../src/analyzer"

describe WebPerfMonitor::Analyzer do
  it "analyzes metrics" do
    analyzer = WebPerfMonitor::Analyzer.new
    metrics = [{"website" => "https://example.com", "response_time" => 0.123}]
    analysis = analyzer.analyze(metrics)
    analysis.should_not be_empty
  end
end
