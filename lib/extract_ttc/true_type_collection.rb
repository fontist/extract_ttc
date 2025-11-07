# frozen_string_literal: true

require "bindata"
require_relative "constants"

module ExtractTtc
  # TrueType Collection domain object using BinData
  #
  # Represents a complete TrueType Collection file using BinData's declarative
  # DSL for binary structure definition. The structure definition IS the
  # documentation, and BinData handles all low-level reading/writing.
  #
  # @example Reading and extracting fonts
  #   File.open("Helvetica.ttc", "rb") do |io|
  #     ttc = TrueTypeCollection.read(io)
  #     puts ttc.num_fonts  # => 6
  #     fonts = ttc.extract_fonts(io)  # => [TrueTypeFont, TrueTypeFont, ...]
  #   end
  class TrueTypeCollection < BinData::Record
    endian :big

    string :tag, length: 4, assert: "ttcf"
    uint16 :major_version
    uint16 :minor_version
    uint32 :num_fonts
    array :font_offsets, type: :uint32, initial_length: :num_fonts

    # Read TrueType Collection from a file
    #
    # @param path [String] Path to the TTC file
    # @return [TrueTypeCollection] A new instance
    # @raise [ArgumentError] if path is nil or empty
    # @raise [Errno::ENOENT] if file does not exist
    # @raise [RuntimeError] if file format is invalid
    def self.from_file(path)
      if path.nil? || path.to_s.empty?
        raise ArgumentError,
              "path cannot be nil or empty"
      end
      raise Errno::ENOENT, "File not found: #{path}" unless File.exist?(path)

      File.open(path, "rb") { |io| read(io) }
    rescue BinData::ValidityError => e
      raise "Invalid TTC file: #{e.message}"
    rescue EOFError => e
      raise "Invalid TTC file: unexpected end of file - #{e.message}"
    end

    # Extract fonts as TrueTypeFont objects
    #
    # Reads each font from the TTC file and returns them as TrueTypeFont objects.
    #
    # @param io [IO] Open file handle to read fonts from
    # @return [Array<TrueTypeFont>] Array of font objects
    def extract_fonts(io)
      require_relative "true_type_font"

      font_offsets.map do |offset|
        TrueTypeFont.from_ttc(io, offset)
      end
    end

    # Validate format correctness
    #
    # @return [Boolean] true if the format is valid, false otherwise
    def valid?
      tag == Constants::TTC_TAG && num_fonts.positive? && font_offsets.length == num_fonts
    rescue StandardError
      false
    end

    # Get the TTC version as a single integer
    #
    # @return [Integer] Version number (e.g., 0x00010000 for version 1.0)
    def version
      (major_version << 16) | minor_version
    end
  end
end
