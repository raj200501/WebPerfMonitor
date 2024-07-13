require "./monitor"
require "./analyzer"
require "./report"
require "./integration"

module WebPerfMonitor
  def self.run
    monitor = Monitor.new
    analyzer = Analyzer.new
    report = Report.new

    loop do
      metrics = monitor.collect_metrics
      analysis = analyzer.analyze(metrics)
      report.generate(analysis)

      Integration.send_to_apple_tools(report)

      sleep Config::MONITOR_INTERVAL
    end
  end
end

WebPerfMonitor.run
