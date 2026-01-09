require "net/http"
require "uri"

module Support
  class HttpResponse
    attr_reader :status_code, :body

    def initialize(status_code, body)
      @status_code = status_code
      @body = body
    end
  end

  class HttpClient
    def self.get(url, timeout_seconds)
      uri = URI.parse(url)
      http = Net::HTTP.new(uri.host, uri.port)
      http.use_ssl = uri.scheme == "https"
      http.open_timeout = timeout_seconds
      http.read_timeout = timeout_seconds
      request = Net::HTTP::Get.new(uri.request_uri)
      response = http.request(request)
      HttpResponse.new(response.code.to_i, response.body.to_s)
    end

    def self.post(url, body, headers = {"Content-Type" => "application/json"}, timeout_seconds = 10.0)
      uri = URI.parse(url)
      http = Net::HTTP.new(uri.host, uri.port)
      http.use_ssl = uri.scheme == "https"
      http.open_timeout = timeout_seconds
      http.read_timeout = timeout_seconds
      request = Net::HTTP::Post.new(uri.request_uri, headers)
      request.body = body
      response = http.request(request)
      HttpResponse.new(response.code.to_i, response.body.to_s)
    end
  end
end
