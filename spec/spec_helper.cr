require "../src/web_perf_monitor.cr"

module TestSuite
  @@tests_run = 0
  @@failures = 0

  def self.test(name)
    @@tests_run += 1
    yield
    puts "PASS: #{name}"
  rescue => ex
    @@failures += 1
    puts "FAIL: #{name} - #{ex.message}"
  end

  def self.assert(condition, message = "Assertion failed")
    raise message unless condition
  end

  def self.assert_equal(expected, actual, message = nil)
    return if expected == actual

    raise(message || "Expected #{expected.inspect}, got #{actual.inspect}")
  end

  def self.assert_includes(haystack, needle, message = nil)
    return if haystack.to_s.index(needle.to_s)

    raise(message || "Expected #{haystack.inspect} to include #{needle.inspect}")
  end

  def self.summary
    puts "Tests run: #{@@tests_run}, Failures: #{@@failures}"
    exit 1 if @@failures > 0
  end
end
