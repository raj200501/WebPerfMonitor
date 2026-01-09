require "uri"

module WebPerfMonitor
  class Thresholds
    def initialize(warning_seconds = 0.5, critical_seconds = 1.5)
      @warning_seconds = warning_seconds
      @critical_seconds = critical_seconds
    end

    def warning_seconds
      @warning_seconds
    end

    def critical_seconds
      @critical_seconds
    end

    def validate
      if @warning_seconds <= 0 || @critical_seconds <= 0
        raise ConfigError.new("Thresholds must be greater than zero")
      end
      if @warning_seconds >= @critical_seconds
        raise ConfigError.new("Warning threshold must be lower than critical threshold")
      end
    end
  end

  class ServerSettings
    def initialize(enabled = false, host = "127.0.0.1", port = 4000)
      @enabled = enabled
      @host = host
      @port = port
    end

    def enabled
      @enabled
    end

    def host
      @host
    end

    def port
      @port
    end

    def validate
      if @port <= 0 || @port > 65_535
        raise ConfigError.new("Server port must be between 1 and 65535")
      end
    end
  end

  class Settings
    def initialize(
      websites = ["https://example.com"],
      monitor_interval_seconds = 60,
      request_timeout_seconds = 5.0,
      report_output_dir = "reports",
      webhook_url = nil,
      thresholds = Thresholds.new,
      server = ServerSettings.new
    )
      @websites = websites
      @monitor_interval_seconds = monitor_interval_seconds
      @request_timeout_seconds = request_timeout_seconds
      @report_output_dir = report_output_dir
      @webhook_url = webhook_url
      @thresholds = thresholds
      @server = server
    end

    def websites
      @websites
    end

    def monitor_interval_seconds
      @monitor_interval_seconds
    end

    def request_timeout_seconds
      @request_timeout_seconds
    end

    def report_output_dir
      @report_output_dir
    end

    def webhook_url
      @webhook_url
    end

    def thresholds
      @thresholds
    end

    def server
      @server
    end

    def validate
      if @websites.empty?
        raise ConfigError.new("At least one website must be configured")
      end

      @websites.each do |website|
        uri = URI.parse(website)
        if uri.scheme.nil? || uri.host.nil?
          raise ConfigError.new("Invalid website URL: #{website}")
        end
      end

      if @monitor_interval_seconds <= 0
        raise ConfigError.new("Monitor interval must be greater than zero")
      end

      if @request_timeout_seconds <= 0
        raise ConfigError.new("Request timeout must be greater than zero")
      end

      if @report_output_dir.to_s.strip.empty?
        raise ConfigError.new("Report output dir cannot be empty")
      end

      @thresholds.validate
      @server.validate
    end

    def to_yaml
      <<-YAML
websites:
  - #{websites.join("\n  - ")}
monitor_interval_seconds: #{@monitor_interval_seconds}
request_timeout_seconds: #{@request_timeout_seconds}
report_output_dir: "#{@report_output_dir}"
webhook_url: "#{@webhook_url || ""}"
thresholds:
  warning_seconds: #{@thresholds.warning_seconds}
  critical_seconds: #{@thresholds.critical_seconds}
server:
  enabled: #{@server.enabled}
  host: "#{@server.host}"
  port: #{@server.port}
YAML
    end

    def self.from_yaml_any(data)
      hash = data.as_h
      websites = read_array(hash, "websites", ["https://example.com"])
      monitor_interval = read_int(hash, "monitor_interval_seconds", 60)
      request_timeout = read_float(hash, "request_timeout_seconds", 5.0)
      report_output_dir = read_string(hash, "report_output_dir", "reports")
      webhook_url = read_string(hash, "webhook_url", "")
      webhook_url = nil if webhook_url.strip.empty?

      thresholds_hash = read_hash(hash, "thresholds")
      thresholds = Thresholds.new(
        read_float(thresholds_hash, "warning_seconds", 0.5),
        read_float(thresholds_hash, "critical_seconds", 1.5)
      )

      server_hash = read_hash(hash, "server")
      server = ServerSettings.new(
        read_bool(server_hash, "enabled", false),
        read_string(server_hash, "host", "127.0.0.1"),
        read_int(server_hash, "port", 4000)
      )

      Settings.new(
        websites,
        monitor_interval,
        request_timeout,
        report_output_dir,
        webhook_url,
        thresholds,
        server
      )
    end

    def self.read_hash(hash, key)
      value = value_for(hash, key)
      return hash.class.new if value.nil?
      value.as_h
    end

    def self.read_array(hash, key, default)
      value = value_for(hash, key)
      return default if value.nil?
      value.as_a.map { |item| item.as_s }
    end

    def self.read_string(hash, key, default)
      value = value_for(hash, key)
      return default if value.nil?
      value.as_s
    end

    def self.read_int(hash, key, default)
      value = value_for(hash, key)
      return default if value.nil?
      value.as_i
    end

    def self.read_float(hash, key, default)
      value = value_for(hash, key)
      return default if value.nil?
      value.as_f
    end

    def self.read_bool(hash, key, default)
      value = value_for(hash, key)
      return default if value.nil?
      value.as_bool
    end

    def self.value_for(hash, key)
      hash.each do |entry_key, entry_value|
        return entry_value if entry_key.to_s == key
      end
      nil
    end
  end

  class Config
    DEFAULT_PATH = "config/default.yml"

    def initialize(settings)
      @settings = settings
    end

    def settings
      @settings
    end

    def self.load(path = nil)
      config_path = resolve_path(path || DEFAULT_PATH)
      data = Support::ConfigLoader.load(config_path)
      settings = if data
                   Settings.from_yaml_any(data)
                 else
                   Settings.new
                 end
      settings.validate
      Config.new(settings)
    end

    def self.resolve_path(path)
      path_string = path.to_s
      return path if !path_string.empty? && path_string[0, 1] == "/"

      root = Support::Env.fetch("WEBPERF_ROOT")
      return File.join(root, path) if root

      File.join(Dir.current, path)
    end
  end
end
