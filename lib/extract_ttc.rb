# frozen_string_literal: true

require_relative "extract_ttc/version"
require_relative "extract_ttc/constants"
require_relative "extract_ttc/configuration"

# Domain objects (binary data objects)
require_relative "extract_ttc/true_type_collection"
require_relative "extract_ttc/true_type_font"

# Model classes (value objects)
require_relative "extract_ttc/models/extraction_result"
require_relative "extract_ttc/models/validation_result"

# Utility classes
require_relative "extract_ttc/utilities/checksum_calculator"
require_relative "extract_ttc/utilities/output_path_generator"

# Conditionally load CLI if Thor is available
require_relative "extract_ttc/cli" if defined?(Thor)

module ExtractTtc
  class Error < StandardError; end

  class ReadFileError < Error; end

  class InvalidFileError < Error; end

  class WriteFileError < Error; end

  class UnknownResultError < Error; end

  # Extract all fonts from a TTC file
  #
  # This is the main public API for the gem. It extracts all fonts from
  # a TrueType Collection (TTC) file and writes them as separate TTF files.
  #
  # Uses the object-oriented architecture where domain objects
  # (TrueTypeCollection, TrueTypeFont) encapsulate their own persistence logic.
  #
  # @param path [String] Path to the input TTC file
  # @param output_dir [String, nil] Optional output directory
  # @param config [Configuration, nil] Optional configuration object
  # @return [Array<String>] Array of output file paths
  #
  # @raise [ReadFileError] If the input file cannot be read
  # @raise [InvalidFileError] If the file is not a valid TTC file
  # @raise [WriteFileError] If output files cannot be written
  #
  # @example Extract fonts to current directory
  #   ExtractTtc.extract("Helvetica.ttc")
  #   # => ["Helvetica_00.ttf", "Helvetica_01.ttf", ...]
  #
  # @example Extract fonts to specific directory
  #   ExtractTtc.extract("Helvetica.ttc", output_dir: "/tmp/fonts")
  def self.extract(path, output_dir: nil, config: nil)
    ensure_output_directory_exists(output_dir)

    File.open(path, "rb") do |file|
      ttc = TrueTypeCollection.read(file)
      fonts = ttc.extract_fonts(file)

      fonts.map.with_index do |font, index|
        output_path = Utilities::OutputPathGenerator.generate(
          path, index, output_dir: output_dir || config&.output_directory
        )
        font.to_file(output_path)
        output_path
      end
    end
  rescue Errno::ENOENT
    raise ReadFileError, "Could not open file: #{path}"
  rescue Errno::EACCES => e
    raise WriteFileError, "Failed to open output file: #{e.message}"
  rescue IOError, RuntimeError, StandardError => e
    raise invalid_file?(e) ? invalid_file_error : write_file_error(e)
  end

  # Check if error indicates invalid/corrupted TTC file
  def self.invalid_file?(error)
    error.message.match?(/end of file|expected|Invalid TTC/i)
  end

  def self.invalid_file_error
    InvalidFileError.new("File does not look like a ttc file")
  end

  def self.write_file_error(error)
    WriteFileError.new("Failed to open output file: #{error.message}")
  end

  def self.ensure_output_directory_exists(output_dir)
    return unless output_dir
    return if File.directory?(output_dir)

    require "fileutils"
    FileUtils.mkdir_p(output_dir)
  end

  private_class_method :invalid_file?, :invalid_file_error,
                       :write_file_error, :ensure_output_directory_exists
end
