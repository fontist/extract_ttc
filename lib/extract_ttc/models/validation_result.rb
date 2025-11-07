# frozen_string_literal: true

module ExtractTtc
  module Models
    # Represents the result of a validation operation
    #
    # This model encapsulates the outcome of validating files, headers, or other
    # data structures, including whether the validation passed and any error
    # messages generated during validation.
    #
    # This is an immutable value object with methods to query validity status.
    class ValidationResult
      attr_reader :valid, :errors

      # Initialize a new validation result
      #
      # @param valid [Boolean] Whether the validation passed
      # @param errors [Array<String>] Array of error messages (empty if valid)
      def initialize(valid: true, errors: [])
        @valid = valid
        @errors = errors.freeze
      end

      # Check if the validation passed
      #
      # @return [Boolean] true if valid, false otherwise
      def valid?
        @valid
      end

      # Check if the validation failed
      #
      # @return [Boolean] true if invalid, false otherwise
      def invalid?
        !@valid
      end

      # Add an error message to the result
      #
      # This creates a new ValidationResult with the error added, as the object
      # is immutable.
      #
      # @param message [String] The error message to add
      # @return [ValidationResult] A new result object with the error added
      def add_error(message)
        self.class.new(
          valid: false,
          errors: @errors.dup << message,
        )
      end
    end
  end
end
