module WebPerfMonitor
  class RunResult
    def initialize(report, output, webhook_result)
      @report = report
      @output = output
      @webhook_result = webhook_result
    end

    def report
      @report
    end

    def output
      @output
    end

    def webhook_result
      @webhook_result
    end
  end

  class Runner
    def initialize(settings)
      @settings = settings
      @monitor = Monitor.new(@settings)
      @analyzer = Analyzer.new
      @reporter = Report.new
      @recommendations = RecommendationEngine.new(@settings.thresholds)
      @store = FileStore.new(@settings.report_output_dir)
    end

    def run_once
      metrics = @monitor.collect_metrics
      analysis = @analyzer.analyze(metrics)
      recommendations = @recommendations.generate(analysis)
      report = @reporter.generate(metrics, analysis, recommendations)
      json = @reporter.to_json(report, true)
      output = @store.write(json, report.timestamp)
      webhook_result = send_webhook(json)
      RunResult.new(report, output, webhook_result)
    end

    def run_forever
      loop do
        result = run_once
        puts "Report written to #{result.output.path}"
        if result.webhook_result
          puts "Webhook result: #{result.webhook_result.message}"
        end
        sleep @settings.monitor_interval_seconds
      end
    end

    private def send_webhook(report_json)
      return nil unless @settings.webhook_url

      client = WebhookClient.new(@settings.webhook_url)
      client.send(report_json)
    end
  end
end
