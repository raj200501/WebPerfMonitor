module Support
  module Env
    def self.fetch(key)
      ENV[key]?
    end
  end
end
