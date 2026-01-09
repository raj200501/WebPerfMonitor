module Support
  module TimeUtil
    def self.monotonic
      Time.monotonic.total_seconds
    end

    def self.now_iso8601
      Time.utc.to_s("%Y-%m-%dT%H:%M:%S%:z")
    end
  end
end
