#!/usr/bin/env ruby
# frozen_string_literal: true

repo_root = File.expand_path("..", __dir__)

cmd = ARGV.shift

module Kernel
  alias original_require require

  def require(path)
    caller_path = caller_locations(1, 1)&.first&.absolute_path
    base_dir = caller_path ? File.dirname(caller_path) : Dir.pwd
    resolved = path.start_with?(".") ? File.expand_path(path, base_dir) : path

    if resolved.end_with?(".cr")
      return false if $LOADED_FEATURES.include?(resolved)

      $LOADED_FEATURES << resolved
      load resolved
      return true
    end

    if File.exist?(resolved + ".rb")
      resolved_rb = resolved + ".rb"
      return false if $LOADED_FEATURES.include?(resolved_rb)

      $LOADED_FEATURES << resolved_rb
      load resolved_rb
      return true
    end

    original_require(resolved)
  end
end

if cmd.nil? || cmd == "--help" || cmd == "-h"
  puts "crystal (shim) supports: run <file> -- [args], spec, --version"
  exit 0
end

if cmd == "--version" || cmd == "-v"
  puts "crystal shim (ruby)"
  exit 0
end

if cmd == "spec"
  file = File.join(repo_root, "scripts", "spec_runner.cr")
  ARGV.clear
elsif cmd == "run"
  file = ARGV.shift
  if file.nil?
    warn "crystal run requires a file"
    exit 1
  end
  if ARGV.first == "--"
    ARGV.shift
  end
else
  warn "Unsupported crystal command: #{cmd}"
  exit 1
end

ENV["WEBPERF_ROOT"] ||= repo_root
file_path = File.expand_path(file, repo_root)
Dir.chdir(File.dirname(file_path))
load file_path
