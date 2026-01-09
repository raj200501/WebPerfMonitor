require "./spec_helper.cr"

TestSuite.test("loads default config when missing") do
  config = WebPerfMonitor::Config.load("tmp/missing.yml")
  TestSuite.assert(!config.settings.websites.empty?, "Expected default websites")
end

TestSuite.test("validates invalid config") do
  settings = WebPerfMonitor::Settings.new([] of String, 0, 0.0, "", nil, WebPerfMonitor::Thresholds.new, WebPerfMonitor::ServerSettings.new)
  begin
    settings.validate
  rescue WebPerfMonitor::ConfigError
    next
  end
  raise "Expected ConfigError"
end

TestSuite.test("loads config from yaml file") do
  root = Support::Env.fetch("WEBPERF_ROOT") || Support::PathUtil.cwd
  Support::FileUtil.mkdir_p(File.join(root, "tmp"))
  File.write(File.join(root, "tmp/spec-config.yml"), <<-YAML)
websites:
  - "https://example.com"
monitor_interval_seconds: 12
request_timeout_seconds: 3.5
report_output_dir: "tmp/spec-output"
webhook_url: ""
thresholds:
  warning_seconds: 0.3
  critical_seconds: 0.8
server:
  enabled: true
  host: "127.0.0.1"
  port: 5050
YAML

  config = WebPerfMonitor::Config.load("tmp/spec-config.yml")
  TestSuite.assert_equal(12, config.settings.monitor_interval_seconds)
  TestSuite.assert_equal(0.8, config.settings.thresholds.critical_seconds)
  TestSuite.assert_equal(5050, config.settings.server.port)
end
