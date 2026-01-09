require "./spec_helper.cr"

TestSuite.test("report generates json") do
  report = WebPerfMonitor::Report.new
  metrics = [WebPerfMonitor::Metric.new("https://example.com", 0.2, 200, nil)]
  analysis = WebPerfMonitor::Analyzer.new.analyze(metrics)
  recommendations = WebPerfMonitor::RecommendationEngine.new(WebPerfMonitor::Thresholds.new).generate(analysis)

  report_data = report.generate(metrics, analysis, recommendations)
  json = report.to_json(report_data, true)

  TestSuite.assert_includes(json, "timestamp")
  TestSuite.assert_includes(json, "metrics")
end
