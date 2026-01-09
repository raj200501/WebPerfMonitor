require "socket"

module Support
  class ServerResponse
    attr_reader :status, :body, :headers

    def initialize(status, body, headers = {})
      @status = status
      @body = body
      @headers = headers
    end
  end

  class HttpServer
    def initialize(host, port, &handler)
      @host = host
      @port = port
      @handler = handler
      @server = TCPServer.new(@host, @port)
      @thread = nil
    end

    def start
      loop do
        socket = @server.accept
        handle(socket)
      rescue IOError
        break
      end
    end

    def start_in_background
      @thread = Thread.new { start }
      @thread.report_on_exception = false
      @server
    end

    def shutdown
      @server.close
      @thread&.kill
    rescue IOError
      # ignore
    end

    private

    def handle(socket)
      request_line = socket.gets
      return if request_line.nil?

      method, path, = request_line.split(" ")
      while (line = socket.gets)
        break if line == "\r\n"
      end

      response = @handler.call(method, path)
      body = response.body.to_s

      socket.write "HTTP/1.1 #{response.status} OK\r\n"
      response.headers.each { |k, v| socket.write "#{k}: #{v}\r\n" }
      socket.write "Content-Length: #{body.bytesize}\r\n"
      socket.write "\r\n"
      socket.write body
    ensure
      socket.close if socket
    end
  end
end
