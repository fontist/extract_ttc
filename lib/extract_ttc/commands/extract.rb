# frozen_string_literal: true

require "paint"

module ExtractTtc
  class ExtractCommand
    def initialize(options = {})
      @options = options
      @verbose = options[:verbose] || false
    end

    def run(file_path)
      validate_file_exists(file_path)
      ensure_output_directory

      log_verbose("Extracting fonts from #{file_path}...")

      output_paths = ExtractTtc.extract(
        file_path,
        output_dir: @options[:output_dir],
      )

      display_results(output_paths)

      0 # Success exit code
    rescue ExtractTtc::ReadFileError => e
      display_error("File read error: #{e.message}")
      1
    rescue ExtractTtc::InvalidFileError => e
      display_error("Invalid file: #{e.message}")
      2
    rescue ExtractTtc::WriteFileError => e
      display_error("Write error: #{e.message}")
      3
    rescue ExtractTtc::Error => e
      display_error("Extraction error: #{e.message}")
      4
    rescue RuntimeError => e
      # BinData errors often come as RuntimeError
      display_error("Invalid file: #{e.message}")
      2
    rescue StandardError => e
      display_error("Unexpected error: #{e.message}")
      5
    end

    private

    attr_reader :options, :verbose

    def validate_file_exists(file_path)
      return if File.exist?(file_path)

      raise ExtractTtc::ReadFileError, "File not found: #{file_path}"
    end

    def ensure_output_directory
      return unless @options[:output_dir]
      return if File.directory?(@options[:output_dir])

      require "fileutils"
      FileUtils.mkdir_p(@options[:output_dir])
    end

    def display_results(output_paths)
      if output_paths.empty?
        puts Paint["⚠️  No fonts were extracted.", :yellow]
        return
      end

      puts Paint["✅ Successfully extracted #{output_paths.size} font(s):", :green, :bold]
      output_paths.each do |path|
        puts "  #{Paint['📄', :cyan]} #{path}"
      end
    end

    def display_error(message)
      warn Paint["❌ Error: ", :red] + message
    end

    def log_verbose(message)
      return unless @verbose

      puts Paint["ℹ️  ", :white] + message
    end
  end
end
