module WebPerfMonitor
  class Error < Exception
  end

  class ConfigError < Error
  end

  class IntegrationError < Error
  end
end
