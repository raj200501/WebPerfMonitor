require "time"

module Support
  module TimeUtil
    def self.monotonic
      Process.clock_gettime(Process::CLOCK_MONOTONIC)
    end

    def self.now_iso8601
      Time.now.utc.iso8601
    end
  end
end
