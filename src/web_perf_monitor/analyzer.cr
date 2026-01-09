module WebPerfMonitor
  class Analyzer
    def analyze(metrics)
      grouped = {} of String => Array(Metric)
      metrics.each do |metric|
        grouped[metric.url] ||= []
        grouped[metric.url] << metric
      end

      per_site = [] of SiteAnalysis
      total_failures = 0

      grouped.each do |url, entries|
        samples = entries.map { |entry| entry.response_time_seconds }
        summary = summarize(samples)
        failures = entries.count { |entry| !entry.success? }
        total_failures += failures
        per_site << SiteAnalysis.new(url, summary, failures)
      end

      overall = summarize(metrics.map { |metric| metric.response_time_seconds })
      AnalysisReport.new(per_site, overall, total_failures)
    end

    private def summarize(samples)
      sorted = samples.sort
      size = sorted.size
      min = sorted.first
      max = sorted.last
      total = 0.0
      sorted.each { |value| total += value }
      avg = total / size
      median = percentile(sorted, 0.5)
      p95 = percentile(sorted, 0.95)
      StatSummary.new(min, max, avg, median, p95, size)
    end

    private def percentile(sorted, percentile)
      return sorted.first if sorted.size == 1

      rank = percentile * (sorted.size - 1)
      lower_index = rank.floor.to_i
      upper_index = rank.ceil.to_i
      lower = sorted[lower_index]
      upper = sorted[upper_index]
      weight = rank - lower_index
      lower + (upper - lower) * weight
    end
  end
end
