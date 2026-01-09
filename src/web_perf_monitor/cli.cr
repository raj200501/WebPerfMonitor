module WebPerfMonitor
  module CLI
    def self.run(args)
      command = "run-once"
      config_path = nil
      index = 0

      while index < args.size
        arg = args[index]
        if arg == "--config" || arg == "-c"
          index += 1
          config_path = args[index]
        elsif arg == "--version"
          puts VERSION
          return
        elsif arg == "--help" || arg == "-h"
          print_help
          return
        elsif arg.to_s[0, 1] != "-"
          command = arg
        end
        index += 1
      end

      config = Config.load(config_path)

      case command
      when "run-once"
        run_once(config)
      when "monitor"
        run_forever(config)
      when "serve"
        serve(config)
      when "validate-config"
        puts "Config OK"
      when "print-config"
        puts config.settings.to_yaml
      else
        puts "Unknown command: #{command}"
        print_help
        exit 1
      end
    end

    def self.print_help
      puts "Usage: webperfmonitor [command] [options]"
      puts "Commands: run-once, monitor, serve, validate-config, print-config"
      puts "Options:"
      puts "  -c, --config PATH   Path to YAML config"
      puts "  --version           Print version"
      puts "  -h, --help          Show help"
    end

    def self.run_once(config)
      runner = Runner.new(config.settings)
      result = runner.run_once
      puts "Report written to #{result.output.path} (#{result.output.bytes_written} bytes)"
      if result.webhook_result
        puts "Webhook: #{result.webhook_result.message}"
      end
    end

    def self.run_forever(config)
      runner = Runner.new(config.settings)
      runner.run_forever
    end

    def self.serve(config)
      unless config.settings.server.enabled
        puts "Server disabled in config. Set server.enabled=true to run."
        exit 1
      end
      store = FileStore.new(config.settings.report_output_dir)
      server = ReportServer.new(config.settings, store)
      server.start
    end
  end
end
