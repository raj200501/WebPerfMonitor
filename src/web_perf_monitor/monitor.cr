module WebPerfMonitor
  class Monitor
    def initialize(settings)
      @settings = settings
    end

    def collect_metrics
      metrics = []
      @settings.websites.each do |website|
        metrics << measure(website)
      end
      metrics
    end

    private def measure(url)
      start_time = Support::TimeUtil.monotonic
      response = Support::HttpClient.get(url, @settings.request_timeout_seconds)
      duration = Support::TimeUtil.monotonic - start_time
      Metric.new(url, duration, response.status_code, nil)
    rescue ex : Exception
      duration = Support::TimeUtil.monotonic - start_time
      Metric.new(url, duration, nil, ex.message)
    end
  end
end
