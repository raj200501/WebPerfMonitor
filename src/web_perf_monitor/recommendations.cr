module WebPerfMonitor
  class RecommendationEngine
    def initialize(thresholds)
      @thresholds = thresholds
    end

    def generate(analysis)
      recommendations = [] of Recommendation

      analysis.per_site.each do |site|
        max_seconds = site.summary.max_seconds
        if max_seconds >= @thresholds.critical_seconds
          recommendations << Recommendation.new(
            site.url,
            "critical",
            "Response time exceeded #{@thresholds.critical_seconds}s. Investigate backend latency or caching."
          )
        elsif max_seconds >= @thresholds.warning_seconds
          recommendations << Recommendation.new(
            site.url,
            "warning",
            "Response time exceeded #{@thresholds.warning_seconds}s. Consider optimizing assets or network paths."
          )
        end

        if site.failures > 0
          recommendations << Recommendation.new(
            site.url,
            "warning",
            "Observed #{site.failures} failed checks. Review uptime or error rates."
          )
        end
      end

      recommendations
    end
  end
end
