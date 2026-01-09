require "json"

module Support
  module JsonUtil
    def self.pretty(payload)
      JSON.pretty_generate(JSON.parse(payload))
    end

    def self.parse(payload)
      JSON.parse(payload)
    end

    def self.value_at(node, keys)
      current = node
      keys.each do |key|
        current = current[key]
      end
      current
    end

    def self.to_string(value)
      value.to_s
    end
  end
end
