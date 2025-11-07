# frozen_string_literal: true

require_relative "../constants"

module ExtractTtc
  module Utilities
    # ChecksumCalculator provides stateless utility methods for calculating font file checksums.
    #
    # This class implements the TrueType/OpenType checksum algorithm which sums all uint32
    # values in a file. The checksum is used to verify file integrity and calculate the
    # checksumAdjustment value stored in the 'head' table.
    #
    # @example Calculate file checksum
    #   checksum = ChecksumCalculator.calculate_file_checksum("font.ttf")
    #   # => 2842116234
    #
    # @example Calculate checksum adjustment
    #   adjustment = ChecksumCalculator.calculate_adjustment(checksum)
    #   # => 1452851062
    class ChecksumCalculator
      # Calculate the checksum of an entire font file.
      #
      # The checksum is calculated by summing all uint32 (4-byte) values in the file.
      # Files that are not multiples of 4 bytes are padded with zeros. The sum is
      # masked to 32 bits to prevent overflow.
      #
      # @param file_path [String] path to the font file
      # @return [Integer] the calculated uint32 checksum
      # @raise [Errno::ENOENT] if the file does not exist
      # @raise [Errno::EACCES] if the file cannot be read
      #
      # @example
      #   checksum = ChecksumCalculator.calculate_file_checksum("font.ttf")
      #   # => 2842116234
      def self.calculate_file_checksum(file_path)
        File.open(file_path, "rb") do |file|
          calculate_checksum_from_io(file)
        end
      end

      # Calculate the checksum adjustment value for the 'head' table.
      #
      # The checksum adjustment is stored at offset 8 in the 'head' table and is
      # calculated as: CHECKSUM_ADJUSTMENT_MAGIC - file_checksum.
      # This value ensures that the checksum of the entire font file equals the
      # magic number.
      #
      # @param file_checksum [Integer] the calculated file checksum
      # @return [Integer] the checksum adjustment value to write to the 'head' table
      #
      # @example
      #   adjustment = ChecksumCalculator.calculate_adjustment(2842116234)
      #   # => 1452851062
      def self.calculate_adjustment(file_checksum)
        (Constants::CHECKSUM_ADJUSTMENT_MAGIC - file_checksum) & 0xFFFFFFFF
      end

      # Calculate checksum from an IO object.
      #
      # Reads the IO stream in 4-byte chunks and calculates the uint32 checksum.
      # This is the core checksum algorithm implementation.
      #
      # @param io [IO] the IO object to read from
      # @return [Integer] the calculated uint32 checksum
      # @api private
      def self.calculate_checksum_from_io(io)
        io.rewind
        sum = 0

        until io.eof?
          # Read 4 bytes at a time
          bytes = io.read(4)
          break if bytes.nil? || bytes.empty?

          # Pad with zeros if less than 4 bytes
          bytes += "\0" * (4 - bytes.length) if bytes.length < 4

          # Convert to uint32 (network byte order, big-endian)
          value = bytes.unpack1("N")
          sum = (sum + value) & 0xFFFFFFFF
        end

        sum
      end

      private_class_method :calculate_checksum_from_io
    end
  end
end
