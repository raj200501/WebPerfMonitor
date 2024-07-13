require "json"

module WebPerfMonitor
  class Report
    def generate(analysis : Hash(String, Float64)) : String
      report = { "timestamp" => Time.now.to_s, "analysis" => analysis }
      report.to_json
    end
  end
end
