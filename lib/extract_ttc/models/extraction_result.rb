# frozen_string_literal: true

module ExtractTtc
  module Models
    # Represents the result of a font extraction operation
    #
    # This model encapsulates the outcome of extracting fonts from a TTC file,
    # including the list of output files created, success status, and any errors
    # encountered during the process.
    #
    # This is an immutable value object with methods to query success/failure status.
    class ExtractionResult
      attr_reader :output_files, :success, :errors

      # Initialize a new extraction result
      #
      # @param output_files [Array<String>] Array of output file paths created
      # @param success [Boolean] Whether the extraction was successful
      # @param errors [Array<String>] Array of error messages (empty if successful)
      def initialize(output_files: [], success: true, errors: [])
        @output_files = output_files.freeze
        @success = success
        @errors = errors.freeze
      end

      # Check if the extraction was successful
      #
      # @return [Boolean] true if successful, false otherwise
      def success?
        @success
      end

      # Check if the extraction failed
      #
      # @return [Boolean] true if failed, false otherwise
      def failure?
        !@success
      end

      # Add an error message to the result
      #
      # This creates a new ExtractionResult with the error added, as the object
      # is immutable.
      #
      # @param message [String] The error message to add
      # @return [ExtractionResult] A new result object with the error added
      def add_error(message)
        self.class.new(
          output_files: @output_files.dup,
          success: false,
          errors: @errors.dup << message
        )
      end
    end
  end
end