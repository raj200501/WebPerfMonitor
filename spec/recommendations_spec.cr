require "./spec_helper.cr"

TestSuite.test("recommendations produce critical alerts") do
  analyzer = WebPerfMonitor::Analyzer.new
  metrics = [
    WebPerfMonitor::Metric.new("https://slow.example.com", 2.0, 200, nil),
    WebPerfMonitor::Metric.new("https://slow.example.com", 1.8, 200, nil)
  ]
  analysis = analyzer.analyze(metrics)
  engine = WebPerfMonitor::RecommendationEngine.new(WebPerfMonitor::Thresholds.new(0.5, 1.0))
  recommendations = engine.generate(analysis)

  TestSuite.assert(!recommendations.empty?, "Expected recommendations")
  TestSuite.assert_equal("critical", recommendations.first.severity)
end
