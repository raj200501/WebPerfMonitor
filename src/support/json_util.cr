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
        if key.is_a?(Int32)
          current = current.as_a[key]
        else
          current = current.as_h[key.to_s]
        end
      end
      current
    end

    def self.to_string(value)
      value.as_s
    end
  end
end
