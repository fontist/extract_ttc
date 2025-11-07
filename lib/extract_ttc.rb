# frozen_string_literal: true

require "bindata"
require_relative "extract_ttc/version"
require_relative "extract_ttc/constants"
require_relative "extract_ttc/configuration"

# Domain objects (OO architecture with BinData)
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
    File.open(path, "rb") do |file|
      # Read TTC file using BinData
      ttc = TrueTypeCollection.read(file)

      # Extract fonts (needs IO to read table data)
      fonts = ttc.extract_fonts(file)

      # Write each font to file
      fonts.map.with_index do |font, index|
        output_path = generate_output_path(path, index, output_dir, config)
        font.to_file(output_path)
        output_path
      end
    end
  rescue Errno::ENOENT => e
    raise ReadFileError, "Could not open file: #{e.message}"
  rescue RuntimeError => e
    if e.message.include?("unexpected end of file") ||
        e.message.include?("Invalid TTC") ||
        e.message.include?("expected")
      raise InvalidFileError, "File does not look like a ttc file"
    else
      raise InvalidFileError, "Invalid TTC file: #{e.message}"
    end
  rescue IOError => e
    # BinData throws IOError with "End of file reached" for empty/invalid files
    if e.message.include?("End of file")
      raise InvalidFileError, "File does not look like a ttc file"
    else
      raise WriteFileError, "Failed to open output file: #{e.message}"
    end
  rescue Errno::EACCES => e
    raise WriteFileError, "Failed to open output file: #{e.message}"
  rescue StandardError => e
    # Catch any other validation errors from BinData
    if e.message.include?("expected")
      raise InvalidFileError, "File does not look like a ttc file"
    else
      raise
    end
  end

  # Generate output path for extracted font
  #
  # @param input_path [String] Input TTC file path
  # @param index [Integer] Font index
  # @param output_dir [String, nil] Optional output directory
  # @param config [Configuration, nil] Optional configuration
  # @return [String] Output file path
  # @api private
  def self.generate_output_path(input_path, index, output_dir, config)
    configuration = config || Configuration.default

    # Override output directory if provided
    if output_dir
      configuration = configuration.merge(output_directory: output_dir)
    end

    Utilities::OutputPathGenerator.generate(
      input_path,
      index,
      output_dir: configuration.output_directory,
    )
  end

  private_class_method :generate_output_path
end
