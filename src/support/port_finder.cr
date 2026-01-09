require "socket"

module Support
  module PortFinder
    def self.available_port
      server = TCPServer.new("127.0.0.1", 0)
      port = server.local_address.port
      server.close
      port
    end
  end
end
