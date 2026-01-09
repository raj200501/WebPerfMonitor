module WebPerfMonitor
  class WebhookClient
    def initialize(endpoint)
      @endpoint = endpoint
    end

    def send(report_json)
      response = Support::HttpClient.post(@endpoint, report_json)
      if response.status_code >= 200 && response.status_code < 300
        WebhookResult.new(true, response.status_code, "Webhook delivered")
      else
        WebhookResult.new(false, response.status_code, "Webhook failed with status #{response.status_code}")
      end
    rescue ex : Exception
      WebhookResult.new(false, nil, "Webhook failed: #{ex.message}")
    end
  end
end
