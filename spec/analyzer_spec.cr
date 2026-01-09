require "./spec_helper.cr"

TestSuite.test("analyzer summarizes metrics") do
  analyzer = WebPerfMonitor::Analyzer.new
  metrics = [
    WebPerfMonitor::Metric.new("https://example.com", 0.1, 200, nil),
    WebPerfMonitor::Metric.new("https://example.com", 0.3, 200, nil),
    WebPerfMonitor::Metric.new("https://example.com", 0.2, 500, "error")
  ]

  analysis = analyzer.analyze(metrics)

  TestSuite.assert_equal(1, analysis.per_site.size)
  TestSuite.assert_equal(1, analysis.total_failures)
  TestSuite.assert_equal(3, analysis.per_site.first.summary.sample_size)
end
