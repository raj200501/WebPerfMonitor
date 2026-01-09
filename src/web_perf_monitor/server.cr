module WebPerfMonitor
  class ReportServer
    def initialize(settings, store)
      @settings = settings
      @store = store
      @server = build_server
    end

    def start
      @server.start
    end

    def start_in_background
      @server.start_in_background
      @server
    end

    def shutdown
      @server.shutdown
    end

    private def build_server
      Support::HttpServer.new(@settings.server.host, @settings.server.port) do |method, path|
        if method == "GET" && path == "/health"
          Support::ServerResponse.new(200, "ok", {"Content-Type" => "text/plain"})
        elsif method == "GET" && path == "/latest"
          report = @store.read_latest
          if report
            Support::ServerResponse.new(200, report, {"Content-Type" => "application/json"})
          else
            Support::ServerResponse.new(404, "No reports available", {"Content-Type" => "text/plain"})
          end
        else
          Support::ServerResponse.new(404, "Not Found", {"Content-Type" => "text/plain"})
        end
      end
    end
  end
end
