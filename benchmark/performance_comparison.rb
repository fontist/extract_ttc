#!/usr/bin/env ruby
# frozen_string_literal: true

require "benchmark"
require "tmpdir"
require "fileutils"
require_relative "../lib/extract_ttc"

# Benchmark configuration
ITERATIONS = 10
TEST_FILE = File.join(__dir__, "../spec/fixtures/Helvetica.ttc")

# Result storage
class BenchmarkResult
  attr_reader :times, :font_count

  def initialize
    @times = []
    @font_count = 0
  end

  def add_time(time)
    @times << time
  end

  def set_font_count(count)
    @font_count = count
  end

  def average
    return 0 if @times.empty?

    @times.sum / @times.size
  end

  def min
    @times.min || 0
  end

  def max
    @times.max || 0
  end

  def available?
    !@times.empty?
  end
end

# Clean up generated TTF files in a directory
def cleanup_output_files(directory)
  Dir.glob(File.join(directory, "*.ttf")).each { |f| File.delete(f) }
end

# Test if C implementation is available
def c_implementation_available?
  begin
    require_relative "../lib/extract_ttc/extractor"
    return true if defined?(ExtractTTC::Extractor)
  rescue LoadError, NameError
    # C implementation not available
  end

  # Check if compiled extension exists
  so_file = File.join(__dir__, "../ext/stripttc/stripttc.so")
  File.exist?(so_file)
end

# Run C implementation benchmark
def benchmark_c_implementation(test_file, iterations)
  result = BenchmarkResult.new

  puts "\nBenchmarking C Implementation..."

  begin
    require_relative "../lib/extract_ttc/extractor"

    Dir.mktmpdir do |tmpdir|
      iterations.times do |i|
        Dir.chdir(tmpdir) do
          cleanup_output_files(tmpdir)

          time = Benchmark.realtime do
            extractor = ExtractTtc::Extractor.new(test_file)
            extractor.extract
          end

          result.add_time(time)

          # Count fonts from first iteration
          if i.zero?
            font_count = Dir.glob(File.join(tmpdir, "*.ttf")).size
            result.set_font_count(font_count)
          end

          print "."
        end
      end
    end

    puts " Done!"
  rescue LoadError, NameError, StandardError => e
    puts " Not available (#{e.message})"
  end

  result
end

# Run Ruby implementation benchmark
def benchmark_ruby_implementation(test_file, iterations)
  result = BenchmarkResult.new

  puts "\nBenchmarking Ruby Implementation..."

  Dir.mktmpdir do |tmpdir|
    iterations.times do |i|
      cleanup_output_files(tmpdir)

      time = Benchmark.realtime do
        # Use the new OO architecture API
        ExtractTtc.extract(test_file, output_dir: tmpdir)
      end

      result.add_time(time)

      # Count fonts from first iteration
      if i.zero?
        font_count = Dir.glob(File.join(tmpdir, "*.ttf")).size
        result.set_font_count(font_count)
      end

      print "."
    end
  end

  puts " Done!"

  result
end

# Format time value
def format_time(seconds)
  format("%.4f", seconds)
end

# Print banner
def print_banner
  puts "=" * 60
  puts "ExtractTTC Performance Benchmark".center(60)
  puts "=" * 60
end

# Print configuration
def print_configuration(test_file, iterations)
  puts "\nConfiguration:"
  puts "  Test file: #{File.basename(test_file)}"
  puts "  File size: #{format_file_size(File.size(test_file))}"
  puts "  Iterations: #{iterations}"
  puts
end

# Format file size
def format_file_size(bytes)
  if bytes < 1024
    "#{bytes} bytes"
  elsif bytes < 1024 * 1024
    "#{(bytes / 1024.0).round(2)} KB"
  else
    "#{(bytes / (1024.0 * 1024.0)).round(2)} MB"
  end
end

# Print result section
def print_result(name, result)
  puts "\n#{name}:"

  unless result.available?
    puts "  Status: Not available"
    return
  end

  puts "  Average time: #{format_time(result.average)} seconds"
  puts "  Min time: #{format_time(result.min)} seconds"
  puts "  Max time: #{format_time(result.max)} seconds"
  puts "  Fonts extracted: #{result.font_count}"

  if result.font_count.positive?
    avg_per_font = result.average / result.font_count
    puts "  Time per font: #{format_time(avg_per_font)} seconds"
  end
end

# Print comparison
def print_comparison(c_result, ruby_result)
  puts "\n#{'-' * 60}"
  puts "Performance Comparison:".center(60)
  puts ("-" * 60)

  if !c_result.available?
    puts "\nC implementation not available for comparison."
    puts "This is expected after removing FFI dependency."
    puts "\nRuby implementation provides:"
    puts "  - Pure Ruby portability"
    puts "  - No compilation required"
    puts "  - Easier maintenance and debugging"
  elsif !ruby_result.available?
    puts "\nRuby implementation failed to run."
  else
    ratio = ruby_result.average / c_result.average
    difference = ruby_result.average - c_result.average

    puts "\n  Ruby is #{format('%.2f', ratio)}x " \
         "#{ratio > 1 ? 'slower' : 'faster'} than C"
    puts "  Difference: #{'+' if difference.positive?}" \
         "#{format_time(difference)} seconds per extraction"

    if ratio > 1
      puts "\n  Note: Performance trade-off for pure Ruby portability"
    end
  end
end

# Main benchmark execution
def run_benchmark
  print_banner
  print_configuration(TEST_FILE, ITERATIONS)

  unless File.exist?(TEST_FILE)
    puts "Error: Test file not found: #{TEST_FILE}"
    exit 1
  end

  # Run benchmarks
  c_result = if c_implementation_available?
               benchmark_c_implementation(TEST_FILE, ITERATIONS)
             else
               puts "\nC Implementation: Not available"
               BenchmarkResult.new
             end

  ruby_result = benchmark_ruby_implementation(TEST_FILE, ITERATIONS)

  # Print results
  puts "\n#{'=' * 60}"
  puts "Results".center(60)
  puts "=" * 60

  print_result("C Implementation (FFI)", c_result)
  print_result("Ruby Implementation (Refactored)", ruby_result)

  print_comparison(c_result, ruby_result)

  puts "\n#{'=' * 60}"
  puts
end

# Run the benchmark
if __FILE__ == $PROGRAM_NAME
  begin
    run_benchmark
  rescue Interrupt
    puts "\n\nBenchmark interrupted by user."
    exit 1
  rescue StandardError => e
    puts "\n\nError running benchmark: #{e.message}"
    puts e.backtrace.join("\n")
    exit 1
  end
end
