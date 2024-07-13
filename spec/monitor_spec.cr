require "./spec_helper"
require "../src/monitor"

describe WebPerfMonitor::Monitor do
  it "collects metrics" do
    monitor = WebPerfMonitor::Monitor.new
    metrics = monitor.collect_metrics
    metrics.should_not be_empty
  end
end
