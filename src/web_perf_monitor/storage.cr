module WebPerfMonitor
  class FileStore
    def initialize(output_dir)
      @output_dir = output_dir
    end

    def write(report_json, timestamp)
      Support::FileUtil.mkdir_p(@output_dir)
      safe_timestamp = timestamp.gsub(":", "-")
      path = File.join(@output_dir, "report-#{safe_timestamp}.json")
      File.write(path, report_json)
      ReportOutput.new(path, report_json.bytesize)
    end

    def latest_report_path
      return nil unless Support::FileUtil.dir_exists?(@output_dir)

      files = Dir.glob(File.join(@output_dir, "report-*.json"))
      return nil if files.empty?

      files.sort.last
    end

    def read_latest
      path = latest_report_path
      return nil unless path

      File.read(path)
    end
  end
end
