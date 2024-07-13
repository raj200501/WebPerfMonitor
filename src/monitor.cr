require "http/client"

module WebPerfMonitor
  class Monitor
    def collect_metrics
      metrics = [] of Hash(String, Float64)

      Config::WEBSITES.each do |website|
        response_time = measure_response_time(website)
        metrics << { "website" => website, "response_time" => response_time }
      end

      metrics
    end

    private def measure_response_time(url : String) : Float64
      start_time = Time.monotonic
      HTTP::Client.get(url)
      end_time = Time.monotonic

      (end_time - start_time).total_seconds
    end
  end
end
