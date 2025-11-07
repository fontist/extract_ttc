# frozen_string_literal: true

require "paint"

module ExtractTtc
  # Command to list fonts contained in a TTC file
  class ListCommand
    def initialize(options = {})
      @options = options
      @verbose = options[:verbose] || false
    end

    def run(file_path)
      validate_file_exists(file_path)

      File.open(file_path, "rb") do |file|
        ttc = TrueTypeCollection.read(file)

        display_font_list(ttc, file_path)

        0 # Success
      end
    rescue ExtractTtc::ReadFileError => e
      display_error("File read error: #{e.message}")
      1
    rescue ExtractTtc::InvalidFileError => e
      display_error("Invalid file: #{e.message}")
      2
    rescue StandardError => e
      display_error("Error: #{e.message}")
      3
    end

    private

    def validate_file_exists(file_path)
      return if File.exist?(file_path)

      raise ExtractTtc::ReadFileError, "File not found: #{file_path}"
    end

    def display_font_list(ttc, file_path)
      puts Paint["📦 TTC File: ", :cyan, :bold] + file_path
      puts Paint["   Fonts: ", :bold] + Paint[ttc.num_fonts.to_s, :green]
      puts

      ttc.num_fonts.times do |index|
        output_name = Utilities::OutputPathGenerator.generate(
          file_path,
          index,
        )
        puts "#{Paint["  #{index}.", :white]} 📄 #{Paint[output_name, :yellow]}"
      end
    end

    def display_error(message)
      warn Paint["❌ Error: ", :red] + message
    end
  end
end
