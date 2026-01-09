module WebPerfMonitor
  class Report
    def generate(metrics, analysis, recommendations)
      timestamp = Support::TimeUtil.now_iso8601
      ReportData.new(timestamp, metrics, analysis, recommendations)
    end

    def to_json(report, pretty = true)
      payload = to_hash(report)
      json = payload.to_json
      return json unless pretty

      Support::JsonUtil.pretty(json)
    end

    private def to_hash(report)
      {
        "timestamp" => report.timestamp,
        "metrics" => report.metrics.map { |metric| metric_to_hash(metric) },
        "analysis" => analysis_to_hash(report.analysis),
        "recommendations" => report.recommendations.map { |rec| recommendation_to_hash(rec) }
      }
    end

    private def metric_to_hash(metric)
      {
        "url" => metric.url,
        "response_time_seconds" => metric.response_time_seconds,
        "status_code" => metric.status_code,
        "error" => metric.error
      }
    end

    private def analysis_to_hash(analysis)
      {
        "per_site" => analysis.per_site.map { |site| site_to_hash(site) },
        "overall" => summary_to_hash(analysis.overall),
        "total_failures" => analysis.total_failures
      }
    end

    private def site_to_hash(site)
      {
        "url" => site.url,
        "summary" => summary_to_hash(site.summary),
        "failures" => site.failures
      }
    end

    private def summary_to_hash(summary)
      {
        "min_seconds" => summary.min_seconds,
        "max_seconds" => summary.max_seconds,
        "average_seconds" => summary.average_seconds,
        "median_seconds" => summary.median_seconds,
        "p95_seconds" => summary.p95_seconds,
        "sample_size" => summary.sample_size
      }
    end

    private def recommendation_to_hash(recommendation)
      {
        "url" => recommendation.url,
        "severity" => recommendation.severity,
        "message" => recommendation.message
      }
    end
  end
end
