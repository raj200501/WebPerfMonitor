require "http/server"

module Support
  class ServerResponse
    getter status
    getter body
    getter headers

    def initialize(@status, @body, @headers = {} of String => String)
    end
  end

  class HttpServer
    def initialize(@host, @port, &@handler : String, String -> ServerResponse)
      @server = build_server
    end

    def start
      @server.bind_tcp(@host, @port)
      @server.listen
    end

    def start_in_background
      @server.bind_tcp(@host, @port)
      spawn { @server.listen }
    end

    def shutdown
      @server.close
    end

    private def build_server
      HTTP::Server.new do |context|
        response = @handler.call(context.request.method, context.request.path)
        context.response.status_code = response.status
        response.headers.each do |key, value|
          context.response.headers[key] = value
        end
        context.response.print(response.body)
      end
    end
  end
end
