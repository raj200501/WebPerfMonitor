require "yaml"

module Support
  class YamlAny
    def initialize(value)
      @value = value
    end

    def raw
      @value
    end

    def as_s
      @value.to_s
    end

    def as_i
      Integer(@value)
    end

    def as_f
      Float(@value)
    end

    def as_a
      Array(@value).map { |item| YamlAny.new(item) }
    end

    def as_h
      Hash(@value).transform_keys(&:to_s).transform_values { |item| YamlAny.new(item) }
    end

    def as_bool
      !!@value
    end
  end

  module ConfigLoader
    def self.load(path)
      return nil unless File.exist?(path)

      YamlAny.new(YAML.load_file(path))
    end
  end
end
