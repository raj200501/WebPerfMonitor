require "fileutils"

module Support
  module FileUtil
    def self.mkdir_p(path)
      FileUtils.mkdir_p(path)
    end

    def self.file_exists?(path)
      File.exist?(path)
    end

    def self.dir_exists?(path)
      Dir.exist?(path)
    end
  end
end
