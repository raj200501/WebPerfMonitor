module WebPerfMonitor
  class Metric
    def initialize(url, response_time_seconds, status_code = nil, error = nil)
      @url = url
      @response_time_seconds = response_time_seconds
      @status_code = status_code
      @error = error
    end

    def url
      @url
    end

    def response_time_seconds
      @response_time_seconds
    end

    def status_code
      @status_code
    end

    def error
      @error
    end

    def success?
      return false unless @error.nil?
      return false if @status_code.nil?

      @status_code < 500
    end
  end

  class StatSummary
    def initialize(min_seconds, max_seconds, average_seconds, median_seconds, p95_seconds, sample_size)
      @min_seconds = min_seconds
      @max_seconds = max_seconds
      @average_seconds = average_seconds
      @median_seconds = median_seconds
      @p95_seconds = p95_seconds
      @sample_size = sample_size
    end

    def min_seconds
      @min_seconds
    end

    def max_seconds
      @max_seconds
    end

    def average_seconds
      @average_seconds
    end

    def median_seconds
      @median_seconds
    end

    def p95_seconds
      @p95_seconds
    end

    def sample_size
      @sample_size
    end
  end

  class SiteAnalysis
    def initialize(url, summary, failures)
      @url = url
      @summary = summary
      @failures = failures
    end

    def url
      @url
    end

    def summary
      @summary
    end

    def failures
      @failures
    end
  end

  class AnalysisReport
    def initialize(per_site, overall, total_failures)
      @per_site = per_site
      @overall = overall
      @total_failures = total_failures
    end

    def per_site
      @per_site
    end

    def overall
      @overall
    end

    def total_failures
      @total_failures
    end
  end

  class Recommendation
    def initialize(url, severity, message)
      @url = url
      @severity = severity
      @message = message
    end

    def url
      @url
    end

    def severity
      @severity
    end

    def message
      @message
    end
  end

  class ReportData
    def initialize(timestamp, metrics, analysis, recommendations)
      @timestamp = timestamp
      @metrics = metrics
      @analysis = analysis
      @recommendations = recommendations
    end

    def timestamp
      @timestamp
    end

    def metrics
      @metrics
    end

    def analysis
      @analysis
    end

    def recommendations
      @recommendations
    end
  end

  class ReportOutput
    def initialize(path, bytes_written)
      @path = path
      @bytes_written = bytes_written
    end

    def path
      @path
    end

    def bytes_written
      @bytes_written
    end
  end

  class WebhookResult
    def initialize(success, status_code, message)
      @success = success
      @status_code = status_code
      @message = message
    end

    def success
      @success
    end

    def status_code
      @status_code
    end

    def message
      @message
    end
  end
end
