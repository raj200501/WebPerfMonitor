module WebPerfMonitor
  class Analyzer
    def analyze(metrics : Array(Hash(String, Float64))) : Hash(String, Float64)
      analysis = Hash(String, Float64).new

      metrics.each do |metric|
        website = metric["website"]
        response_time = metric["response_time"]

        analysis[website] = response_time
      end

      analysis
    end
  end
end
