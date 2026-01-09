require "http/client"
require "uri"

module Support
  class HttpResponse
    getter status_code
    getter body

    def initialize(@status_code, @body)
    end
  end

  class HttpClient
    def self.get(url, timeout_seconds)
      uri = URI.parse(url)
      client = HTTP::Client.new(uri)
      timeout = Time::Span.from_seconds(timeout_seconds)
      client.connect_timeout = timeout
      client.read_timeout = timeout
      response = client.get(uri.request_target)
      HttpResponse.new(response.status_code, response.body)
    ensure
      client.try(&.close)
    end

    def self.post(url, body, headers = {"Content-Type" => "application/json"}, timeout_seconds = 10.0)
      uri = URI.parse(url)
      client = HTTP::Client.new(uri)
      timeout = Time::Span.from_seconds(timeout_seconds)
      client.connect_timeout = timeout
      client.read_timeout = timeout
      response = client.post(uri.request_target, headers: HTTP::Headers.new(headers), body: body)
      HttpResponse.new(response.status_code, response.body)
    ensure
      client.try(&.close)
    end
  end
end
