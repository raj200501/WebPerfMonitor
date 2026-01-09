require "file_utils"

module Support
  module FileUtil
    def self.mkdir_p(path)
      FileUtils.mkdir_p(path)
    end

    def self.file_exists?(path)
      File.exists?(path)
    end

    def self.dir_exists?(path)
      Dir.exists?(path)
    end
  end
end
