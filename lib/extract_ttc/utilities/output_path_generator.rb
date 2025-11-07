# frozen_string_literal: true

module ExtractTtc
  module Utilities
    # OutputPathGenerator provides stateless utility methods for generating output file paths.
    #
    # This class generates standardized output paths for extracted TTF files from TTC files,
    # using a consistent naming convention with zero-padded indices.
    #
    # @example Generate output path with defaults
    #   path = OutputPathGenerator.generate("Helvetica.ttc", 0)
    #   # => "Helvetica_00.ttf"
    #
    # @example Generate output path with custom directory
    #   path = OutputPathGenerator.generate("Helvetica.ttc", 5, output_dir: "/tmp/fonts")
    #   # => "/tmp/fonts/Helvetica_05.ttf"
    class OutputPathGenerator
      # Default format string for zero-padded font indices.
      # Produces two-digit indices (00, 01, 02, etc.)
      DEFAULT_INDEX_FORMAT = "%02d"

      # Generate an output TTF file path for an extracted font.
      #
      # The output path is constructed from the input file's basename, a zero-padded
      # font index, and an optional output directory. The resulting filename follows
      # the pattern: "basename_XX.ttf" where XX is the zero-padded index.
      #
      # @param input_path [String] path to the input TTC file
      # @param font_index [Integer] zero-based index of the font being extracted
      # @param output_dir [String, nil] optional output directory (defaults to current directory ".")
      # @return [String] the generated output file path
      # @raise [ArgumentError] if font_index is negative
      #
      # @example Generate path in current directory
      #   OutputPathGenerator.generate("fonts/Helvetica.ttc", 0)
      #   # => "Helvetica_00.ttf"
      #
      # @example Generate path in specific directory
      #   OutputPathGenerator.generate("Helvetica.ttc", 3, output_dir: "/tmp")
      #   # => "/tmp/Helvetica_03.ttf"
      #
      # @example High font index
      #   OutputPathGenerator.generate("Font.ttc", 15)
      #   # => "Font_15.ttf"
      def self.generate(input_path, font_index, output_dir: nil)
        if font_index.negative?
          raise ArgumentError,
                "font_index must be non-negative"
        end

        basename = File.basename(input_path, ".*")
        formatted_index = sprintf(DEFAULT_INDEX_FORMAT, font_index)
        filename = "#{basename}_#{formatted_index}.ttf"

        if output_dir.nil? || output_dir.empty? || output_dir == "."
          filename
        else
          File.join(output_dir, filename)
        end
      end

      # Generate output path with a custom index format.
      #
      # Allows specifying a custom sprintf format string for the index padding,
      # enabling different padding widths or styles.
      #
      # @param input_path [String] path to the input TTC file
      # @param font_index [Integer] zero-based index of the font being extracted
      # @param index_format [String] sprintf format string for index formatting
      # @param output_dir [String, nil] optional output directory
      # @return [String] the generated output file path
      # @raise [ArgumentError] if font_index is negative
      #
      # @example Three-digit padding
      #   OutputPathGenerator.generate_with_format("Font.ttc", 5, "%03d")
      #   # => "Font_005.ttf"
      #
      # @example No padding
      #   OutputPathGenerator.generate_with_format("Font.ttc", 5, "%d")
      #   # => "Font_5.ttf"
      def self.generate_with_format(input_path, font_index, index_format,
output_dir: nil)
        if font_index.negative?
          raise ArgumentError,
                "font_index must be non-negative"
        end

        basename = File.basename(input_path, ".*")
        formatted_index = sprintf(index_format, font_index)
        filename = "#{basename}_#{formatted_index}.ttf"

        if output_dir.nil? || output_dir.empty?
          filename
        else
          File.join(output_dir, filename)
        end
      end
    end
  end
end
