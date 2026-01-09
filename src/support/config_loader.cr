require "yaml"

module Support
  module ConfigLoader
    def self.load(path)
      return nil unless File.exists?(path)

      YAML.parse(File.read(path))
    end
  end
end
